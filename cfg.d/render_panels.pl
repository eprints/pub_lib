# process the panels data into a renderable format - as tabs (default) or as tiles only
$c->{render_panels_pagination_min} = 100; # add pagination controls if there are at least this number of panels
$c->{render_panels} = sub
{
  my( $item, $repository, $panels, $panels_to_show, $init_config, $_id ) = @_;

  $init_config = "as_tabs" unless $init_config;

  my $dataset = $item->get_dataset->base_id;
  my $id = ($_id) ? $_id : "ep_panel_set_" . $dataset . "_" . $item->get_id();
  my $page = $repository->make_element( "div", class => "ep_panel_container ep_panel_container_$dataset $id", id => $id );
  my $content = $repository->make_element( "div", class => "ep_panels", id => "${id}_panels" );
  my $buttons = $repository->make_element( "ul", class => "ep_panel_buttons nav nav-tabs", id => "${id}_buttons", role => "tablist", "aria-label" => "Tabbed Panels" );
  my $number_of_panels = 0;

  my $first = undef;
  my %content_stash; # hold onto content for deferred rendering

  foreach my $p ( @${panels_to_show} )
  {
    my $use_panel = 1;
    $item->{tmp__id} = $id . "__" . $p;
    my $has_content = 0;

    foreach my $f ( @{ $panels->{$p}->{data}->{metadata} } )
    {
      if( $item->is_set( $f ) )
      {
        $has_content = 1;
        last;
      }
    }

    my $show_empty = defined($panels->{$p}->{show_empty}) && $panels->{$p}->{show_empty} == 1;
    if( $has_content || $panels->{$p}->{data}->{panel_frag} || $show_empty )
    {
      $first = $p unless $first;

      # build up parameters for use within a citation
      my %processed_params;
      $panels->{$p}->{params}->{title} = $panels->{$p}->{title} unless defined $panels->{$p}->{params}->{title};
      $panels->{$p}->{params}->{dataset} = $dataset;
      foreach my $par ( keys  %{ $panels->{$p}->{params} } )
      {
        $processed_params{$par} = [ $repository->make_text( $panels->{$p}->{params}->{$par} ), "XHTML" ];
      }

      # if we have a render function, run it and store the result for use in the citation
      my $fn = $panels->{$p}->{render};
      if( defined( $fn ) && ref($fn) eq "CODE" )
      {
        my $render_rv = &{$fn}( 
          $item,
          $repository,
          ( defined $panels->{$p}->{params} ) ? $panels->{$p}->{params} : undef,
          ( defined $panels->{$p}->{data} ) ? $panels->{$p}->{data} : undef,
        );

        # if the render fn returns undef then skip the entire panel
        $use_panel = 0 unless defined $render_rv;

        $processed_params{ render } = [ $render_rv, "XHTML" ];
      }

      # if we have a dynamic data functions, run then and pass these to use in the citation - useful for setting up values based on the current dataobj, which are hard to evaluate in a citation or in a custon renderer
      my $fn0 = $panels->{$p}->{dynamic_data_start};
      my $fn1 = $panels->{$p}->{dynamic_data};
      my $fn2 = $panels->{$p}->{dynamic_data_end};
      my $dynamic_data0 = {};
      my $dynamic_data1 = {};
      my $dynamic_data2 = {};
      if( defined( $fn0 ) && ref($fn0) eq "CODE" ) { $dynamic_data0 = &{$fn0}( $item, $repository ); }
      if( defined( $fn1 ) && ref($fn1) eq "CODE" ) { $dynamic_data1 = &{$fn1}( $item, $repository ); }
      if( defined( $fn2 ) && ref($fn2) eq "CODE" ) { $dynamic_data2 = &{$fn2}( $item, $repository ); }

      if( $use_panel )
      {
        my $panel_order = ( $panels->{$p}->{panel_order} ) ? $panels->{$p}->{panel_order} : $number_of_panels; # not actively used
        my $tile_order  = ( $panels->{$p}->{tile_order} )  ? $panels->{$p}->{tile_order} : $number_of_panels; # used to determin the order when expanded into tiles

        my $div = $repository->make_element( "div", "id" => "$p", class => "ep_panel_wrapper", ep_panel_order => $panel_order, ep_tile_order => $tile_order, role => "tabpanel", "aria-labelledby" => "${id}_links_$p" );
        $div->setAttribute( "ep_panel_onchange", $panels->{$p}->{onchange} ) if $panels->{$p}->{onchange};
	
        $div->appendChild(
          $item->render_citation(
            $panels->{$p}->{citation}, %processed_params, data => $panels->{$p}->{data},
            dynamic_data_start => $dynamic_data0, dynamic_data => $dynamic_data1, dynamic_data_end => $dynamic_data2
        ) );

        # render later when the tile order has been confirmed
        $content_stash{ "$tile_order:$number_of_panels" } = $div;

	my $button = $repository->make_element( "li", "class" => "ep_panel_links ${id}_links nav-item nav-link p-2", id => "${id}_links_$p", onfocusin => "ep_open_panel(event, '$id', '$p')", "tabindex" => -100-$number_of_panels, role => "tab", "aria-controls" => "$p" );
        $button->appendChild( $repository->make_text( $panels->{$p}->{title} ) );
	$buttons->appendChild( $button );

        $number_of_panels++;
      }
    }
  }

  delete $item->{tmp__id};

  if( $number_of_panels >= $c->{render_panels_pagination_min} ) # add pagination controls
  {
    my $first_button = $repository->make_element( "li", "class" => "ep_panel_links ep_panel_nav ep_panel_first ${id}_first", id => "${id}_prev", onclick => "ep_open_panel_number(event, '$id', 1)" );
    $first_button->appendChild( $repository->make_text( "<<" ) );

    my $last_button = $repository->make_element( "li", "class" => "ep_panel_links ep_panel_nav ep_panel_last ${id}_last", id => "${id}_prev", onclick => "ep_open_panel_number(event, '$id', $number_of_panels)" );
    $last_button->appendChild( $repository->make_text( ">>" ) );

    my $prev_button = $repository->make_element( "li", "class" => "ep_panel_links ep_panel_nav ep_panel_prev ${id}_prev", id => "${id}_prev", onclick => "ep_open_prev_panel(event, '$id', 0)" );
    $prev_button->appendChild( $repository->make_text( "<" ) );

    my $next_button = $repository->make_element( "li", "class" => "ep_panel_links ep_panel_nav ep_panel_next ${id}_next", id => "${id}_next", onclick => "ep_open_next_panel(event, '$id', 0)" );
    $next_button->appendChild( $repository->make_text( ">" ) );

    $buttons->appendChild( $last_button );
    $buttons->appendChild( $next_button );
    $buttons->appendChild( $prev_button );
    $buttons->appendChild( $first_button );
  }

  if( $first ) # anything to show?
  {
    # render content_stash into content, ordered by tile_order
    foreach my $c ( sort {
      my @aa = split(":", $a);
      my @bb = split(":", $b);
      $aa[0] <=> $bb[0]
    } keys %content_stash )
    {
      $content->appendChild( $content_stash{$c} );
    }

    $content->setAttribute( number_of_panels => $number_of_panels );
    my $controls = $repository->make_element( "div", class => "ep_panel_controls", id => "${id}_controls" );
    my $open_all = $repository->make_element( "a", id => "${id}_controls_open", class => "ep_panel_controls_open", onclick => "ep_open_panel_all('$id');" );
    $open_all->appendChild( $repository->make_text( "[+]" ) );
    $controls->appendChild( $open_all );
    my $close_all = $repository->make_element( "a", id => "${id}_controls_close", class => "ep_panel_controls_close", onclick => "ep_close_panel_all('$id');" );
    $close_all->appendChild( $repository->make_text( "[-]" ) );
    $controls->appendChild( $close_all );

    $page->appendChild( $buttons );
    $page->appendChild( $controls );
    $page->appendChild( $content );
    $page->appendChild( $repository->make_javascript( "ep_panel_init('$first', '$init_config', '$id');" ) );

    # automatically page through the panels
    # $page->appendChild( $repository->make_javascript( "function loop_$id() { ep_open_next_panel(null, '$id', 1); }\nwindow.setInterval(loop_$id, 1000);" ) );
  }

  return $page;
};
