#!/bin/sh
set -eu
cd "$(dirname "$0")"
cli=.cache/morphe-desktop-2.3.0-all.jar
printf '%s  %s\n' e0e49525e1fbe1108d6cfd7398d39e0cd489c58a753e63653c1e8f11a0099757 "$cli" | sha256sum -c -
classes=$(mktemp -d .cache/debugs-XXXXXX)
trap 'rm -r -- "$classes"' EXIT
javac --release 8 -cp "$cli" -d "$classes" patches/src/main/java/app/debugs/patches/RedditLauncherPatch.java
jar cfm .cache/debugs-0.1.0.mpp patches/bundle.mf -C "$classes" .
java -jar "$cli" list-patches --patches=.cache/debugs-0.1.0.mpp
