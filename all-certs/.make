#! /usr/bin/make -f
MAKE=/usr/bin/make
SHELL=/bin/sh

NSS=/etc/pki/nssdb
DOD=/etc/pki/ALL
P7B1=AllCerts.p7b
P7B2=MacAllRootCerts.p7b
P7B3=RootCert5.cer
URL=https://militarycac.com/maccerts
PEMS=All.pems
R4C=DoD_Root_CA_4.cert

help:
	: 
	: get		Download AllCerts Bundle from MilitaryCAC
	: cvt		Unpack P7B to PEM certs
	: split		Split and rename certs
	: add		Add certs to NSS Database
	: all		All of the Above
	:
	: save		Save Everything
	: init		Initialize Cert Database
	: install	Save, Init, Fix, Install
	:
	: list		List Certs
	: clean		Remove Everything
	: every		Clean + Install
	: del		Del certs in NSS Database

all:	add

get:	${P7B1}
${P7B1}:
	: GET: download cert bundle from DISA
	curl "${URL}/{${P7B1},${P7B2},${P7B3}}" -O

cvt:	${PEMS}
${PEMS}:${P7B1}
	: CVT: convert PKCS7 bundle to PEM bundle
	openssl pkcs7 -in ${P7B1} -inform DER -print_certs  > $@
	openssl pkcs7 -in ${P7B2} -inform DER -print_certs >> $@
	openssl x509  -in ${P7B3} -inform DER -out DoD_Root_CA_5.cert

split:	${R4C}
${R4C}:	${PEMS}
	: SPLIT: split PEM bundle to Cert files
	./.split ${PEMS}
	

init:	${R4C}
	: INIT: set up NSSDB
	sudo rm -f ${NSS}/*
	sudo certutil -N --empty-password -d sql:${NSS}
	sudo certutil -N --empty-password -d dbm:${NSS}

fix:
	: FIX: selinux context and file permissions
	sudo fixfiles -F restore ${NSS}
	sudo chmod -R a+r ${NSS}

list:
	sudo certutil -L -d sql:${NSS} | sort
	sudo certutil -L -d dbm:${NSS} | sort

add:	${R4C}
	: ADD: generate add and del scripts
	./.add ${NSS}

del:	${R4C}
	: DEL: generate add and del scripts
	./.add ${NSS}
	: sudo sh -x $@

save:
	: SAVE NSSDB
	-(cd ${NSS}; SAVE=.$$(date +%F.%T); \
	sudo mkdir -p $$SAVE; sudo mv -f * $$SAVE)

install: add save init fix
	: INSTALL: actually add the certs
	sudo sh -x add

clean:
	: CLEAN
	-rm -rf *

every:	clean install

# END
