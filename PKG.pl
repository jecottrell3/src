#! /usr/bin/perl

use strict;

use PKG;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

#################################################################
#	Build Package Database: PKG.db
#################################################################

sub main
{
	my $db = "PKG.db";
	my $path = shift || 'RPMS' ;
	my $count = 0;

	my $t1 = time;
	map { PKG->new($_) and ++$count; }  glob "$path/*.rpm";
	my $t2 = time;

	open DB, ">$db" or die;
	
	warn "Dumping\n";
	select DB;	PKG->dump;
	close  DB;
	my $t3 = time;
	warn "Reading\n";
	require $db;
	my $t4 = time;
	select STDOUT;	PKG->dump;
	my $t5 = time;
	printf("%d Packages, converted %d, dumped %d, read %d, shown %d\n",
		$count, $t2 - $t1, $t3 - $t2, $t4 - $t3, $t5 - $t4);
}

main(@ARGV);
