#!/bin/sh
# SPDX-FileCopyrightText: 2026 MyStickCloud
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Installs and configures the Euro-Office connector so documents open in the
# office service from docker-compose.yml. Runs on every container start; safe to re-run.
set -eu

occ() {
	php /var/www/html/occ "$@"
}

if ! occ status --output=json | grep -q '"installed":true'; then
	echo "MyStickCloud: Nextcloud not installed yet, skipping office setup"
	exit 0
fi

if [ -z "${OFFICE_URL:-}" ] || [ -z "${OFFICE_JWT_SECRET:-}" ]; then
	echo "MyStickCloud: OFFICE_URL or OFFICE_JWT_SECRET not set, skipping office setup"
	exit 0
fi

version="${EUROOFFICE_CONNECTOR_VERSION:-11.0.6}"
app_dir=/var/www/html/custom_apps/eurooffice

installed=$(sed -n 's:.*<version>\(.*\)</version>.*:\1:p' "$app_dir/appinfo/info.xml" 2>/dev/null | head -n 1)
if [ "$installed" != "$version" ]; then
	echo "MyStickCloud: installing Euro-Office connector $version"
	tmp=$(mktemp -d)
	curl -fsSL -o "$tmp/eurooffice.tar.gz" \
		"https://github.com/Euro-Office/eurooffice-nextcloud/releases/download/v$version/eurooffice.tar.gz"
	tar -xzf "$tmp/eurooffice.tar.gz" -C "$tmp"
	rm -rf "$app_dir"
	mv "$tmp/eurooffice" "$app_dir"
	rm -rf "$tmp"
fi

occ app:enable eurooffice

# The office service calls back into Nextcloud as http://app/
occ config:system:set trusted_domains 20 --value=app

occ config:app:set eurooffice DocumentServerUrl --value="$OFFICE_URL"
occ config:app:set eurooffice DocumentServerInternalUrl --value="http://office/"
occ config:app:set eurooffice StorageUrl --value="http://app/"
occ config:app:set eurooffice jwt_secret --value="$OFFICE_JWT_SECRET" >/dev/null

echo "MyStickCloud: office configured"
