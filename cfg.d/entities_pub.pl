$c->{entities}->{field_contribution_types}->{eprint}->{person} = {
    creators => 'https://id.loc.gov/vocabulary/relators/aut',
    editors => 'https://id.loc.gov/vocabulary/relators/edt',
    contributors => 'https://id.loc.gov/vocabulary/relators/oth',
};

$c->{entities}->{field_contribution_maps}->{eprint}->{person} = {
    creators => {
		name => 'contributor:name',
		id => 'contributor:id_value:id_type=email',
	},
    editors => {
		name => 'contributor:name',
		id => 'contributor:id_value:id_type=email',
	},
    contributors => {
		type => 'type',
		name => 'contributor:name',
		id => 'contributor:id_value:id_type=email',
	},	 
};

$c->{entities}->{field_contribution_types}->{eprint}->{organisation} = {
    corp_creators => 'https://id.loc.gov/vocabulary/relators/aut',
    publisher => 'https://id.loc.gov/vocabulary/relators/pbl',
    funders => 'https://id.loc.gov/vocabulary/relators/fnd',
    patent_applicant => 'https://id.loc.gov/vocabulary/relators/pta',
    copyright_holders => 'https://id.loc.gov/vocabulary/relators/cph',
};

# All existing field that map to organisations are non-compound fields so use default name mapping
$c->{entities}->{field_contribution_maps}->{eprint}->{organisation} = {};
