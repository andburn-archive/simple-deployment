#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI;

my $html_output = '';
my $html_content = '';

my $name=param('name');
my $address=param('address');

$html_content .= "<h3>inserting name:$name and address:$address into Database</h3>";
insertDB($name,$address);
$html_content .= "<h3>Showing the contents of the Database</h3>";
$html_content .= showDB();

open IFILE, 'main.html';
while (<IFILE>) {
	if (/<%CONTENT%>/) {
		# add content instead of current line
		$html_output .= $html_content;
	} else {
		# add line to output
		$html_output .= $_;
	}
}
close IFILE;

# output html
print header;

print $html_output;

exit;

sub insertDB {
	my $name = shift;
	my $address = shift;

	my $dbhost='127.0.0.1'; my $dbport=3306;
	my $dsn="DBI:mysql:dbtest;host=$dbhost;port=$dbport";
	$dbh = DBI->connect($dsn, 'dbtestuser', 'dbpassword'
			) || die "Could not connect to database: $DBI::errstr";
	$sth = $dbh->prepare("insert into custdetails(name,address) values(?,?)");
	$sth->execute($name,$address);
}

sub showDB {
	my $dbhost='127.0.0.1'; my $dbport=3306;
	my $dsn="DBI:mysql:dbtest;host=$dbhost;port=$dbport";
	$dbh = DBI->connect($dsn, 'dbtestuser', 'dbpassword'
			) || die "Could not connect to database: $DBI::errstr";
	$sth = $dbh->prepare("select * from custdetails");
	$sth->execute();
	
	my $dbstr = '<table class="pure-table pure-table-bordered">' . "\n";
	$dbstr .= "<thead><tr><th>Name</th></th>Address</th></thead>\n";
	$dbstr .= "<tbody>\n";
	while (my $result = $sth->fetchrow_hashref()) {
		$dbstr .= '<tr><td>' . $result->{'name'}  . '</td><td>' . $result->{'address'} . "</td></tr>\n";
	}
	$dbstr .= '</tbody>';
	return $dbstr;
}
