$c->{entities}->{field_contribution_types}->{eprint}->{person} = {
    creators => 'http://www.loc.gov/loc.terms/relators/AUT',
    editors => 'http://www.loc.gov/loc.terms/relators/EDT',
    contributors => 'http://www.loc.gov/loc.terms/relators/OTH',
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
    corp_creators => 'http://www.loc.gov/loc.terms/relators/AUT',
    publisher => 'http://www.loc.gov/loc.terms/relators/PBL',
    funders => 'http://www.loc.gov/loc.terms/relators/FND',
    patent_applicant => 'http://www.loc.gov/loc.terms/relators/PTA',
    copyright_holders => 'http://www.loc.gov/loc.terms/relators/CPH',
};

# All existing field that map to organisations are non-compound fields so use default name mapping
$c->{entities}->{field_contribution_maps}->{eprint}->{organisation} = {};
