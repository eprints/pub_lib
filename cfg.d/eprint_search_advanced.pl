
$c->{search}->{advanced} = 
{
	search_fields => [
		{ meta_fields => [ "documents" ] },
		{ meta_fields => [ "title" ] },
		{ meta_fields => [ "creators_name" ] },
		{ meta_fields => [ "abstract" ] },
		{ meta_fields => [ "date" ] },
		{ meta_fields => [ "keywords" ] },
		{ meta_fields => [ "subjects" ] },
		{ meta_fields => [ "type" ] },
		{ meta_fields => [ "divisions" ] },
		{ meta_fields => [ "editors_name" ] },
		{ meta_fields => [ "ispublished" ] },
		{ meta_fields => [ "refereed" ] },
		{ meta_fields => [ "publication" ] },
		{ meta_fields => [ "documents.format" ] },
	],
	preamble_phrase => "cgi/advsearch:preamble",
	title_phrase => "cgi/advsearch:adv_search",
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
