#!/bin/sh
set -eu
cd "$(dirname "$0")"

# Use a caller-supplied stock APK from a trusted local source.
input=$(realpath "${1:?Usage: build-reddit-clone.sh STOCK_APK}")
tools=.cache
output=$tools/reddit-clone.apk
test ! -e "$output"
printf '%s\n' \
  '1c37549274a2b6cf7f2e3e099d9b8cb641880b8a7dac323a95638a06bb4509a9  .cache/patches-2.3.0.mpp' \
  'e0e49525e1fbe1108d6cfd7398d39e0cd489c58a753e63653c1e8f11a0099757  .cache/morphe-desktop-2.3.0-all.jar' |
  sha256sum -c -
apksigner verify "$input"
package_id() {
  aapt dump badging "$1" | sed -n "s/^package: name='\([^']*\)'.*/\1/p"
}
test "$(package_id "$input")" = com.reddit.frontpage
java -Xmx1800m -jar "$tools/morphe-desktop-2.3.0-all.jar" patch \
  -p "$tools/patches-2.3.0.mpp" --exclusive -e 'Clone app' -o "$output" "$input"
apksigner verify "$output"
test "$(package_id "$output")" = com.reddit.frontpage.morphe
printf '%s\n' "$output"
