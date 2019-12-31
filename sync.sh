#!/bin/sh

set -e

# Sync
cp ./README.md ./public/README.md

cd ./public

wget -O ./GeoLite2-Country.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${LICENSE_KEY}&suffix=tar.gz"
tar zxvf ./GeoLite2-Country.tar.gz -C .

VERSION=$(ls | grep 'GeoLite2-Country_' | sed "s|GeoLite2-Country_||g" | tr -d '\n')
DATE="$(echo $(TZ=UTC-8 date '+%Y--%m--%d%%20%H%%3A%M%%3A%S'))"

mv ./GeoLite2-Country_*/GeoLite2-Country.mmdb ./Country.mmdb
rm -rf ./GeoLite2-Country_*
echo $VERSION > version

sed -i "s|## Sync Status|## Sync Status\n\n![](https://img.shields.io/badge/Version-$VERSION-2f8bff.svg?style=for-the-badge)\n![](https://img.shields.io/badge/Last%20Sync-$DATE-blue.svg?style=for-the-badge)|g" README.md

cd ..

# Deploy

mkdir ./public-git
cd ./public-git
git init
git config --global push.default matching
git config --global user.email "${GITHUB_EMAIL}"
git config --global user.name "${GITHUB_USER}"
git remote add origin https://${GITHUB_TOKEN}@github.com/clashdev/geolite.clash.dev.git
git checkout -b gh-pages
cp -rf ../public/* ./
git add --all .
DATE="$(echo $(TZ=UTC-8 date '+%Y-%m-%d %H:%M:%S'))"
git commit -m "Synced success at $DATE - $VERSION"
git push --quiet --force origin HEAD:gh-pages
