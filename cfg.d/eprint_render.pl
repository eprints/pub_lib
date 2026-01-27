# four ways to show the docs, use 1, or several
$c->{eprint_render_docs}->{"as separate panels"} = undef;	# render a set of panels under the main set for the docs to sit in
$c->{eprint_render_docs}->{"via citation"} = undef;		# use a citation to render the docs as a list under the main panel sets, much like it used to
$c->{eprint_render_docs}->{"as panel"} = undef;			# put the docs in a panel within the main panel set
$c->{eprint_render_docs}->{"as panel by type"} = 1;		# use a new panel in the main set for each type of doc, so images, texts, videos etc are grouped

# panels definition for use on the eprints summary page
$c->{eprint_summary_panels_local} =
{
  # just show the eprint abstract
  abstract =>
  {
    citation => "panel_simple",
    title => "Abstract",
    params =>
    {
    },
    data =>
    {
      metadata => [ qw/ abstract / ],
    }
  },

  # just show the eprint abstract as raw html
  abstract_raw =>
  {
    citation => "panel_render",
    title => "Abstract",
    show_empty => 1,

    render => sub 
    {
      my ($eprint, $repo) = @_;
      my $abstract = $eprint->get_value("abstract");
      return undef unless $abstract;
      my $dom = XML::LibXML->load_html( string => $abstract );
      my @nodelist = $dom->getElementsByTagName("body");
      my $body = $nodelist[0];
      return $body;   
    },
  },

  # ENTITIES - people
  entities_people =>
  {
    title => "People",
    citation => "panel_render",
    show_empty => 1,
    render => sub
    {
      my ( $eprint, $session ) = @_;

      my $contributions = $eprint->get_value( "contributions" );
 
      if( $session->get_repository->can_call( 'filter_eprint_contributions_by_entity_type' ) )
      {
        print STDERR "can_call filter_eprint_contributions_by_entity_type\n";
        $contributions = $session->get_repository->call( 'filter_eprint_contributions_by_entity_type', $session, $contributions, "person" );
      }
      else
      {
        print STDERR "can NOT call filter_eprint_contributions_by_entity_type\n";
        return;
      }

      my $frag = $session->make_element("div", class => "row row-cols-1 row-cols-md-2 row-cols-lg-3 m-1 g-4");
      my $eprint_ds = $session->dataset( "eprint" );
      my $person_ds = $session->dataset( "person" );

      for my $contribution ( @$contributions )
      {
		my $person = $person_ds->dataobj( $contribution->{contributor}->{entityid} );

		my $type_field = $eprint_ds->get_field( "contributors_type" );
		my $type_value = $type_field->render_single_value( $session, $contribution->{type} );

		my $flags = {};
		my %fragments = ( %{$contribution->{contributor}}, type => $type_value );

		foreach my $key ( keys %fragments ) { $fragments{$key} = [ $fragments{$key}, "XHTML" ]; }

		my $citation = $person->render_citation( "summary_box", %fragments, flags=>$flags );
		$frag->appendChild( $citation );
      }

      return $frag;
    },
  },

  # ENTITIES - organisations
  entities_organisations =>
  {
    title => "Organisations",
    citation => "panel_render",
    show_empty => 1,
    render => sub
    {
      my ( $eprint, $session ) = @_;

      my $contributions = $eprint->get_value( "contributions" );
 
      if( $session->get_repository->can_call( 'filter_eprint_contributions_by_entity_type' ) )
      {
        print STDERR "can_call filter_eprint_contributions_by_entity_type\n";
        $contributions = $session->get_repository->call( 'filter_eprint_contributions_by_entity_type', $session, $contributions, "organisation" );
      }
      else
      {
        print STDERR "can NOT call filter_eprint_contributions_by_entity_type\n";
        return;
      }

      my $frag = $session->make_element("div", class => "row row-cols-1 row-cols-md-2 row-cols-lg-3 m-1 g-4");
      my $eprint_ds = $session->dataset( "eprint" );
      my $organisation_ds = $session->dataset( "organisation" );

      for my $contribution ( @$contributions )
      {
		my $organisation = $organisation_ds->dataobj( $contribution->{contributor}->{entityid} );

		my $type_field = $eprint_ds->get_field( "contributors_type" );
		my $type_value = $type_field->render_single_value( $session, $contribution->{type} );

		my $flags = {};
		my %fragments = ( %{$contribution->{contributor}}, type => $type_value );

		foreach my $key ( keys %fragments ) { $fragments{$key} = [ $fragments{$key}, "XHTML" ]; }

		my $citation = $organisation->render_citation( "summary_box", %fragments, flags=>$flags );
		$frag->appendChild( $citation );
      }

      return $frag;
    },
  },

  # show the docs in a panel
  docs =>
  {
    citation => "panel_render",
    title => "Documents",
    show_empty => 1,
    params => {},
    render => sub 
    {
      my ($eprint, $repo) = @_;
      my $docs_panelfn = $c->{eprint_render_docs_as_panels};
      return &{$docs_panelfn}( $eprint, $repo, 0 );
    },
  },

  # explicitly define handlers for all default document format types, not very succinctly
  docs_image =>  {
    title => "Images", citation => "panel_render", show_empty => 1, params => {},
    render => sub { my ($eprint, $repo) = @_; my $docs_panelfn = $c->{eprint_render_docs_as_panels}; return &{$docs_panelfn}( $eprint, $repo, 0, "image" ); }, },
  docs_video => {
    title => "Videos", citation => "panel_render", show_empty => 1, params => {},
    render => sub { my ($eprint, $repo) = @_; my $docs_panelfn = $c->{eprint_render_docs_as_panels}; return &{$docs_panelfn}( $eprint, $repo, 0, "video" ); }, },
  docs_audio =>  {
    title => "Audio", citation => "panel_render", show_empty => 1, params => {},
    render => sub { my ($eprint, $repo) = @_; my $docs_panelfn = $c->{eprint_render_docs_as_panels}; return &{$docs_panelfn}( $eprint, $repo, 0, "audio" ); }, },
  docs_text => {
    title => "Texts", citation => "panel_render", show_empty => 1, params => {},
    render => sub { my ($eprint, $repo) = @_; my $docs_panelfn = $c->{eprint_render_docs_as_panels}; return &{$docs_panelfn}( $eprint, $repo, 0, "text" ); }, },
  docs_slideshow =>  {
    title => "Slideshows", citation => "panel_render", show_empty => 1, params => {},
    render => sub { my ($eprint, $repo) = @_; my $docs_panelfn = $c->{eprint_render_docs_as_panels}; return &{$docs_panelfn}( $eprint, $repo, 0, "slideshows" ); }, },
  docs_spreadsheet => {
    title => "Spreadsheets", citation => "panel_render", show_empty => 1, params => {},
    render => sub { my ($eprint, $repo) = @_; my $docs_panelfn = $c->{eprint_render_docs_as_panels}; return &{$docs_panelfn}( $eprint, $repo, 0, "spreadsheets" ); }, },
  docs_archive =>  {
    title => "Archives", citation => "panel_render", show_empty => 1, params => {},
    render => sub { my ($eprint, $repo) = @_; my $docs_panelfn = $c->{eprint_render_docs_as_panels}; return &{$docs_panelfn}( $eprint, $repo, 0, "archives" ); }, },
  docs_other => {
    title => "Other Docs", citation => "panel_render", show_empty => 1, params => {},
    render => sub { my ($eprint, $repo) = @_; my $docs_panelfn = $c->{eprint_render_docs_as_panels}; return &{$docs_panelfn}( $eprint, $repo, 0, "other" ); }, },
  docs_restricted => {
    title => "Restricted", citation => "panel_render", show_empty => 1, params => {},
    render => sub { my ($eprint, $repo) = @_; my $docs_panelfn = $c->{eprint_render_docs_as_panels}; return &{$docs_panelfn}( $eprint, $repo, 0, "restricted" ); }, },

  # show the main eprint metadata fields
  metadata =>
  {
    citation => "panel_table",
    title => "Information",
    params =>
    {
    },
    data =>
    {
      metadata => [ qw/
title
creators_name
editors_name
contributors
id_number
official_url
date
subjects
divisions
commentary
publisher
note
      / ],
    },
#    dynamic_data => sub
#    {
#      my( $eprint, $repository ) = @_;
#
#      my $dynamic_data->{keys} = [ "URI" ];
#      my $link = $repository->make_element( "a", href => $eprint->uri() );
#         $link->appendChild( $repository->make_text( $eprint->uri() ) );
#      $dynamic_data->{ "URI" } = $link;
#
#      return $dynamic_data;
#    },
  },

  # fields more of interest to the library
  library =>
  {
    citation => "panel_table",
    title => "Library",
    params =>
    {
    },
    data =>
    {
      metadata => [ qw/
type
pres_type
monograph_type
thesis_type
source
userid
sword_depositor
datestamp
rev_number
lastmod
      / ],
    },
    dynamic_data => sub
    {
      my( $eprint, $repository ) = @_;

      my $dynamic_data->{keys} = [ "URI" ];
      my $link = $repository->make_element( "a", href => $eprint->uri() );
         $link->appendChild( $repository->make_text( $eprint->uri() ) );
      $dynamic_data->{ "URI" } = $link;

      return $dynamic_data;
    },
  },

  # add IRStats2 for this item into a panel, requires 'irstats2.5'
  stats =>
  {
    citation => "panel_render",
    title => "Statistics",
    show_empty => 1,
    tile_order => 50, # display at the end when rendered as tiles
    onchange => "irstats2_redraw", # name of javascript fn to call when resize/redraw happens

    render => sub 
    {
      my ($eprint, $repo) = @_;
      my $frag = $repo->make_element("div", onresize => "console.log('resize')");
      my $util = $repo->get_conf( "irstats2", "util" );
      if( $util )
      {
        $frag->appendChild( &{$util->{render_summary_page_totals}}( $repo, $eprint ) );
        $frag->appendChild( &{$util->{render_summary_page_docs}}( $repo, $eprint ) );
      }
      return $frag;
    },
  },

  # add a threaded discussion forum in a comment panel, requires 'annotations'
  comments =>
  {
    citation => "panel_render",
    title => "Comments",
    show_empty => 1,
    render => sub
    {
      my ($eprint, $repo) = @_;
      my $id = $eprint->get_id;
      my $frag = $repo->xml()->create_document_fragment();
      $frag->appendChild( $repo->make_element( "div", id => "eprint_${id}_discuss" ) );
      $frag->appendChild( $repo->make_javascript( "anno_init_discuss( 'eprint/${id}', '#eprint_${id}_discuss' );" ) );
      return $frag;
    },
  },
};

