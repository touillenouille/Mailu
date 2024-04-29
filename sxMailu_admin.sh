#!/bin/sh

VERSION=local
WORKDIR=/home/app/admin
WORKBASE=/root/Mailu/core/admin
#set -euxo pipefail
apt install mariadb-plugin-connect postgresql #mariadb-connector-c postgresql-libs libressl 

mkdir ${WORKDIR}
#COPY --from=assets /work/static/ ./mailu/static/
cp -r /root/Mailu/setup/static/ ${WORKDIR}/mailu/

cp ${WORKBASE}/audit.py ${WORKDIR}
cp ${WORKBASE}/start.py ${WORKDIR}

cp -r ${WORKBASE}/migrations/ ${WORKDIR}

cp -r ${WORKBASE}/mailu/ ${WORKDIR}/
#set -euxo pipefail \
/home/app/venv/bin/pybabel compile -d ${WORKDIR}/mailu/translations

echo $VERSION >/version

#EXPOSE 8080/tcp
#HEALTHCHECK CMD curl -skfLo /dev/null http://localhost:8080/ping

mkdir /home/app/data
mkdir /home/app/dkim

echo 'export FLASK_APP=mailu' >> /etc/profile.d/mailu.sh

source /etc/profile.d/mailu.sh
source /home/app/venv/bin/activate 

cd ${WORKDIR}
python start.py
