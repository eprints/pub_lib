

######################################################################
#
# EP_TRIGGER_VALIDATE 'eprint' dataset trigger
#
######################################################################
#
# $dataobj
# - EPrint object
# $repository
# - Repository object (the current repository)
# $for_archive
# - Is this being checked to go live (`1` means it is)
# $problems
# - ARRAYREF of DOM objects
#
######################################################################
#
# Validate the whole eprint, this is the last part of a full 
# validation so you don't need to duplicate tests in 
# validate_eprint_meta, validate_field or validate_document.
#
######################################################################

$c->add_dataset_trigger( 'eprint', EPrints::Const::EP_TRIGGER_VALIDATE, sub {
	my( %args ) = @_;
	my( $repository, $eprint, $problems ) = @args{qw( repository dataobj problems )};

	# If we don't have creators (eg. for a book) then we 
	# must have editor(s). To disable that rule, remove the 
	# following block.	
	if( !$eprint->is_set( "creators" ) && 
		!$eprint->is_set( "editors" ) )
	{
		my $fieldname = $repository->make_element( "span", class=>"ep_problem_field:creators" );
		push @$problems, $repository->html_phrase( 
				"validate:need_creators_or_editors",
				fieldname=>$fieldname );
	}
}, id => 'creator_or_editor');

# If you want to import legacy data which is exempt from the normal
# validation methods, then uncomment this function and make it return
# true for eprints which are not to be validated.
# $c->{skip_validation} = sub {
#   my( $eprint ) = @_;
#
#   return 0;
#};

# Validation - ensure that only one of each type of date (published, accepted etc).
# has been entered
$c->add_trigger( EPrints::Const::EP_TRIGGER_VALIDATE_FIELD, sub
{
	my( %args ) = @_;
	my( $repo, $field, $eprint, $value, $problems ) = @args{qw( repository field dataobj value problems )};

	return unless $field->name eq "dates_date_type";

	my %seen;
	for( @{ $value } )
	{
		next unless defined $_;
		$seen{$_}++;
	}

	for( keys %seen )
	{
		if( $seen{$_} > 1 )
		{
			my $parent = $field->get_property( "parent" );
			my $fieldname = $repo->xml->create_element( "span", class=>"ep_problem_field:".$parent->get_name );
			$fieldname->appendChild( $parent->render_name( $repo ) );
			push @$problems, $repo->html_phrase( "validate:datesdatesdates:duplicate_date_type",
				fieldname => $fieldname,
				date_type => $repo->html_phrase( "eprint_fieldopt_dates_date_type_$_" ),
			);
		}
	}
}, id => 'dates_date_type_unique', priority => 100 );

# Validation - ensure that the format of IDs used are correct.
$c->add_trigger( EPrints::Const::EP_TRIGGER_VALIDATE_FIELD, sub
{
	my( %args ) = @_;
	my( $repo, $field, $eprint, $value, $problems ) = @args{qw( repository field dataobj value problems )};

	return unless $field->name eq "ids_id";
	my $parent = $field->get_property( "parent" );
	my $validations = $repo->config( "validate_id" );

	return unless defined $validations;
	for( @{ $eprint->value( "ids" ) } )
	{
		my $id_value = $_->{id};
		my $id_type = $_->{id_type};
		if ( defined $validations->{$id_type} )
		{
			if ( !$validations->{$id_type}( $repo, $id_value ) )
			{
				my $fieldname = $repo->xml->create_element( "span", class=>"ep_problem_field:".$field->get_name );
				$fieldname->appendChild( $parent->render_name( $repo ) );
				push @$problems, $repo->html_phrase( "validate:invalid_id_format",
					fieldname => $fieldname,
					id_type => $repo->html_phrase( "eprint_fieldopt_ids_id_type_" . $id_type ),
					id_value => $repo->make_text( $id_value ),
				);
			}
		}
	}
}, id => 'ids_id_format', priority => 100 );

# Validation - check that articles and conference items have a full acceptance date
# relevant to UK institutions to help comply with HEFCE Open Access guidelines
#$c->add_trigger( EPrints::Const::EP_TRIGGER_VALIDATE_FIELD, sub
#{
#	my( %args ) = @_;
#	my( $repo, $field, $eprint, $value, $problems ) = @args{qw( repository field dataobj value problems )};
#
#	return unless $field->name eq "dates_date";
#	return unless $eprint->value( "type" ) eq "article" || $eprint->value( "type" ) eq "conference_item";
#
#	my $seen = 0;
#	my $comp = 0;
#	for( @{ $eprint->value( "dates" ) } )
#	{
#		next unless $_->{date_type} eq "accepted";
#		$seen = 1;
#		$comp = 1 if $_->{date} =~ /^\d{4}-\d{2}-\d{2}$/;
#		last;
#	}
#
#	if( !$seen )
#	{
#		my $parent = $field->get_property( "parent" );
#		my $fieldname = $repo->xml->create_element( "span", class=>"ep_problem_field:".$parent->get_name );
#		$fieldname->appendChild( $parent->render_name( $repo ) );
#		push @$problems, $repo->html_phrase( "validate:datesdatesdates:missing_accepted_date",
#			fieldname => $fieldname,
#		);
#	}
#
#	if( $seen && !$comp )
#	{
#		my $parent = $field->get_property( "parent" );
#		my $fieldname = $repo->xml->create_element( "span", class=>"ep_problem_field:".$parent->get_name );
#		$fieldname->appendChild( $parent->render_name( $repo ) );
#		push @$problems, $repo->html_phrase( "validate:datesdatesdates:incomplete_accepted_date",
#			fieldname => $fieldname,
#		);
#	}
#
#}, id => 'dates_date_type_accepted_required', priority => 100 );

