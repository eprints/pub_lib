$c->{date_priorities} = {
	published => 1000,
	published_online => 800,
	accepted => 600,
	submitted => 500,
    completed => 400,
    default => 0,
};

$c->{id_priorities} = {
	doi => 1000,
	isbn => 800,
	issn => 600,
	pmid => 500,
	pmcid => 400,
	undefined => 0,
};
