
$c->{set_eprint_automatic_fields} = sub
{
	my( $eprint ) = @_;

	my $type = $eprint->value( "type" );
	if( $type eq "monograph" || $type eq "thesis" )
	{
		unless( $eprint->is_set( "institution" ) )
		{
 			# This is a handy place to make monographs and thesis default to
			# your institution
			#
			# $eprint->set_value( "institution", "University of Southampton" );
		}
	}

	if( $type eq "patent" )
	{
		$eprint->set_value( "ispublished", "pub" );
		# patents are always published!
	}

	if( $type eq "thesis" && !$eprint->is_set( "ispublished" ) )
	{
		$eprint->set_value( "ispublished", "unpub" );
		# thesis are usually unpublished.
	}

	my @docs = $eprint->get_all_documents();
	my $textstatus = "none";
	if( scalar @docs > 0 )
	{
		$textstatus = "public";
		foreach my $doc ( @docs )
		{
			if( !$doc->is_public )
			{
				$textstatus = "restricted";
				last;
			}
		}
	}
	$eprint->set_value( "full_text_status", $textstatus );
};

# To prevent citations, exports etc. from breaking, populate the default 'date' and 'date_type'
# fields using a suitable value from the new 'dates' field
$c->add_dataset_trigger( 'eprint', EPrints::Const::EP_TRIGGER_BEFORE_COMMIT, sub
{
	my( %args ) = @_;
	my( $repo, $eprint, $changed ) = @args{qw( repository dataobj changed )};
	
	# trigger is global - check that current repository actually has all expected date fields
	return unless $eprint->dataset->has_field( "dates" ) && $eprint->dataset->has_field( "date" ) && $eprint->dataset->has_field( "date_type" );

	# if this is an existing record, or a new record that has been imported, initialise
	# the 'dates' field first
	if( !$changed->{dates_date} && !$eprint->is_set( "dates" ) && $eprint->is_set( "date" ) )
	{
		$eprint->set_value( "dates", [
			{
				date => $eprint->value( "date" ),
				date_type => $eprint->value( "date_type" ),
			}
		]);
	}

	# set a suitable 'date' and 'date_type' value
	# use published date for preference - if not available use accepted date, and so on
	my %priority = %{$repo->config( 'date_priorities' )};

	return unless $eprint->is_set( "dates" );
	my @dates = sort {
		$priority{$b->{date_type}||"default"} <=> $priority{$a->{date_type}||"default"}
	} @{ $eprint->value( "dates" ) };

	my $date = scalar @dates ? $dates[0]->{date} : undef;
	my $date_type = scalar @dates ? $dates[0]->{date_type} : undef;

	$eprint->set_value( "date", $date );
	$eprint->set_value( "date_type", $date_type );

}, id => 'update_date_and_date_type_fields', priority => 100 );

# To prevent citations, exports etc. from breaking, populate the default  id_number'
# field using a suitable value from the new 'ids' field
# If multiple IDs of the same type are permitted first ID fo type with the highest
# priority will be used for in id_number field.
$c->add_dataset_trigger( 'eprint', EPrints::Const::EP_TRIGGER_BEFORE_COMMIT, sub
{
	my( %args ) = @_;
	my( $repo, $eprint, $changed ) = @args{qw( repository dataobj changed )};

	# trigger is global - check that current repository actually has ids field
	return unless $eprint->dataset->has_field( 'ids' );

	# if this is an existing record, or a new record that has been imported, initialise
	# the 'ids' field first
	my $idps = $repo->config( 'id_priorities' );
	if( !$changed->{ids} && !$eprint->is_set( "ids" ) && ( $eprint->is_set( "id_number" ) || $eprint->is_set( "isbn" ) || $eprint->is_set( "issn" ) ) )
	{
		my @ids = ();
		if ( $eprint->is_set( "id_number" ) )
		{
			my $id_number = $eprint->value( "id_number" );
			foreach my $id_type (sort { $idps->{$b} <=> $idps->{$a} } keys %{$idps})
			{
				if ( defined $c->{validate_id}->{$id_type} && $c->{validate_id}->{$id_type}( $repo, $id_number ) )
				{
					push @ids, { id => $id_number, id_type => $id_type };
					last;
				}
			}
		}
		if ( $eprint->is_set( "isbn" ) )
		{
			push @ids, { id => $eprint->value( "isbn" ), id_type => 'isbn' };
		}
		if ( $eprint->is_set( "issn" ) )
		{
			push @ids, { id => $eprint->value( "issn" ), id_type => 'issn' };
		}
		$eprint->set_value( "ids", \@ids ) if scalar @ids;
	}
	else
	{
		my $ids = $eprint->get_value( 'ids' );
		return unless scalar @{$ids} > 0;

		my $id_id = undef;
		my $id_type = undef;
		my $id_note = undef;
		foreach my $id (@{$ids})
		{
			$id->{id_type} = "undefined" unless defined $id->{id_type};
			if ( defined $id->{id} && defined $idps->{$id->{id_type}} && ( !defined $id_type || !defined $idps->{$id_type} || $idps->{$id->{id_type}} > $idps->{$id_type} ) )
			{
				$id_type = $id->{id_type};
				$id_id = $id->{id};
				$id_note = $id->{id_note};
			}
			if ( defined $id->{id} && $id->{id_type} eq "issn" )
			{
				my $issn = $id->{id};
				$issn .= " (" . $id->{id_note} . ")" if defined $id->{id_note};
				$eprint->set_value( "issn", $issn );
			}
			if ( defined $id->{id} &&  $id->{id_type} eq "isbn" )
			{
				my $isbn = $id->{id};
				$isbn .= " (" . $id->{id_note} . ")" if defined $id->{id_note};
				$eprint->set_value( "isbn", $isbn );
			}
		}
		if ( defined $id_id )
		{
			my $id_number = $id_id;
			$id_number = $id_type . ":" . $id_number if defined $id_type && $id_type ne "undefined";
			$id_number .= " (" . $id_note . ")" if defined $id_note;
			$eprint->set_value( "id_number", $id_number );
		}
	}
},  id => 'update_id_fields', priority => 100 );

