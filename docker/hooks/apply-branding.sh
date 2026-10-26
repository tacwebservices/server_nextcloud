#!/bin/sh
# SPDX-FileCopyrightText: 2026 MyStickCloud
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Applies the MyStickCloud branding on every container start. Safe to re-run.
set -eu

occ() {
	php /var/www/html/occ "$@"
}

if ! occ status --output=json | grep -q '"installed":true'; then
	echo "MyStickCloud: Nextcloud not installed yet, skipping branding"
	exit 0
fi

img=/var/www/html/themes/mystickcloud/core/img

occ config:system:set theme --value=mystickcloud
occ app:enable theming

occ theming:config name "MyStickCloud"
occ theming:config slogan "Your USB stick, in the cloud."
occ theming:config url "https://mystickcloud.com"
occ theming:config primary_color "#1E5EFF"
occ theming:config background_color "#0B1F3A"

occ theming:config logo "$img/logo-icon.png"
occ theming:config logoheader "$img/logo-white.png"
occ theming:config favicon "$img/favicon-512.png"
occ theming:config background "$img/background.jpg"

# Remove Nextcloud promotion, news and help links shown to users
for app in firstrunwizard nextcloud_announcements privacy support survey_client; do
	occ app:disable "$app" || true
done
occ config:system:set knowledgebaseenabled --value=false --type=boolean
occ config:system:set simpleSignUpLink.shown --value=false --type=boolean

# "Get the apps" links point to the MyStickCloud website instead of the Nextcloud stores
apps_url="${MYSTICKCLOUD_APPS_URL:-https://mystickcloud.com}"
for key in customclient_desktop customclient_android customclient_ios customclient_fdroid; do
	occ config:system:set "$key" --value="$apps_url"
done

echo "MyStickCloud: branding applied"
