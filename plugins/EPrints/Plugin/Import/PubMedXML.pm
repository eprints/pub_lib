=head1 NAME

EPrints::Plugin::Import::PubMedXML

=cut

package EPrints::Plugin::Import::PubMedXML;

use strict;

use EPrints::Plugin::Import::DefaultXML;

our @ISA = qw/ EPrints::Plugin::Import::DefaultXML /;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{name} = "PubMed XML";
	$self->{visible} = "all";
	$self->{produce} = [ 'list/eprint', 'dataobj/eprint' ];

	return $self;
}

#sub top_level_tag
#{
#	my( $plugin, $dataset ) = @_;
#
#	return "PubmedArticleSet";
#}

sub resolve_month
{
	my ($month) = @_;
	my %months =
	(
		'jan' => '01', 'january' => '01', 
		'feb' => '02', 'february' => '02',
		'mar' => '03', 'march' => '03',
		'apr' => '04', 'april' => '04',
		'may' => '05', 
		'jun' => '06', 'june' => '06',
		'jul' => '07', 'july' => '07',
		'aug' => '08', 'august' => '08',
		'sep' => '09', 'september' => '09', 'sept' => '09',
		'oct' => '10', 'october' => '10',
		'nov' => '11', 'november' => '11',
		'dec' => '12', 'december' => '12',
	);
	if ($month =~ /^\d$/)
	{
		$month = '0' . $month ;
	}
	elsif ($month =~ /^\d\d$/)
	{
		# do  nothing
	}
	elsif (exists $months{lc($month)}) 
	{
		$month = $months{ lc($month) };
	}
	else 
	{
		# do nothing !
	}
	return $month ;
}

sub handler_class { "EPrints::Plugin::Import::DefaultXML::DOMHandler" }

