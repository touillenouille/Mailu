export VERSION=local
WORKDIR=/home/app/unbound
BASEDIR=/root/Mailu/optional/unbound

mkdir ${WORKDIR}
#set -euxo pipefail \
apt install dnsutils unbound #bind-tools unbound
curl -so /etc/unbound/root.hints https://www.internic.net/domain/named.cache \
chown root:unbound /etc/unbound \
chmod 775 /etc/unbound \
/usr/sbin/unbound-anchor -a /etc/unbound/trusted-key.key || true

cp ${BASEDIR}/unbound.conf ${WORKDIR}
cp ${BASEDIR}/start.py $WORKDIR


#EXPOSE 53/udp 53/tcp
#HEALTHCHECK CMD dig @127.0.0.1 || exit 1

cd ${WORKDIR}
./start.py
