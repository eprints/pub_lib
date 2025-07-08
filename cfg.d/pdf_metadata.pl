# What information should we try and absorb from PDF metadata while importing

$c->{pdf_metadata_enabled} = 1;

$c->{title_metadata} = ["XMP-dc:Title", "PDF:Title"];

# Which metadata fields shall we read from to fill `authors`.
# This will split on ',', '\t', 'and', '&' and ';' to form multiple authors,
# and it will split according to `$c->{format_imported_author}` to fill
# the `given` and `family` fields.
$c->{authors_metadata} = ["XMP-sn:AuthorInfoName", "XMP-dc:Creator", "PDF:Author"];
$c->{authors_orcid_metadata} = ["XMP-sn:AuthorInfoOrcid"];

$c->{publication_metadata} = ["XMP-prism:PublicationName"];
$c->{issn_metadata} = ["XMP-prism:ISSN"];
$c->{publisher_metadata} = ["XMP-dc:Publisher"];
$c->{official_url_metadata} = ["XMP-prism:URL"];
$c->{volume_metadata} = ["XMP-prism:Volume"];
$c->{number_metadata} = ["XMP-prism:Number"];

$c->{page_count_metadata} = ["XMP-prism:PageCount", "PDF:PageCount"];
# Which metadata fields shall we read from to fill `pagerange` or `article_number` depending on if it contains a `-`
# If this field exists we don't use `page_start` and `page_end` from below (as `pagerange` and `article_number` are mutually exclusive)
$c->{page_range_metadata} = ["XMP-prism:PageRange"];
# Which metadata fields shall we read from to fill `pagerange` with '{page_start}-{page_end}'.
$c->{page_start_metadata} = ["XMP-prism:StartingPage"];
$c->{page_end_metadata} = ["XMP-prism:EndingPage"];

# Which metadata fields shall we read from to fill `date` (most other date fields are too inaccurate to be useful)
$c->{date_metadata} = ["XMP-prism:PublicationDate", "XMP-prism:CoverDate"];
# If we fill in the date from `date_metadata` above, what date_type should we give it.
# If this is "published" and we filled in the date then `ispublished` will be filled with "pub".
$c->{date_type_metadata_default} = "published";

$c->{id_number_metadata} = [
    "XMP-prism:DigitalObjectIdentifier",
    "XMP-pdfx:Doi",
    "XMP-crossmark:Doi"
];
# Whether to fill the `official_url` with 'https://doi.org/{id_number}' if the `official_url_metadata` fields don't exist.
$c->{fill_url_with_id_number} = 1;

# A function to split an author's name into the creators/contributions field.
#
# This is expected to return a single string `<name>` if `$has_contributions`
# is true and a hash ref of `{given => <given>, family => <family>}` if false.
#
# The default behaviour is to make the final word (split on spaces) the 'given
# name' and join in contributions as `<family>, <given>`.
$c->{format_imported_author} = sub {
	my( $name, $has_contributions ) = @_;

	my @words = split(' ', $name);
	my $given = join(' ', @words[0..$#words-1]);

	if( $has_contributions ) {
		return $words[-1] . ', ' . $given;
	} else {
		return {
			given => $given,
			family => $words[-1]
		};
	}
}
