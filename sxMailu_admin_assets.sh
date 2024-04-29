WORKBASE=/root/Mailu/core/admin/assets
#WORKDIR="/work"
WORKDIR=/home/app/admin

cp ${WORKBASE}/package.json ${WORKDIR}/
cd ${WORKDIR}

#RUN set -euxo pipefail \
apt install nodejs npm -y
npm config set update-notifier false
echo "#!/bin/sh" >/usr/local/bin/husky
chmod +x /usr/local/bin/husky
npm install --no-audit --no-fund
sed -i 's/#007bff/#55a5d9/' node_modules/admin-lte/build/scss/_bootstrap-variables.scss
mkdir assets
for l in ca da de:de-DE en:en-GB es:es-ES eu fa fr:fr-FR he hu is it:it-IT ja nb_NO:no-NB nl:nl-NL pl pt:pt-PT ru sv:sv-SE uk zh zh_TW:zh-HANT; do
      cp node_modules/datatables.net-plugins/i18n/${l#*:}.json ${WORKDIR}/assets/${l%:*}.json;
    done

cp -r ${WORKBASE}/assets/ ${WORKDIR}/assets/

cp ${WORKBASE}/webpack.config.js ${WOKDIR}

#RUN set -euxo pipefail \
node_modules/.bin/webpack-cli --color
