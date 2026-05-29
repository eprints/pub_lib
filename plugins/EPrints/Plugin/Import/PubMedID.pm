=head1 NAME

EPrints::Plugin::Import::PubMedID

=cut

package EPrints::Plugin::Import::PubMedID;

use strict;


use EPrints::Plugin::Import;
use URI;

our @ISA = qw/ EPrints::Plugin::Import /;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{name} = "PubMed ID";
	$self->{visible} = "all";
	$self->{produce} = [ 'list/eprint', 'dataobj/eprint' ];

	$self->{EFETCH_URL} = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&rettype=full';

	return $self;
}

sub input_fh
{
	my( $plugin, %opts ) = @_;

	my @ids;

	my $pubmedxml_plugin = $plugin->{session}->plugin( "Import::PubMedXML", Handler=>$plugin->handler );
	$pubmedxml_plugin->{parse_only} = $plugin->{parse_only};
	my $fh = $opts{fh};
	while( my $pmid = <$fh> )
	{
		$pmid =~ s/^\s+//;
		$pmid =~ s/\s+$//;
		if( $pmid !~ /^[0-9]+$/ ) # primary IDs are always an integer
		{
			$plugin->warning( "Invalid ID: $pmid" );
			next;
		}

		# Fetch metadata for individual PubMed ID 
		# NB. EFetch utility can be passed a list of PubMed IDs but
		# fails to return all available metadata if the list 
		# contains an invalid ID
		my $url = URI->new( $plugin->{EFETCH_URL} );
		$url->query_form( $url->query_form, id => $pmid );

 		my $req = HTTP::Request->new("GET", $url);
 		$req->header( "Accept" => "text/xml" );
 		$req->header( "Accept-Charset" => "utf-8" );
 
 		my $ua = LWP::UserAgent->new;
 		my $resp = $ua->request( $req );
 
 		if( $resp->code != 200 )
 		{
 			$plugin->warning( "Could not connect to remote site: $url (".$resp->code.")" );
 			next;
 		}
 
 		my $parser = XML::LibXML->new( expand_entities=>1, load_external_dtd=>1 );
 		my $xml = $parser->parse_string( $resp->content );	
		
		my $root = $xml->documentElement;

		if( $root->nodeName eq 'ERROR' )
		{
			EPrints::XML::dispose( $xml );
			$plugin->warning( "No match: $pmid" );
			next;
		}

		foreach my $article ($root->getElementsByTagName( "PubmedArticle" ))
		{
			my $item = $pubmedxml_plugin->xml_to_dataobj( $opts{dataset}, $article );
			if( defined $item )
			{
				push @ids, $item->get_id;
			}
		}

		EPrints::XML::dispose( $xml );
	}

	return EPrints::List->new( 
		dataset => $opts{dataset}, 
		session => $plugin->{session},
		ids=>\@ids );
}

1;

=head1 COPYRIGHT AND LICENSE

=begin COPYRIGHT_AND_LICENSE

Copyright University of Southampton under the GNU Lesser General Public License. See README at https://github.com/eprints/eprints3.5 for further information.

EPrints 3.5 is supplied by EPrints Services.

=end COPYRIGHT_AND_LICENSE
