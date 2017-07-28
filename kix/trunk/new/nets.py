#! /usr/bin/python
# $Id: nets.py 278 2014-06-12 00:18:14Z JECottrell3@gmail.com $
#################################################################
#	Default Network Object
#################################################################

class Net(object):

	# Class Variables: defaults

	name	= 'noname'
	ether	= 'eth0'
	uther	= None
	proto	= 'dhcp'
	host	= None
	work	= None
	addr	= None
	gate	= None
	mask	= '255.255.255.0'	# /24 = Class C
	dns	= None			# DIY

	# Initialize: store hostname if given

	def __init__(self, host=None, addr=None):
		self.host = host
		self.addr = addr	# for inheritance?

	# Represent: return kickstart network line

	def __repr__(self):
#		rep = 'network --noipv6 --device=' + self.ether
		rep = 'network --device=' + self.ether
		rep = rep + ' --onboot=yes --bootproto=' + self.proto

		if self.host:
			rep = rep + ' --hostname='+ self.host

		if self.addr:
			#print self.work, self.addr, self.mask
			rep = rep + ' --ip='      + self.work + self.addr
			rep = rep + ' --gateway=' + self.work + self.gate
			rep = rep + ' --netmask=' + self.mask

		if self.dns:
			rep = rep + ' --nameserver=' + self.dns
		else:	rep = rep + ' --nodns'

		return '\n'.join([
			'#### BEG Net ' + self.name + ' ####',
			rep,
			'#### END Net ' + self.name + ' ####',
			''
		])

#################################################################

#################################################################
#	DHCP is the Default
#################################################################

class Dhcp(Net):
	def __init__(self, host=None, addr=None):
		self.site = 'dhcp'
		self.host = host
		self.addr = addr
		if host: self.name = 'dhcp'

#################################################################
#	RBJ Home Network
#################################################################

class HomerJ(Net):
	def __init__(self, host, addr, net=None):
		self.site = 'home'
		self.host = host
		self.addr = str(addr)
		self.name = 'homerJ'
		self.uther = net
		self.proto='static'
		self.work = '1.2.3.'
		self.gate = '4'

#################################################################
#	Zimmerman Net 192.168.{50,51,17}
#################################################################

class Zai(Net):
	def __init__(self, host, addr):
		self.site = 'zai'
		self.host = host
		self.addr = addr
		self.name = 'zai'
		self.uther = 'em1'
		self.proto='static'
		self.mask = '255.255.255.0'	# /22
		self.work = '192.168.'		# 15[6789]
		self.gate = '50.1'		# highest
		self.dns  = '192.168.17.36'	# also 17.15

#################################################################
#	SEAS Net 15[6789]
#################################################################

class Seas156(Net):
	def __init__(self, host, addr):
		self.site = 'seas'
		self.host = host
		self.addr = addr
		self.name = 'seas156'
		self.proto='static'
		self.mask = '255.255.252.0'	# /22
		self.work = '128.164.'		# 15[6789]
		self.gate = '159.254'		# highest
		self.dns  = '128.164.141.12'	# ns2.gwu.edu

#################################################################

#################################################################
#	SEAS Net 219
#################################################################

class Seas219(Net):
	def __init__(self, host, addr):
		self.site = 'seas'
		self.host = host
		self.addr = addr
		self.name = 'seas219'
		self.ether='eth0'
		self.proto='static'
		self.mask = '255.255.255.128'	# /25
		self.work = '128.164.219.'	# 0-127
		self.gate = '1'			# lowest
		self.dns  = '128.164.219.82'	# kick

#################################################################
#	RACK 5 uses ETH2 on Net 219
#################################################################

class Rack5(Seas219):
	def __init__(self, host, addr):
		self.site = 'seas'
		super(Rack5, self).__init__(host, addr)
		self.ether='eth2'
		self.name = 'rack5'

#################################################################
#	UNIT TEST
#################################################################

if __name__ == '__main__':

	print Dhcp(None)	#                     print `n`
	print Dhcp('DhCp')	#                   print `n`
	print Seas156('SEAS-156',	'157.158')	# print `n`
	print Seas219('vdi02',	'3'      )	# print `n`
	print   Rack5('node27',	'27'     )	# print `n`
	print HomerJ('yoyo',	'45'     )	# print `n`

#################################################################
