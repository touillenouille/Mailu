#/bin/sh

MAILU_GID=2000
MAILU_UID=2000

#Base
set -euxo pipefail

echo "add user and gourp"
if [ ! $(getent group mailu) ]; then
	groupadd --gid "${MAILU_GID}" mailu
	useradd --uid "${MAILU_UID}" --gid "${MAILU_GID}" -m --home-dir /home/app --comment "mailu app" --shell /bin/bash mailu
fi

echo "install dep"
#apt-get update
#apt-get install -y --no-install-recommends bash ca-certificates curl python3 tzdata

if [[ "$(uname -m)" != "x86_64" ]]; then
    apt-get install -y --no-install-recommends hardened-malloc
fi


cd /home/app

MAILU_DEPS=prod
SNUFFLEUPAGUS_VERSION=0.10.0


VIRTUAL_ENV=/home/app/venv

cp /root/Mailu/core/base/requirements-build.txt .

set -euxo pipefail 
apt install python3-venv 
python3 -m venv ${VIRTUAL_ENV} 
${VIRTUAL_ENV}/bin/pip install --no-cache-dir -r requirements-build.txt 
apt -y remove python3-venv 
rm -f /tmp/*.pem


cp /root/Mailu/core/base/requirements-${MAILU_DEPS}.txt .
cp -r /root/Mailu/core/base/libs/ libs/


PATH="${VIRTUAL_ENV}/bin:${PATH}" \
CXXFLAGS="-g -O2 -fdebug-prefix-map=/app=. -fstack-protector-strong -Wformat -Werror=format-security -fstack-clash-protection -fexceptions" \
CFLAGS="-g -O2 -fdebug-prefix-map=/app=. -fstack-protector-strong -Wformat -Werror=format-security -fstack-clash-protection -fexceptions" \
CPPFLAGS="-Wdate-time -D_FORTIFY_SOURCE=2" \
LDFLAGS="-Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now" \
SNUFFLEUPAGUS_URL="https://github.com/jvoisin/snuffleupagus/archive/refs/tags/v${SNUFFLEUPAGUS_VERSION}.tar.gz"

machine="$(uname -m)"
deps="build-essential gcc libffi-dev python3-dev"
[[ "${machine}" != x86_64 ]] && deps="${deps} cargo git libretls-dev mariadb-connector-c-dev postgresql-dev"
apt install -y ${deps}

pip install -r requirements-${MAILU_DEPS}.txt
if [[ '0' == '1' ]]; then
echo "curl de snuff"
curl -sL ${SNUFFLEUPAGUS_URL} | tar xz
cd snuffleupagus-${SNUFFLEUPAGUS_VERSION}
rm -rf src/tests/*php7*/ src/tests/*session*/ src/tests/broken_configuration/ src/tests/*cookie* src/tests/upload_validation/
fi

if [[ '0' == '1' ]]; then
apt install apt-transport-https
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt update

echo "install php8.3"
apt install -y php8.3-dev php8.3-cgi php8.3-simplexml php8.3-xml libpcre3-dev php-pear re2c # php8.3-openssl 

#pecl install vld-beta
fi

#ln -s /usr/bin/phpize83 /usr/bin/phpize
#ln -s /usr/bin/php-config83 /usr/bin/php-config
cd snuffleupagus-${SNUFFLEUPAGUS_VERSION}
make -j $(grep -c processor /proc/cpuinfo) release
cp src/.libs/snuffleupagus.so /usr/lib/php/8.3/
rm -rf /root/.cargo /tmp/*.pem /root/.cache


echo 'export I_KNOW_MY_SETUP_DOESNT_FIT_REQUIREMENTS_AND_WONT_FILE_ISSUES_WITHOUT_PATCHES="1" \
export VIRTUAL_ENV=/home/app/venv \
export PATH="/home/app/venv/bin:${PATH}" \
export ADMIN_ADDRESS="127.0.0.1" \
export FRONT_ADDRESS="127.0.0.1" \
export FTS_ATTACHMENTS_ADDRESS="127.0.0.1" \
export SMTP_ADDRESS="127.0.0.1" \
export IMAP_ADDRESS="127.0.0.1" \
export OLETOOLS_ADDRESS="127.0.0.1" \
export REDIS_ADDRESS="127.0.0.1" \
export ANTIVIRUS_ADDRESS="127.0.0.1" \
export ANTISPAM_ADDRESS="127.0.0.1" \
export WEBMAIL_ADDRESS="127.0.0.1" \
export WEBDAV_ADDRESS="127.0.0.1" ' > /etc/profile.d/mailu.sh

source /etc/profile.d/mailu.sh
