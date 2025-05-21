# Various config options for highlighted search

$c->{highlighted_search_enabled} = 1;

# If advanced searching for a particular field, this specifies what CSS selections it will possibly highlight in.
# If this is set to undef it will never highlight for that search (e.g. if the field isn't visible within the result citation)
$c->{highlighted_search_selection} = {
	creators_name => 'span.person_name',
	editors_name => 'span.person_name',
	abstract => 'div.embedded',
	type => undef, # Item Type facet
	ispublished => undef, # Status facet
};

# Which field(s) should be pulled from the record and included in the search page if they match
$c->{highlighted_search_embeddable} = ['abstract', 'note'];
