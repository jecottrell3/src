#! /usr/bin/make -f
MAKE=/usr/bin/make
SHELL=/bin/sh

NSS=/etc/pki/nssdb
DOD=/etc/pki/DOD
URL=http://iasecontent.disa.mil/pki-pke/${ZIP}
DIR=Certificates_PKCS7_v5.0u1_DoD
ZIP=${DIR}.zip
P7B=${DIR}/Certificates_PKCS7_v5.0u1_DoD.pem.p7b
PEMS=DOD.pems
R4C=DoD_Root_CA_4.cert

help:
	: zip	Download Cert Bundle from DISA
	: dir	Unzip Cert Bundle
	: pems	Unpack P7B to PEM certs
	: split	Split and rename certs
	: add	Add certs to NSS Database
	: all	All of the Above
	: del	Del certs in NSS Database
	: list	List Certs
	: save	Save Everything
	: clean Remove Everything
	: INIT	Initialize Cert Database ONCE ONLY
	: NUKE	Nuke all Certs in Database

zip:	${ZIP}
dir:	${DIR}
pems:	${PEMS}
split:	${R4C}
all:	add

${ZIP}:
	: download cert bundle from DISA
	wget ${URL}

${DIR}:	${ZIP}
	: unpack zip file
	unzip ${ZIP}

${PEMS}:${DIR}
	: convert PKCS7 bundle to PEM bundle
	openssl pkcs7 -in ${P7B} -print_certs > $@

${R4C}:	${PEMS}
	: split PEM bundle to Cert files
	./.split ${PEMS}

INIT:	${R4C}
	: NOTE: use blank password
	: sudo rm -f ${NSS}/*
	: sudo certutil -N -d sql:${NSS}
	: sudo certutil -N -d dbm:${NSS}

list:
	certutil -L -d sql:${NSS} | sort
	certutil -L -d dbm:${NSS} | sort

add:	${R4C} ALWAYS
	: generate add and del scripts
	./.add ${NSS}
	: sudo sh -x $@

del:	${R4C} ALWAYS
	: generate add and del scripts
	./.add ${NSS}
	: sudo sh -x $@

clean:
	: clean up
	-rm -rf *

save:
	: save everything
	mkdir -p .save
	-mv -f * .save

rest:
	: restore everything
	-cp -f .save/* .

ALWAYS:

