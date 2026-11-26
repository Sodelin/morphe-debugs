#!/bin/sh
set -eu

verify_app() {
  stock=$1
  clone=$2
  expected=$3
  stock_path=$(adb shell pm path "$stock") || return 2
  case "$stock_path" in
    package:*) ;;
    *) printf 'Missing original package %s\n' "$stock" >&2; return 2 ;;
  esac

  clone_packages=$(adb shell pm list packages "$clone") || return 2
  if ! printf '%s\n' "$clone_packages" | grep -Fxq "package:$clone"; then
    printf 'Missing clone package %s\n' "$clone" >&2
    return 1
  fi
  clone_path=$(adb shell pm path "$clone") || return 2
  case "$clone_path" in
    package:/data/app/*/base.apk) ;;
    *) printf 'Expected one installed base APK for %s\n' "$clone" >&2; return 2 ;;
  esac
  case "$clone_path" in
    *'
'*) printf 'Unexpected split APKs for %s\n' "$clone" >&2; return 2 ;;
  esac

  # Android package-manager paths normally contain no shell metacharacters
  # other than the base64 markers.
  clone_path=${clone_path#package:}
  case "$clone_path" in
    *[!a-zA-Z0-9/~_=.\-]*) printf 'Unexpected APK path for %s\n' "$clone" >&2; return 2 ;;
  esac
  result=$(adb shell sha256sum "$clone_path") || return 2
  actual=${result%% *}
  if [ "$actual" != "$expected" ]; then
    printf 'Installed APK digest mismatch for %s\n' "$clone" >&2
    return 1
  fi
  printf '%s verified; original %s present\n' "$clone" "$stock"
}

if [ "$#" -eq 0 ]; then
  input=
elif [ "$#" -eq 2 ] && [ "$1" = "--install" ]; then
  input=$(realpath "$2")
  local_result=$(sha256sum "$input")
  local_digest=${local_result%% *}
else
  printf 'Usage: sh verify-installed-builds.sh [--install VERIFIED_APK]\n' >&2
  exit 1
fi

while read -r original patched digest <&3; do
  if [ -z "$input" ]; then
    verify_app "$original" "$patched" "$digest"
  elif [ "$digest" = "$local_digest" ]; then
    if verify_app "$original" "$patched" "$digest"; then
      exit 0
    else
      status=$?
      test "$status" -eq 1 || exit "$status"
    fi
    apksigner verify "$input"
    # Android enforces the installed package's signing identity on updates.
    # Never uninstall, clear app data or request a downgrade.
    adb install --streaming -r "$input"
    verify_app "$original" "$patched" "$digest"
    exit 0
  fi
done 3<<'BATCH'
com.discord com.discord.venus 0b56b2e3845800dcc5f8fa377d4e151befc84e5d987248d904457a2fb0895c92
com.reddit.frontpage com.reddit.frontpage.morphe 8ab435348c8508e0affdeefbfe8eef1dedde45a8a2546ce2b6eaf746b25be058
com.google.android.apps.youtube.music com.google.android.apps.youtube.music.debugs 0aad39ad26c0b4047efe9dea4bde1cff160c2732879c113a322f2dca8c31c689
BATCH

if [ -n "$input" ]; then
  printf 'APK does not match a verified build in this batch.\n' >&2
  exit 1
fi
