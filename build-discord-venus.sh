#!/bin/sh
set -eu
cd "$(dirname "$0")"
input=$(realpath "${1:?Usage: sh build-discord-venus.sh ORIGINAL_SPLIT_ARCHIVE [OUTPUT]}")
case "$input" in *.apkm|*.apks|*.xapk) ;; *) echo 'Provide a complete original split archive.' >&2; exit 1;; esac
output=${2:-.cache/discord-venus-expanded.apk}
test ! -e "$output"
printf '%s\n' \
  '5588f69a5f12b868538112b70f6c666171fbed547719980e979af8b811404f8e  .cache/venus-1.20.0.mpp' \
  'e0e49525e1fbe1108d6cfd7398d39e0cd489c58a753e63653c1e8f11a0099757  .cache/morphe-desktop-2.3.0-all.jar' |
  sha256sum -c -
umask 077
python verify-discord-input.py "$input"
scratch=$(mktemp -d .cache/discord-build-XXXXXX)
trap 'rm -rf -- "$scratch"' EXIT
candidate=$scratch/discord.apk
log=$scratch/build.log
if ! java -Xmx1800m -jar .cache/morphe-desktop-2.3.0-all.jar patch \
  -p .cache/venus-1.20.0.mpp --exclusive \
  -e 'Custom branding' -e 'Load full-quality images' \
  -e 'Show file sizes when attaching' -e 'Tap mentions to open profiles' \
  -e 'Custom themes' -e 'Message highlights' \
  -e "Use your phone's emojis" -e "Use your phone's font" \
  -e 'Voice channel options' -e 'Material You colors' -e 'Pastel name colors' \
  -e 'Jump to first message' -e 'Icon packs' -e 'Disable analytics' \
  -e 'Copy profile bios' -e 'Show owner and mod tags' -e 'Fix unknown mentions' \
  -e 'Show device indicators' -e 'Clean channel names' -e 'Venus button on profile bar' \
  -e 'Hide blocked or ignored messages' -e 'Server info' -e 'Edit servers locally' \
  -e 'Anonymous file names' -e 'Favourite any image or video' -e 'Read all button' \
  -e 'Disable advertising identifiers' \
  -o "$candidate" "$input" >"$log" 2>&1; then
  tail -25 "$log" >&2
  exit 1
fi
test "$(grep -c '^INFO: Applied:' "$log")" -eq 27
apksigner verify "$candidate"
test "$(aapt dump badging "$candidate" 2>/dev/null | sed -n "s/^package: name='\([^']*\)'.*/\1/p")" = com.discord.venus
manifest=$(aapt dump xmltree "$candidate" AndroidManifest.xml)
if printf '%s\n' "$manifest" | grep -q 'requiredSplitTypes.*base__'; then
  echo 'Output still requires additional splits.' >&2
  exit 1
fi
# Discord 350.8 declares media projection on this foreground service.
if ! printf '%s\n' "$manifest" | awk '
  /^[[:space:]]*E: / { service = 0 }
  /android:name.*"android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION"/ { permission = 1 }
  /android:name.*"com.discord.foreground_service.ForegroundService"/ { service = 1 }
  service && /android:foregroundServiceType.*0xe1$/ { projection = 1 }
  END { exit !(permission && projection) }
'; then
  echo 'Output is missing the Discord 350.8 screen-capture service configuration.' >&2
  exit 1
fi
mv -n -- "$candidate" "$output"
test ! -e "$candidate"
printf '%s\n' "$output"
