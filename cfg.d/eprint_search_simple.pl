
$c->{search}->{simple} = 
{
	search_fields => [
		{
			id => "q",
			meta_fields => [
				"documents",
				"title",
				"abstract",
				"creators_name",
				"date" 
			]
		},
	],
#	preamble_phrase => "cgi/search:preamble",
	title_phrase => "cgi/search:simple_search",
	citation => "result",
	page_size => 20,
	facets => [
		{ field_id => "type" },
		{ field_id => "ispublished" },
		{ field_id => "publisher" },
		{ field_id => "publication" },
		{ field_id => "date;res=year", field_name => "metafield_fieldopt_min_resolution_year" },
	],
	order_methods => {
		"byyear" 	 => "-date/creators_name/title",
		"byyearoldest"	 => "date/creators_name/title",
		"byname"  	 => "creators_name/-date/title",
		"bytitle" 	 => "title/creators_name/-date"
	},
	default_order => "byyear",
	show_zero_results => 1,
	template => "search",
};
		

=head1 COPYRIGHT AND LICENSE

=begin COPYRIGHT_AND_LICENSE

Copyright University of Southampton under the GNU Lesser General Public License. See README at https://github.com/eprints/eprints3.5 for further information.

EPrints 3.5 is supplied by EPrints Services.

=end COPYRIGHT_AND_LICENSE
