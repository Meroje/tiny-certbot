#!/usr/bin/env bash
set -xe
DEST="/var/www/letsencrypt"

# 1.prepare request
openssl genrsa 4096 > $DEST/account.key
openssl genrsa 4096 > $DEST/domain.key
openssl dhparam -out $DEST/dhparam.pem 3072
openssl req -new -sha256 -key $DEST/domain.key -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:example.com")) > $DEST/domain.csr

# 2.send request
python $DEST/acme-tiny/acme_tiny.py --account-key $DEST/account.key --csr $DEST/domain.csr --acme-dir $DEST/.well-known/acme-challenge > $DEST/signed.crt

# 3.prepare cert
wget -qO $DEST/intermediate.pem https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem
cat $DEST/signed.crt $DEST/intermediate.pem > $DEST/chained.pem

# 4.reload services
service nginx reload

# 5.cleanup
rm -f $DEST/account.key