# pass the panels config to the render function - override this in your archive config to change the panels and their order
$c->{eprint_render_panels_local} = sub
{
  my( $eprint, $repository ) = @_;
  
  my @panels_to_show;
  my $public_docs = 0;
  push @panels_to_show, "abstract" if( $eprint->get_value("abstract") );
  push @panels_to_show, "entities_people"; # if( $eprint->get_value("abstract") );
  push @panels_to_show, "entities_organisations"; # if( $eprint->get_value("abstract") );
  # push @panels_to_show, "abstract" if( $eprint->get_value("abstract_raw") );
  push @panels_to_show, "docs"  if( $c->{eprint_render_docs}->{"as panel"} && scalar( $eprint->get_all_documents ) );

  # render each doc type as its own panels, so all image together, all text docs together etc
  if( $c->{eprint_render_docs}->{"as panel by type"} && scalar( $eprint->get_all_documents ) )
  {
    my %dtype_panels;
    foreach my $doc ( $eprint->get_all_documents )
    {
      my $type = $doc->get_value("format");
      $dtype_panels{ "docs_" . $type } = 1;
    }

    push @panels_to_show, (sort keys %dtype_panels); # in no meaningful order
  }
  #FNU-27 Hide Statistics panel when there are only restricted documents 
  foreach my $doc ( $eprint->get_all_documents )  
  {
    $public_docs++ if $doc->is_public; 
  } 
  push @panels_to_show, "metadata";
  push @panels_to_show, "library";
  # push @panels_to_show, "altmetric" if( &{$c->{altmetric}->{panel}->{include_altmetric_panel}}( $repository, $eprint ) );
  #push @panels_to_show, "stats" if( ( $repository->flavour_has("ingredients/irstats2") || $repository->flavour_has("ingredients/irstats2.5") ) && $public_docs > 0  );
  #push @panels_to_show, "comments" if $repository->flavour_has("ingredients.spicy/annotations");
  # call and return the main panel render code
  print STDERR EPrints->dump(@panels_to_show);
  return &{$c->{render_panels}}( $eprint, $repository, $c->{eprint_summary_panels_local}, \@panels_to_show );
};

