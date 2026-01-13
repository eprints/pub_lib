$c->{altmetric}->{panel}->{render_altmetric_panel} = sub
{
  my ( $repo, $eprint ) = @_;

  my $frag = $repo->xml()->create_document_fragment();
  my ( $type, $id ) = $repo->call( [ "altmetric", "get_type_and_id" ], $eprint );
  return $frag if ( !defined $type || !defined $id );

  my $div = $frag->appendChild( $repo->make_element( 'div', id => 'altmetric_summary_page', "data-altmetric-id-type" => $type, "data-altmetric-id" => $id ) );
  $frag->appendChild( $repo->make_javascript( <<EOJ ) );
new EP_Altmetric_Badge( 'altmetric_summary_page' );
EOJ

  return $frag;
};

$c->{altmetric}->{panel}->{include_altmetric_panel} = sub
{
  my ( $repo, $eprint ) = @_;

  my ( $type, $id ) = $repo->call( [ "altmetric", "get_type_and_id" ], $eprint );

  return ( $type && $id );
};

$c->{eprint_summary_panels_local}->{altmetric} =
  {
    citation => "panel_render",
    title => "Altmetric",
    show_empty => 1,
    # tile_order => 40,

    render => sub
    {
      my ($eprint, $repo) = @_;
      my $frag = undef;
      my $util = $repo->get_conf( "altmetric", "panel" );
      if( $util )
      {
        $frag = $repo->make_element("div");
        $frag->appendChild( &{$util->{render_altmetric_panel}}( $repo, $eprint ) );
      }
      return $frag;
    },
  };
