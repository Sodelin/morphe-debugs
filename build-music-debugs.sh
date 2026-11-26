#!/bin/sh
set -eu
cd "$(dirname "$0")"
input=$(realpath "${1:?Usage: sh build-music-debugs.sh ORIGINAL_9.30.53_APK [OUTPUT]}")
output=${2:-.cache/music-debugs.apk}
test ! -e "$output"
umask 077
cli=.cache/morphe-desktop-2.3.0-all.jar
mpp=.cache/patches-2.3.0.mpp
printf '%s\n' \
  "e0e49525e1fbe1108d6cfd7398d39e0cd489c58a753e63653c1e8f11a0099757  $cli" \
  "1c37549274a2b6cf7f2e3e099d9b8cb641880b8a7dac323a95638a06bb4509a9  $mpp" |
  sha256sum -c -
certs=$(apksigner verify --print-certs "$input")
printf '%s\n' "$certs" | grep -Eq '^V3\.1 Signer: .*certificate SHA-256 digest: 6a2f65ec694a6a632acdcb5080912a565f903d4b8d83f0eb8e44fbdf2660d8e1$'
aapt dump badging "$input" | grep -Eq "^package: name='com\.google\.android\.apps\.youtube\.music' versionCode='93053240' "
scratch=$(mktemp -d .cache/music-build-XXXXXX)
trap 'rm -rf -- "$scratch"' EXIT
log=$scratch/build.log
candidate=$scratch/music.apk
if ! java -Xmx1800m -jar "$cli" patch -p "$mpp" --exclusive \
  -e 'Clone app' -OpackageName=com.google.android.apps.youtube.music.debugs \
  -e 'Custom branding' '-OcustomName=Music Debugs' -e 'GmsCore support' \
  -e 'Crossfade' -e 'A-B loop' -e 'Remember repeat state' -e 'Remember shuffle state' \
  -e 'Navigation bar' -e 'Change miniplayer color' -e 'Miniplayer previous and next buttons' \
  -e 'Theme' -e 'Force original audio' -e 'Media notification controls' \
  -e 'Sanitize sharing links' -e 'Open system share sheet' -e 'Playback speed' \
  -o "$candidate" "$input" >"$log" 2>&1; then
  tail -25 "$log" >&2
  exit 1
fi
grep '^INFO: Applied:' "$log"
test "$(grep -c '^INFO: Applied:' "$log")" -eq 16
apksigner verify "$candidate"
aapt dump badging "$candidate" | grep -Eq "^package: name='com\.google\.android\.apps\.youtube\.music\.debugs' versionCode='93053240' "
mv -n -- "$candidate" "$output"
test ! -e "$candidate"
printf '%s\n' "$output"
