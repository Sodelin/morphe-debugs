#!/bin/sh
set -eu
input=$(realpath "${1:?Usage: sh build-reddit-debugs.sh ORIGINAL_XAPK [OUTPUT]}")
cd "$(dirname "$0")"
output=${2:-.cache/reddit-debugs-arm64.apk}
test ! -e "$output"
umask 077
cli=.cache/morphe-desktop-2.3.0-all.jar
mpp=.cache/patches-2.3.0.mpp
debugs=.cache/debugs-0.1.0.mpp
printf '%s\n' \
  "e0e49525e1fbe1108d6cfd7398d39e0cd489c58a753e63653c1e8f11a0099757  $cli" \
  "1c37549274a2b6cf7f2e3e099d9b8cb641880b8a7dac323a95638a06bb4509a9  $mpp" \
  "a70bafe5e3853095412ed502271e0e488c800113064cb6785cd93766c0bb32f0  $debugs" |
  sha256sum -c -
test "$(sha256sum "$input" | cut -d ' ' -f 1)" = 918f78dd1cd5dbefe808d5dbe9c69338b5cbf23075cd40939ae6e315530e74d8
scratch=$(mktemp -d .cache/reddit-build-XXXXXX)
trap 'rm -rf -- "$scratch"' EXIT
if ! java -Xmx1800m -jar "$cli" patch -p "$mpp" --exclusive \
 -e 'Clone app' -e 'Start as guest' -e 'Keep feed position' -e 'Customize post layout' \
 -e 'Hide navigation buttons' -e 'Full width feed media' -e 'Feed media max height' \
 -e 'Media viewer black background' -e 'Media viewer fade' -e 'Remember collapsed comments' \
 -e 'Copy text' -e 'Show flairs in home feed' -e 'High quality avatars' -e 'Sanitize sharing links' \
 -e 'Custom font' -e 'Force system font' -e 'Hide Ask button' -e 'Hide communities shelf' \
 -e 'Hide media viewer components' -e 'Disable modern home' -e 'Disable screenshot popup' \
 -e 'Hide Reddit search' -e 'Hide sidebar components' -e 'Hide Trending shelves' \
 -e 'App icon' -e 'Download location' -e 'Open links externally' -e 'Redgifs audio' \
 -o "$scratch/clone.apk" "$input" >"$scratch/clone.log" 2>&1; then
  tail -24 "$scratch/clone.log" >&2
  exit 1
fi
test "$(grep -c '^INFO: Applied:' "$scratch/clone.log")" -eq 28
java -Xmx1800m -jar "$cli" patch -p "$debugs" --exclusive -e 'Debugs launcher label' \
 -o "$scratch/labeled.apk" "$scratch/clone.apk"
apksigner verify "$scratch/labeled.apk"
aapt dump badging "$scratch/labeled.apk" | awk "
 /^package: name='com\.reddit\.frontpage\.morphe'/ {p=1}
 /^application-label:'Reddit Debugs'/ {l=1}
 END {exit !(p && l)}
"
unzip -Z1 "$scratch/labeled.apk" | awk '/^lib\/arm64-v8a\// {n++} END {exit !n}'
mv -n -- "$scratch/labeled.apk" "$output"
test ! -e "$scratch/labeled.apk"
printf '%s\n' "$output"