$c->{summary_page_metadata} = [qw/
/];

# a version of the classic eprint render routine, with panels rendered as tabs to show the abstract and metadata fields
$c->{eprint_render} = sub
{
	my( $eprint, $repository, $preview ) = @_;

	my $succeeds_field = $repository->dataset( "eprint" )->field( "succeeds" );
	my $commentary_field = $repository->dataset( "eprint" )->field( "commentary" );

	my $flags = { 
		has_multiple_versions => $eprint->in_thread( $succeeds_field ),
		in_commentary_thread => $eprint->in_thread( $commentary_field ),
		preview => $preview,
	};
	my %fragments = ();

	# Put in a message describing how this document has other versions
	# in the repository if appropriate
	if( $flags->{has_multiple_versions} )
	{
		my $latest = $eprint->last_in_thread( $succeeds_field );
		if( $latest->value( "eprintid" ) == $eprint->value( "eprintid" ) )
		{
			$flags->{latest_version} = 1;
			$fragments{multi_info} = $repository->html_phrase( "page:latest_version" );
		}
		else
		{
			$fragments{multi_info} = $repository->render_message(
				"warning",
				$repository->html_phrase( 
					"page:not_latest_version",
					link => $repository->render_link( $latest->get_url() ) ) );
		}
	}		


	# Now show the version and commentary response threads
	if( $flags->{has_multiple_versions} )
	{
		$fragments{version_tree} = $eprint->render_version_thread( $succeeds_field );
	}
	
	if( $flags->{in_commentary_thread} )
	{
		$fragments{commentary_tree} = $eprint->render_version_thread( $commentary_field );
	}

	foreach my $key ( keys %fragments ) { $fragments{$key} = [ $fragments{$key}, "XHTML" ]; }
	
	#my $page = $eprint->render_citation( "summary_page1", %fragments, flags=>$flags );
	my $page = $repository->xml()->create_document_fragment();


	my $panelfn = $c->{eprint_render_panels_local};
	#my $panelfn = $c->{eprint_render_panels};
	my $docs_panelfn = $c->{eprint_render_docs_as_panels};

	$page->appendChild( $eprint->render_citation( "summary_page_citation", %fragments, flags=>$flags ) );
	$page->appendChild( $eprint->render_citation( "summary_page_ai_summaries", %fragments, flags=>$flags ) );
	my @docs = $eprint->get_all_documents;
	for my $doc ( @docs )
	{
		next if $doc->get_value("security") =~ m/validuser|staffonly/;
		if ( $doc->get_value("format") =~ m/text/ ) {
			$page->appendChild( $doc->render_citation( "summary_page_doc_pdf_preview", params => {} ) );
			last;
		}
	}
	$page->appendChild( &{$panelfn}( $eprint, $repository ) );
	$page->appendChild( &{$docs_panelfn}( $eprint, $repository, $preview ) ) if $c->{eprint_render_docs}->{"as separate panels"}; # add docs into their own panel set under the main one

	$page->appendChild( $eprint->render_citation( "summary_page_traditional_doc_preview", %fragments, flags=>$flags ) ) if $c->{eprint_render_docs}->{"via citation"}; # add docs in the traditional way
	$page->appendChild( $eprint->render_citation( "summary_page_manage", %fragments, flags=>$flags ) );

	my $title = $eprint->render_citation("brief");

	my $links = $repository->xml()->create_document_fragment();
	if( !$preview )
	{
		$links->appendChild( $repository->plugin( "Export::Simple" )->dataobj_to_html_header( $eprint ) );
		$links->appendChild( $repository->plugin( "Export::DC" )->dataobj_to_html_header( $eprint ) );
	}

	return( $page, $title, $links, "default_internal" );
};