# Validation - ensure that only one of each type of date (doi, pmid, etc). has been entered.
# Uncomment below to limit IDs to one per type.
#$c->add_trigger( EPrints::Const::EP_TRIGGER_VALIDATE_FIELD, sub
#{
#       my( %args ) = @_;
#       my( $repo, $field, $eprint, $value, $problems ) = @args{qw( repository field dataobj value problems )};
#
#       return unless $field->name eq "ids_id_type";
#
#       my %seen;
#       for( @{ $value } )
#       {
#	       next unless defined $_;
#	       $seen{$_}++;
#       }
#
#       for( keys %seen )
#       {
#	       if( $seen{$_} > 1 )
#	       {
#		       my $parent = $field->get_property( "parent" );
#		       my $fieldname = $repo->xml->create_element( "span", class=>"ep_problem_field:".$parent->get_name );
#		       $fieldname->appendChild( $parent->render_name( $repo ) );
#		       push @$problems, $repo->html_phrase( "validate:duplicate_id_type",
#			       fieldname => $fieldname,
#			       id_type => $repo->html_phrase( "eprint_fieldopt_ids_id_type_$_" ),
#		       );
#	       }
#       }
#}, id => 'ids_id_type_unique', priority => 200 );

$c->{validate_id}->{doi} = sub {
	my( $session, $value ) = @_;
	$value = "" unless defined $value;
	return EPrints::DOI->parse( $value, test => 1 );
};

$c->{validate_id}->{issn} = sub {
	my ( $session, $value ) = @_;
	$value = "" unless defined $value;
	$value =~ s/[- ]//g;
	$value =~ s/^ISSN//i;
	return 0 unless $value =~ /^[0-9X]{8}$/i;
	my $weight = 8;
	my $sum = 0;
	for my $c (split //, $value)
	{
		last if $weight == 1;
		$sum += $weight-- * $c;
	}
	my $checkdigit = 11 - $sum % 11;
	$checkdigit = "X" if $checkdigit == 10;
	return $checkdigit eq substr( $value, -1 );
};

$c->{validate_id}->{isbn} = sub {
	my ( $session, $value ) = @_;
	$value = "" unless defined $value;
	$value =~ s/[- ]//g;
	$value =~ s/^ISBN//i;
	return 0 unless $value =~ /^[0-9X]{10,13}$/i;
	if ( length $value == 10 )
	{
		my $weight = 10;
		my $sum = 0;
		for my $c (split //, $value)
		{
			last if $weight == 1;
			$sum += $weight-- * $c;
		}
		my $checkdigit = $sum % 11;
		$checkdigit = "X" if $checkdigit == 10;
		return $checkdigit eq substr( $value, -1 );
	}
	else
	{
		my $count = 0;
		my $sum = 0;
		for ( my $c = 0; $c < length( $value ) - 1; $c++ )
		{
			my $product = substr( $value, $c, 1 );
			$product = $product * 3 if $c % 2 == 1;
			$sum += $product;
		}
		my $checkdigit = 10 - $sum % 10;
		return $checkdigit == substr( $value, -1 );
	}
};

$c->{validate_id}->{pmcid} = sub {
	my ( $session, $value ) = @_;
	$value = "" unless defined $value;
	return if $value =~ /^PMC[0-9]+$/i;
};

$c->{validate_id}->{pmid} = sub {
	my ( $session, $value ) = @_;
	$value = "" unless defined $value;
	return if $value =~ /^[0-9]+$/i;
};

$c->{validate_id}->{undefined} = sub {
	my ( $session, $value ) = @_;
	return if defined $value;
};

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2022 University of Southampton.
EPrints 3.4 is supplied by EPrints Services.

http://www.eprints.org/eprints-3.4/

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints 3.4 L<http://www.eprints.org/>.

EPrints 3.4 and this file are released under the terms of the
GNU Lesser General Public License version 3 as published by
the Free Software Foundation unless otherwise stated.

EPrints 3.4 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints 3.4.
If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

