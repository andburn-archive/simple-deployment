function testCgiScript {
	# start mysql
	/etc/init.d/mysql start

	# create database
	mysql -uroot -ppassword < setupdb.sql

	# sdfs
	perl -w apache/cgi-bin/accept_form.pl name="Bill Jones" address="No fixed abode"
}