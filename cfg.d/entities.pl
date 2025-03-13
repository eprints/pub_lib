$c->{entities}->{datasets} = [ qw/ person organisation / ];

$c->{render_contributions_contributor} = sub {

	my( $session, $field, $value, $alllangs, $nolink, $object ) = @_;

    $session = $object->repository unless $session->can("make_doc_fragment");

	my $frag = $session->make_doc_fragment;

	my $dataset = $session->get_dataset( $value->{datasetid} );
	my $entity = $dataset->dataobj( $value->{entityid} );
	
	$frag->appendChild( $entity->render_citation_link( 'default' ) );

	return $frag;
};	

