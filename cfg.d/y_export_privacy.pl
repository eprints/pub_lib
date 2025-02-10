if ( defined $c->{export_privacy} && $c->{export_privacy} )
{
	$c->{plugins}->{"Export::JSON"}->{params}->{visible} = "staff";
	$c->{plugins}->{"Export::XML"}->{params}->{visible} = "staff";
	$c->{plugins}->{"Export::CSV"}->{params}->{visible} = "staff";
	$c->{plugins}->{"Export::Simple"}->{params}->{visible} = "staff";
}
