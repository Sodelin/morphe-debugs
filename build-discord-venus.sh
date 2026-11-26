#!/bin/sh
set -eu
cd "$(dirname "$0")"
input=$(realpath "${1:?Usage: sh build-discord-venus.sh ORIGINAL_SPLIT_ARCHIVE}")
case "$input" in *.apkm|*.apks|*.xapk) ;; *) echo 'Provide a complete original split archive.' >&2; exit 1;; esac
output=.cache/discord-venus-batch.apk
test ! -e "$output"
printf '%s\n' \
  '5588f69a5f12b868538112b70f6c666171fbed547719980e979af8b811404f8e  .cache/venus-1.20.0.mpp' \
  'e0e49525e1fbe1108d6cfd7398d39e0cd489c58a753e63653c1e8f11a0099757  .cache/morphe-desktop-2.3.0-all.jar' |
  sha256sum -c -
umask 077
python verify-discord-input.py "$input"
java -Xmx1800m -jar .cache/morphe-desktop-2.3.0-all.jar patch \
  -p .cache/venus-1.20.0.mpp --exclusive \
  -e 'Custom branding' -e 'Load full-quality images' \
  -e 'Show file sizes when attaching' -e 'Tap mentions to open profiles' \
  -e 'Custom themes' -e 'Message highlights' \
  -e "Use your phone's emojis" -e "Use your phone's font" \
  -e 'Voice channel options' -e 'Material You colors' -e 'Pastel name colors' \
  -e 'Jump to first message' -e 'Icon packs' -e 'Disable analytics' \
  -e 'Disable advertising identifiers' --keystore .cache/discord-venus-signing.keystore \
  -o "$output" "$input"
apksigner verify "$output"
test "$(aapt dump badging "$output" 2>/dev/null | sed -n "s/^package: name='\([^']*\)'.*/\1/p")" = com.discord.venus
manifest=$(aapt dump xmltree "$output" AndroidManifest.xml)
if printf '%s\n' "$manifest" | grep -q 'requiredSplitTypes.*base__'; then
  echo 'Output still requires additional splits.' >&2
  exit 1
fi
printf '%s\n' "$output"
