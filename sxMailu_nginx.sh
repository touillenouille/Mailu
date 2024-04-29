#!/bin/bash

WORKDIR="/home/app/nginx"
BASEDIR="/root/Mailu/core/nginx"

if [[ 'ls ${WORKDIR}' ]]; then
	mkdir ${WORKDIR}
fi

cp -r ${BASEDIR}/static/ ${WORKDIR}

#set -euxo pipefail
gzip -k9 -y ${WORKDIR}/static/*.ico ${WORKDIR}/static/*.txt
chmod a+rX-w -R ${WORKDIR}/static


#ARG VERSION
#LABEL version=$VERSION

apt install -y certbot nginx libnginx-mod-http-brotli* libnginx-mod-mail openssl

#mkdir -p /etc/apt/keyrings; curl https://repo.dovecot.org/DOVECOT-REPO-GPG | gpg --import
#gpg --export ED409DA1 > /etc/apt/keyrings/dovecot.gpg

#echo 'deb [signed-by=/etc/apt/keyrings/dovecot.gpg] https://repo.dovecot.org/ce-2.3-latest/debian/bullseye bullseye main' > /etc/apt/sources.list.d/dovecot.list

#apt update

apt install -y dovecot-core dovecot-lmtpd dovecot-pop3d dovecot-submissiond #dovecot-lua dovecot-pigeonhole-plugin

cp -r ${BASEDIR}/conf/ ${WORKDIR}
cp ${BASEDIR}/*.py ${WORKDIR}
mkdir ${WORKDIR}/dovecot_conf
cp ${BASEDIR}/dovecot/proxy.conf ${BASEDIR}/dovecot/login.lua ${WORKDIR}/dovecot_conf/

#echo $VERSION >/version

#EXPOSE 80/tcp 443/tcp 110/tcp 143/tcp 465/tcp 587/tcp 993/tcp 995/tcp 25/tcp 4190/tcp
# EXPOSE 10025/tcp 10143/tcp 14190/tcp
#HEALTHCHECK --start-period=60s CMD curl -skfLo /dev/null http://127.0.0.1:10204/health && kill -0 `cat /run/dovecot/master.pid`

mkdir /home/app/certs
mkdir /home/app/overrides

cd ${WORKDIR}
source /home/app/venv/bin/activate
python3 start.py
