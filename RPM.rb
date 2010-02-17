#! /usr/bin/ruby

class RPM

#################################################################
#	Class Variables
#################################################################

@@DB = "RPM.db"	# database
@@Named = { :namedKey => 'namedVal' }	# name    -> pkg
@@Owner = { :ownerKey => 'ownerVal' }	# file    -> name
@@Giver = { :giverKey => 'giverVal' }	# feature -> name

#################################################################
#	Class Method: find
#################################################################

def find
end

#################################################################
#	Class Method: dump
#################################################################

def dump
	puts "class RPM"
	puts "@@DB = "
	p     @@DB
	puts "@@Named = "
	p     @@Named
	puts "@@Owner = "
	p     @@Owner
	puts "@@Giver = "
	p     @@Giver
	puts "end"
end

#################################################################
#	Constructor
#################################################################

def initialize(rpm)

	@dir  = '.'
	@file = @rpm = rpm

	pos = rpm.rindex(?/)
	if (pos > 0) then
		@dir  = rpm[0 ... pos]
		@file = rpm[1+pos .. -1]
	end

	@@Named[@file] = self
end

#################################################################
#	Constructor Helper: initpro
#################################################################

def initpro
end

#################################################################
#	Constructor Helper: initreq
#################################################################

def initreq
end

#################################################################
#	Constructor Helper: initlist
#################################################################

def initlist
end

#################################################################

end

rpm = nil

ARGV.each do |arg|
	rpm = RPM.new(arg)
end

rpm.dump

