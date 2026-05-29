# These configuration variables are mostly unused and should be deprecated.

{
	my $uri = URI->new( "http://" );
        if( EPrints::Utils::is_set( $c->{securehost} ) )
        {
                $uri->scheme( "https" );
                $uri->host( $c->{securehost} );
                $uri->port( $c->{secureport} );
                $uri = $uri->canonical;
                $uri->path( $c->{https_root} );
        }
        else
        {
                $uri->scheme( "http" );
                $uri->host( $c->{host} );
                $uri->port( $c->{port} );
                $uri = $uri->canonical;
                $uri->path( $c->{http_root} );
        }

# EPrints base URL without trailing slash
	$c->{base_url} = "$uri";
# CGI base URL without trailing slash
	$c->{perl_url} = "$uri/cgi";
# Uncomment to keep URI for eprint items as http or different to base_url.
# May need editing, if repository on unusual port number, not on the root path or host is unset because HTTPS everywhere is configured.
	#$c->{uri_url} = "http://" . $c->{host};
}

# If you don't want EPrints to respond to a specific URL add it to the
# exceptions here. Each exception is matched against the uri using regexp:
#  e.g. /myspecial/cgi
# Will match http://yourrepo/myspecial/cgi
#$c->{rewrite_exceptions} = [];

#Set EPrints abstract page url to /id/eprint/XX instead of the shorter version /XX, for search engine optimisation.
$c->{use_long_url_format} = 1; 



=head1 COPYRIGHT AND LICENSE

=begin COPYRIGHT_AND_LICENSE

Copyright University of Southampton under the GNU Lesser General Public License. See https://github.com/eprints/eprint3.5/COPYING for further information.

EPrints 3.5 is supplied by EPrints Services.

=end COPYRIGHT_AND_LICENSE
