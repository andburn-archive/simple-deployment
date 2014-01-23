#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI;

print header
#, start_html("Accept Form");
my $html_output = '';
my $html_content = '';

my $name=param('name');
my $address=param('address');

$html_content .= "<h3>inserting name:$name and address:$address into Database</h3>";
insertDB($name,$address);
$html_content .= "<h3>Showing the contents of the Database</h3>";
showDB();

#print end_html;
open IFILE, 'template.html';
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

print $html_output;

exit;

sub insertDB {
my $name = shift;
my $address =shift;

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
while (my $result = $sth->fetchrow_hashref()) {
        print $result->{'name'}," ",$result->{'address'},"<p>";
}
}
