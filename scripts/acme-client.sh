#!/bin/sh -xu

_script=$(realpath $0)
_base=$(dirname $_script)

. $_base/common.sh

_domains="$_acme/domains.txt"
_www="/export/www/default/acme"
_force=""

if [ $# -gt 0 ]; then
	_force="-F"
fi

cat $_domains | while read _domain _altnames; do
	_crt="$_ssl/$_domain"

	install -d -m 0755 -g wheel -o root -v $_crt

	# cert.pem: server certificate only
	# chain.pem: root and intermediate certificates only
	# fullchain.pem: combination of server, root and intermediate certificates
	# privkey.pem: private key

	# -v: verbose
	# -e: allow expanding the domain list
	# -F: updating the certificate signature
	# -n: create a new 4096-bit RSA account key
	# -N: create a new 4096-bit RSA domain key
	# -C: www challenge directory
	# -f: account private key
	# -k: private key for the domain
	# -c: public certificates directory
	acme-client -v -e -n -N $_force \
		-C $_www -c $_crt \
		-f $_acme/account.pem \
		-k $_crt/privkey.pem \
		$_domain $_altnames

	_rc=$?

	if [ $_rc -eq 0 ]; then
		$_base/acme-deploy.sh $_domain
	elif [ $_rc -eq 2 ]; then
		continue
	else
		exit $_rc
	fi
done
