drop database if exists dbtest;
CREATE DATABASE dbtest;
GRANT ALL PRIVILEGES ON dbtest.* TO dbtestuser@localhost IDENTIFIED BY 'dbpassword';
use dbtest;
drop table if exists custdetails;
create table if not exists custdetails (
	name VARCHAR(30) NOT NULL DEFAULT '',
	address VARCHAR(30) NOT NULL DEFAULT ''
);
insert into custdetails (name,address) values ('John Smith','Street Address'); select * from custdetails;
