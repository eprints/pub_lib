=head1 NAME

EPrints::Plugin::Export::OAI_DC

=cut

package EPrints::Plugin::Export::OAI_DC;

# eprint needs magic documents field

# documents needs magic files field

use EPrints::Plugin::Export;

@ISA = ( "EPrints::Plugin::Export" );

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );

	$self->{name} = "Dublin Core - OAI Schema";
	$self->{accept} = [ 'dataobj/eprint' ];
	$self->{visible} = "";
	$self->{suffix} = ".xml";
	$self->{mimetype} = "text/xml";
	
	$self->{metadataPrefix} = "oai_dc";
	$self->{xmlns} = "http://www.openarchives.org/OAI/2.0/oai_dc/";
	$self->{schemaLocation} = "http://www.openarchives.org/OAI/2.0/oai_dc.xsd";

	return $self;
}


sub output_dataobj
{
	my( $plugin, $dataobj ) = @_;

	my $xml = $plugin->xml_dataobj( $dataobj );

	return EPrints::XML::to_string( $xml );
}


sub xml_dataobj
{
	my( $plugin, $dataobj ) = @_;

	my $main_dc_plugin = $plugin->{session}->plugin( "Export::DC" );
	
	my $data = $main_dc_plugin->convert_dataobj( $dataobj );

	my $dc = $plugin->{session}->make_element(
        	"oai_dc:dc",
		"xmlns:oai_dc" => "http://www.openarchives.org/OAI/2.0/oai_dc/",
        	"xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        	"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
		"xsi:schemaLocation" =>
 	"http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd" );

	# turn the list of pairs into XML blocks (indented by 8) and add them
	# them to the DC element.
	foreach( @{$data} )
	{
		$dc->appendChild(  $plugin->{session}->render_data_element( 8, "dc:".$_->[0], $_->[1], %{$_->[2]} ) );
		# produces <key>value</key>
	}

	return $dc;
}


1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2022 University of Southampton.
EPrints 3.4 is supplied by EPrints Services.

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

