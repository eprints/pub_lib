$c->{entities}->{field_contribution_types}->{eprint}->{person} = {
    creators => 'http://id.loc.gov/vocabulary/relators/aut',
    editors => 'http://id.loc.gov/vocabulary/relators/edt',
    contributors => 'http://id.loc.gov/vocabulary/relators/oth',
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
    corp_creators => 'http://id.loc.gov/vocabulary/relators/aut',
    publisher => 'http://id.loc.gov/vocabulary/relators/pbl',
    funders => 'http://id.loc.gov/vocabulary/relators/fnd',
    patent_applicant => 'http://id.loc.gov/vocabulary/relators/pta',
    copyright_holders => 'http://id.loc.gov/vocabulary/relators/cph',
};

# All existing field that map to organisations are non-compound fields so use default name mapping
$c->{entities}->{field_contribution_maps}->{eprint}->{organisation} = {};
