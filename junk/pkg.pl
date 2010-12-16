#! /usr/bin/perl

#################################################################
#	The PKG Object
#################################################################

package PKG;

use strict;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

#################################################################
# Class Variables
#################################################################

#our @All = ();		# all packages # needed?
our %Named = ();	# name    -> pkg
our %Owner = ();	# file    -> pkg
our %Provider = ();	# feature -> pkg

#################################################################
# Class Function: find
#################################################################

sub find
{
	my ($class, $name) = @_;
	my $pkg = $Named{$name};
	return $pkg if $pkg;

	for $pkg (values %Named)
	{
		return $pkg if $pkg->{file} eq $name;
		return $pkg if $pkg->{pkg}  eq $name;
	}
	
	
}

#################################################################
# Class Function: dump
#################################################################

sub dump
{
#	print(Data::Dumper->Dump([ \@PKG::All      ], [ '*PKG::All'      ]));
	print(Data::Dumper->Dump([ \%PKG::Named    ], [ '*PKG::Named'    ]));
	print(Data::Dumper->Dump([ \%PKG::Owner    ], [ '*PKG::Owner'    ]));
	print(Data::Dumper->Dump([ \%PKG::Provider ], [ '*PKG::Provider' ]));
}

#################################################################
# Accessor Functions
#################################################################

sub name
{
	my $self = shift;
	$self->{name};
}

#################################################################
# Initialize Name/Version/Release/Arch
#	format: /path/name-release-version.arch.rpm
#################################################################

sub initname
{
	my $self = shift;

	my @file = split(/\//, $self->{pkg});
	$self->{file} = pop(@file);		# last is file
	$self->{dir}  = join('/', @file);	# others are dirs

	my @name = split(/-/, $self->{file});
	$self->{rel} = pop(@name);		# last is release
	$self->{ver} = pop(@name);		# next is version
	my $name = join('-', @name);		# rest is name
	$self->{name} = $name;

	$PKG::Named{$name} = $self;
#	push(@PKG::All, $self);

	my @arch = split(/\./, $self->{rel});
	pop @arch ; # nuke .rpm suffix		# last is '.rpm'
	$self->{arch} = pop(@arch);		# next is arch
	$self->{rel} = join('.', @arch);	# rest is release

}

#################################################################
# Initialize Provides List
#################################################################

sub initpro
{
	my $self = shift;
	my $name = $self->{name};
	my ($key, $val);

	chomp(my @pro  = `rpm -qp --provides $self->{pkg}`);
	$self->{prx} = [ @pro ];
	$self->{pro} = { };
	for (@pro)
	{
		s/ //g;				# nuke whitespace
		next if /[()]/;			# parens evil
		$val = $key = $_;
		$key =~ s/[<=>()].*//;		# find key
		$val =~ s/.*[<=>()]//;		# find value

		$self->{pro}{$key} = $val;	# store
		$Pkg::Provider{$key} = $name;
	}
}

#################################################################
# Initialize Require List
#################################################################

sub initreq
{
	my $self = shift;
	my ($key, $val);

	chomp(my @req  = `rpm -qp --requires $self->{pkg}`);
	$self->{rex} = [ @req ];
	$self->{req} = { };
	for (@req)
	{
		s/ //g;
		next if /[()]/;
		$val = $key = $_;
		$key =~ s/[<=>()].*//;
		$val =~ s/.*[<=>()]//;

		$self->{req}{$key} = $val;
	}
}

#################################################################
# Initialize File List
#################################################################

sub initlist
{
	my $self = shift;
	my $name = $self->{name};
	chomp(my @list = `rpm -qp --list     $self->{pkg}`);
	map	{ s/ //g; }		@list;
	map	{ $Owner{$_} = $name; }	@list;
}

#################################################################
# Constructor
#################################################################

sub new
{
	my $class = shift;
	my $pkg   = shift;

warn "new($class, $pkg)\n" ;

	warn("ERROR: Not a Package File: $pkg\n") && return undef 
		unless ($pkg =~ /\.rpm$/);

	my $self = {
		pkg	=> $pkg,
		line	=> 0,
		lvl	=> 0,
	};

#	push @All, $self;

	bless $self, $class;

	$self->initname;
	$self->initpro;
	$self->initreq;
	$self->initlist;

	return $self ;
}

#################################################################
1;
