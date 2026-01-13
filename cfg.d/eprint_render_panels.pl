# panels definition for use on the eprints summary page
$c->{eprint_summary_panels} =
{
  panel1 =>
  {
    citation => "panel_table",
    title => "Citation",
    params =>
    {
    },
    data =>
    {
      metadata => [ qw/
title
creators_name
date
      / ],
    }
  },
  panel2 =>
  {
    citation => "panel_simple",
    title => "Abstract",
    params =>
    {
    },
    data =>
    {
      metadata => [ qw/
abstract
      / ],
    }
  },
  panel3 =>
  {
    citation => "panel_table",
    title => "Metadata",
    params =>
    {
    },
    data =>
    {
      metadata => [ qw/
id_number
userid
datestamp
rev_number
lastmod
      / ],
    }
  },
  panel4 =>
  {
    citation => "panel_ajax",
    # screen => "xxx", # not yet
    title => "Test Data",
    show_empty => 1,
    params =>
    {
      panel_url => "/cgi/counter",
    },
    data =>
    {
      metadata => [ qw/ / ],
    }
  },
};

# pass the panels config to the render function
$c->{eprint_render_panels} = sub
{
  my( $eprint, $repository ) = @_;

  my @panels_to_show = qw/ panel1 panel2 panel3 panel4 /;

  return &{$c->{render_panels}}( $eprint, $repository, $c->{eprint_summary_panels}, \@panels_to_show );
};
