#!/bin/sh
set -eu

verify_app() {
  stock=$1
  clone=$2
  expected=$3
  stock_path=$(adb shell pm path "$stock")
  case "$stock_path" in
    package:*) ;;
    *) printf 'Missing original package %s\n' "$stock" >&2; return 1 ;;
  esac

  clone_path=$(adb shell pm path "$clone")
  case "$clone_path" in
    package:/data/app/*/base.apk) ;;
    *) printf 'Expected one installed base APK for %s\n' "$clone" >&2; return 1 ;;
  esac
  case "$clone_path" in
    *'
'*) printf 'Unexpected split APKs for %s\n' "$clone" >&2; return 1 ;;
  esac

  # Android package-manager paths normally contain no shell metacharacters
  # other than the base64 markers.
  clone_path=${clone_path#package:}
  case "$clone_path" in
    *[!a-zA-Z0-9/~_=.\-]*) printf 'Unexpected APK path for %s\n' "$clone" >&2; return 1 ;;
  esac
  result=$(adb shell sha256sum "$clone_path")
  actual=${result%% *}
  if [ "$actual" != "$expected" ]; then
    printf 'Installed APK digest mismatch for %s\n' "$clone" >&2
    return 1
  fi
  printf '%s verified; original %s present\n' "$clone" "$stock"
}

verify_app com.discord com.discord.venus \
  0b56b2e3845800dcc5f8fa377d4e151befc84e5d987248d904457a2fb0895c92
verify_app com.reddit.frontpage com.reddit.frontpage.morphe \
  8ab435348c8508e0affdeefbfe8eef1dedde45a8a2546ce2b6eaf746b25be058
verify_app com.google.android.apps.youtube.music com.google.android.apps.youtube.music.debugs \
  0aad39ad26c0b4047efe9dea4bde1cff160c2732879c113a322f2dca8c31c689
