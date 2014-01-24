function testCgiScript {
	# start mysql
	/etc/init.d/mysql start

	# create database
	cat <<FINISH | mysql -uroot -ppassword
	drop database if exists dbtest;
	CREATE DATABASE dbtest;
	GRANT ALL PRIVILEGES ON dbtest.* TO dbtestuser@localhost IDENTIFIED BY 'dbpassword';
	use dbtest;
	drop table if exists custdetails;
	create table if not exists custdetails (
	name         VARCHAR(30)   NOT NULL DEFAULT '',
	address         VARCHAR(30)   NOT NULL DEFAULT ''
	);
	insert into custdetails (name,address) values ('John Smith','Street Address'); select * from custdetails;
	FINISH

	# sdfs
	perl -w accept_form.pl name="Bill Jones" address="No fixed abode"
}