sub xml_to_epdata
{
	# $xml is the PubmedArticle element
	my( $plugin, $dataset, $xml ) = @_;

	my $epdata = {};

	my $citation = $xml->getElementsByTagName("MedlineCitation")->item(0);
	return unless defined $citation;

	my $article = $citation->getElementsByTagName("Article")->item(0);
	return unless defined $article;

	my $articletitle = $article->getElementsByTagName( "ArticleTitle" )->item(0);
	$epdata->{title} = $plugin->xml_to_text( $articletitle ) if defined $articletitle;

	my $journal = $article->getElementsByTagName( "Journal" )->item(0);
	if( defined $journal )
	{
		my $title = $journal->getElementsByTagName( "Title" )->item(0);
		$epdata->{publication} = $plugin->xml_to_text( $title ) if defined $title;

		my $issn = $journal->getElementsByTagName( "ISSN" )->item(0);
		$epdata->{issn} = $plugin->xml_to_text( $issn ) if defined $issn;

		my $journalissue = $journal->getElementsByTagName( "JournalIssue" )->item( 0 );
		if( defined $journalissue )
		{
			my $volume = $journalissue->getElementsByTagName( "Volume" )->item(0);
			$epdata->{volume} = $plugin->xml_to_text( $volume ) if defined $volume;
	
			my $issue = $journalissue->getElementsByTagName( "Issue" )->item(0);
			$epdata->{number} = $plugin->xml_to_text( $issue ) if defined $issue;

			my $pubdate = $journalissue->getElementsByTagName( "PubDate" )->item(0);
			if( defined $pubdate )
			{
				my $year  = $pubdate->getElementsByTagName( "Year" )->item(0);
				my $month = $pubdate->getElementsByTagName( "Month" )->item(0);
				my $day   = $pubdate->getElementsByTagName( "Day" )->item(0);
				if (defined $year) # some pubdates have MedlineDate subfield (non parseable date : http://www.nlm.nih.gov/bsd/licensee/elements_descriptions.html#medlinedate)
				{
					my $tmpDate = $plugin->xml_to_text( $year );
					if (defined $month)
					{
						$month = $plugin->xml_to_text( $month );
						$month = resolve_month($month); # can be numeric or text ! (at least taken across all pubmed date fields)
						$tmpDate .= '-' . $month ; 
						if (defined $day)
						{
							$day = $plugin->xml_to_text( $day );
							if (length $day == 1) # convert 1 to 01
							{
								$day = '0' . $day ;
							}
							$tmpDate .= '-' . $day ;
						}	
					}
					if( defined $tmpDate )
					{
						$epdata->{date} = $tmpDate;
						$epdata->{date_type} = "published";
					}
				}
			}
		}
	}

	my $pagination = $article->getElementsByTagName( "Pagination" )->item(0);
	if( defined $pagination )
	{
		my $medlinepgn = $pagination->getElementsByTagName( "MedlinePgn" )->item(0);
		if( defined $medlinepgn )
		{
			$epdata->{pagerange} = $plugin->xml_to_text( $medlinepgn );
		}
		else
		{
			my $startpage = $pagination->getElementsByTagName( "StartPage" )->item(0);
			if( defined $startpage )
			{
				$epdata->{pagerange} = $plugin->xml_to_text( $startpage );

				my $endpage = $pagination->getElementsByTagName( "EndPage" )->item(0);
				$epdata->{pagerange} .= "-" . $plugin->xml_to_text( $endpage ) if defined $endpage;
			}
		}
	}

	my $abstract = $article->getElementsByTagName( "Abstract" )->item(0);
	if( defined $abstract )
	{
		my @parts;
		foreach my $at ( $abstract->getElementsByTagName( "AbstractText" ) )
		{
			if( $at->hasAttribute( "Label" ) )
			{
				push @parts, $at->getAttribute( "Label" );
			}
			push @parts, $plugin->xml_to_text( $at );
		}
		$epdata->{abstract} = join( "\n\n", @parts ) if scalar @parts;
	}

	my $authorlist = $article->getElementsByTagName( "AuthorList" )->item(0);
	if( defined $authorlist )
	{
		foreach my $author ( $authorlist->getElementsByTagName("Author") )
		{
			my $collectivename = $author->getElementsByTagName( "CollectiveName" )->item(0);

			if ( defined $collectivename )
			{
				push @{ $epdata->{corp_creators} }, $plugin->xml_to_text( $collectivename );
			}
			else
			{
				my $name = {};

				my $lastname = $author->getElementsByTagName( "LastName" )->item(0);
				$name->{family} = $plugin->xml_to_text( $lastname ) if defined $lastname;

				my $forename = $author->getElementsByTagName( "ForeName" )->item(0);
				$name->{given} = $plugin->xml_to_text( $forename ) if defined $forename;

				push @{ $epdata->{creators_name} }, $name;
			}
		}
	}

	my $i = 0;
	my %id_priority = ( 'doi' => 1, 'pubmed' => 2, 'pii' => 3 );
	my $cur_id_priority = 99;
	my $articleidlist = $xml->getElementsByTagName( "ArticleIdList" )->item(0);
	my $article_ids = $articleidlist->getElementsByTagName( "ArticleId" );
	while ( defined $article_ids->item( $i ) )
	{
		my $id = $article_ids->item( $i );
		if ( defined $id_priority{$id->getAttribute( "IdType" )} && $id_priority{$id->getAttribute( "IdType" )} < $cur_id_priority )
		{
			$cur_id_priority = $id_priority{$id->getAttribute( "IdType" )};
			$epdata->{id_number} = $id->getAttribute( "IdType" ) . ":" . $plugin->xml_to_text( $id );
		}
		$i++;
	}

	unless( defined $epdata->{publication} )
	{
		# Alternative way of getting (abbrev.) journal title
		my $medlinejournalinfo = $citation->getElementsByTagName( "MedlineJournalInfo" )->item(0);
		if( defined $medlinejournalinfo )
		{
			my $medlineta = $medlinejournalinfo->getElementsByTagName( "MedlineTA" )->item(0);
			$epdata->{publication} = $plugin->xml_to_text( $medlineta ) if defined $medlineta;
		}
	}

	# NLMCommon DTD has "Book" entity, but PubMed seems to
	# only contain articles
	# http://www.ncbi.nlm.nih.gov/entrez/query/DTD/nlmcommon_070101.dtd
	$epdata->{type} = "article";

	return $epdata;

}

1;

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

