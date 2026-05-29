=head1 NAME

EPrints::Plugin::Import::XSLT

=cut

package EPrints::Plugin::Import::XSLT;

use EPrints::Plugin::Import;

@ISA = ( "EPrints::Plugin::Import" );

use strict;

our %SETTINGS; # class-specific settings

sub new
{
	my( $class, @args ) = @_;

	return $class->SUPER::new(
		%{$SETTINGS{$class}},
		@args
	);
}

sub init_xslt
{
	my( $class, $repo, $xslt ) = @_;

	delete $xslt->{doc};

	$SETTINGS{$class} = $xslt;
}

sub input_fh
{
	my( $self, %opts ) = @_;

	my $fh = $opts{fh};
	my $session = $self->{session};

	my $dataset = $opts{dataset};
	my $class = $dataset->get_object_class;
	my $root_name = $dataset->base_id;

	# read the source XML
	# note: LibXSLT will only work with LibXML, so that's what we use here
	my $source = XML::LibXML->new( expand_entities=>1, load_external_dtd=>1 )->parse_fh( $fh );

	# transform it using our stylesheet
	my $result = $self->transform( $source );

	my @ids;

	my $root = $result->documentElement;

	foreach my $node ($root->getElementsByTagName( $root_name ))
	{
		my $epdata = $class->xml_to_epdata( $session, $node );
		my $dataobj = $self->epdata_to_dataobj( $dataset, $epdata );
		next if !defined $dataobj;
		push @ids, $dataobj->id;
	}

	$session->xml->dispose( $source );
	$session->xml->dispose( $result );

	return EPrints::List->new(
		session => $session,
		dataset => $dataset,
		ids => \@ids );
}

sub transform
{
	my( $self, $doc ) = @_;

	my $ss_doc =  $self->{repository}->xml->parse_file( $self->{_filename} );
	my $stylesheet  = XML::LibXSLT->new->parse_stylesheet( $ss_doc );

	my $result = $stylesheet->transform( $doc );
	$stylesheet = undef;
	
	return $result;
}

1;

=head1 COPYRIGHT AND LICENSE

=begin COPYRIGHT_AND_LICENSE

Copyright University of Southampton under the GNU Lesser General Public License. See https://github.com/eprints/eprints3.5/blob/master/COPYING for further information.

EPrints 3.5 is supplied by EPrints Services.

=end COPYRIGHT_AND_LICENSE