# render the documents as a set of panels, so they are easily manipulated
# TODO: review which docs get shown, may not want all seen
$c->{eprint_render_docs_as_panels} = sub
{
	my( $eprint, $session, $preview, $filter ) = @_;

        my $page = $session->make_doc_fragment;

	my $number_of_docs = scalar( $eprint->get_all_documents );
	return $page unless $number_of_docs;

        my $fn = $session->get_conf( "render_panels" );
        if ( !defined($fn) || ref $fn ne "CODE" )
        {
                print STDERR "Cannot find definition for callback: render_panels\n";
                return $page;
        }

        my $panels;
        my @panels_to_show;
        my $index = 0;
        my $docs_css = (defined $filter) ? "docs_$filter" : "docs";
        my $panel_set_id = "ep_panel_set_" . $docs_css . "_" . $eprint->get_id();
        my $reference_doc;
	my @docs = $eprint->get_all_documents;

	foreach my $doc ( @docs )
        {
                $reference_doc = $doc;
                $index++;
                next if( defined($filter) && $doc->get_value("format") ne $filter ); # honour the filter if its set

                $panels->{ "panel_" . $index } =
                {
                        title => $eprint->get_id() . ":" . $doc->get_id(),
                        show_empty => 1,
                        params =>
                        {
                                id => "panel_$index",
                                panel_set_id => $panel_set_id,
                                doc_index => $index -1, # zero based
				filter => $filter,
			},
                        citation => "panel_render",
			render => sub
			{
				my ($eprint, $repo, $params, $data) = @_;
				return $doc->render_citation( "summary_page_doc", params => $params, data => $data );
			}
                };
                push @panels_to_show,  "panel_" . $index;
        }

#	if( $number_of_docs == 1 ) # pad with blank
#	{
#		$panels->{ "panel_blank" } = { show_empty => 1, citation => "panel_blank", title => "" };
#		unshift @panels_to_show, "panel_blank";
#	}

        my $panels_div = &{$fn}(
                $reference_doc,
                $session,
                $panels,
                \@panels_to_show,
                "as_tiles",
		$panel_set_id );

        $page->appendChild( $panels_div );

        return $page;
};


=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2016 University of Southampton.
EPrints 3.4 preview 2 is supplied by EPrints Services.
This software is supplied as is and is for demonstration purposes.
This software may be used with permission and must not be redistributed.
http://www.eprints.org/eprints-3.4/

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints 3.4 L<http://www.eprints.org/>.

EPrints 3.4 and this file are released under the terms of the
GNU Lesser General Public License version 3 as published by
the Free Software Foundation unless otherwise stated.

EPrints 3.4 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints 3.4.
If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

