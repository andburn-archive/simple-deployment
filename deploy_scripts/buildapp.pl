#!/usr/bin/perl

my $dir = $ARGV[0];
my $out_dir = 'html';
my @structure = ('cgi', 'content', 'templates');
my $structre_count = -1;

foreach my $d (@structure) {
	if (-e "$dir/$d") {
		print "$d exists\n";
		$structre_count++;
	}
}

if ($structre_count != $#structure) {
	print "error invalid dir structure in $dir";
	exit 1;
}

# check main template file exists
if (-e "$dir/$structure[2]/main.html") {
	my $template = file_to_string("$dir/$structure[2]/main.html");
	my @content_files = glob("$dir/$structure[1]/*.html");
	foreach my $c (@content_files) {
		my $filename = $1 if $c =~ /([^\/]+)$/;
		my $content = file_to_string($c);
		my $new_content = $template;
		$new_content =~ s/<%CONTENT%>/$content/;
		mkdir "$dir/$out_dir";
		open OFILE, ">$dir/$out_dir/$filename";
		print OFILE $new_content;
		close OFILE;
	}
} else {
	print "error missing template file";
	exit 1;
}

sub file_to_string {
	my $file = shift;
	my $output = '';
	open TFILE, $file or die "error opening $file";
	while (<TFILE>) {
		$output .= $_;
	}
	close TFILE;
	return $output;
}