$c->add_dataset_trigger( 'eprint', EPrints::Const::EP_TRIGGER_BEFORE_COMMIT, sub
{
	my( %args ) = @_;
	my( $repo, $eprint, $changed ) = @args{qw( repository dataobj changed )};

	my $primary_id_types = { person => 'email', organisation => 'ror' };
	my $contrib_person_fields = { 'creators' => 'http://www.loc.gov/loc.terms/relators/AUT', 'editors' => 'http://www.loc.gov/loc.terms/relators/EDT', 'contributors' => undef };
	my $contrib_org_fields = { 'corp_creators' => 'http://www.loc.gov/loc.terms/relators/AUT', 'publisher' => 'http://www.loc.gov/loc.terms/relators/PBL', 'funders' => 'http://www.loc.gov/loc.terms/relators/FND' };
	my $all_contrib_fields = { person => $contrib_person_fields, organisation => $contrib_org_fields };
	my @contributions = ();

	use Data::Dumper;
	foreach my $contrib_fields_id ( keys %$all_contrib_fields )
	{
		my $dataset = $repo->dataset( $contrib_fields_id );
		my $contrib_fields = $all_contrib_fields->{$contrib_fields_id};
		foreach my $contrib_field ( keys %{$all_contrib_fields->{$contrib_fields_id}} )
		{
			next unless $eprint->exists_and_set( $contrib_field );
			my $values = $eprint->value( $contrib_field );
			$values = [ $values ] unless ref( $values );
			my $contrib_type = $contrib_fields->{$contrib_field};
			foreach my $value ( @$values )
			{
				my $contrib_name = ref( $value ) ? $value->{name} : $value;
				$contrib_type = $value->{type} unless $contrib_type;
				my $entity = undef;
				$entity = EPrints::DataObj::Entity::entity_with_id( $dataset, $value->{id}, { type => $primary_id_types->{$contrib_fields_id}, name => $contrib_name } ) if ref( $value ) && $value->{id};
				if ( $entity )
				{
					unless ( $entity->has_name( $contrib_name ) )
					{
						my $names = $entity->get_value( 'names' );
						unshift @$names, { name => $contrib_name };
						$entity->set_value( 'names', $names );
						$entity->commit;
					}		
				}
				else
				{
					# Find an entity that matches the entity's name but does not already have an ID.
					$entity = EPrints::DataObj::Entity::entity_with_name( $dataset, $contrib_name, { no_id => 1 } );

					# If an entity is found but the entered field row has an ID, create a new entity including that ID.
					if( $entity && ref( $value ) && $value->{id} )
					{
						my $entity_data = { names => [ { name => $contrib_name } ], ids => [ { id => $value->{id}, id_type => $primary_id_types->{$contrib_fields_id} } ] };
						$entity = $dataset->create_dataobj( $entity_data );
						$entity->commit( 1 );
					}
					elsif ( !$entity )
					{
						my $entity_data = { names => [ { name => $contrib_name } ] };
						$entity_data->{ids} = [ { id => $value->{id}, id_type => $primary_id_types->{$contrib_fields_id} } ] if ref( $value ) && $value->{id} ;
						$entity = $dataset->create_dataobj( $entity_data );
						$entity->commit( 1 );
					}
				}
				push @contributions, { contributor => { entityid => $entity->id, datasetid => $contrib_fields_id }, type => $contrib_type };
			}
		}
	}

	$eprint->set_value( "contributions", \@contributions );

}, id => 'update_contributions', priority => 100 );



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

