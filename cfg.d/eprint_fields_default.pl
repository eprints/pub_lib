$c->add_dataset_trigger( 'eprint', EP_TRIGGER_DEFAULTS, sub {
	my( %params ) = @_;
	
	$params{data}->{type} = 'article';
}, id => 'default_eprint_type_article' );

=head1 COPYRIGHT AND LICENSE

=begin COPYRIGHT_AND_LICENSE

Copyright University of Southampton under the GNU Lesser General Public License. See https://github.com/eprints/eprint3.5/COPYING for further information.

EPrints 3.5 is supplied by EPrints Services.

=end COPYRIGHT_AND_LICENSE
