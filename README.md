# Morphe Debugs

Independent patch design and verification batches. Upstream tools and patches are by MorpheApp and their respective contributors. Preserve upstream notices when distributing derivative source.

## Reddit baseline

- [Morphe Desktop v2.3.0](https://github.com/MorpheApp/morphe-desktop/releases/tag/v2.3.0), SHA-256 e0e49525e1fbe1108d6cfd7398d39e0cd489c58a753e63653c1e8f11a0099757.
- [Morphe Patches v2.3.0](https://github.com/MorpheApp/morphe-patches/releases/tag/v2.3.0), SHA-256 1c37549274a2b6cf7f2e3e099d9b8cb641880b8a7dac323a95638a06bb4509a9.
- Both downloads matched the GitHub release asset digests. Java 21 ran the CLI on the phone.
- The installed Reddit 2026.24.0 is a single base APK. The bundle lists it with 30 compatible patches, but the actual five-patch trial aborted. Customize post layout requires Reddit SettingsPatch, which in turn invokes Spoof signature and failed its ApplicationFingerprint match.
- Trial scope: Clone app, Keep feed position, Customize post layout, Hide navigation buttons, and Media viewer black background. No APK was installed. Start the next design batch by checking which UI improvements can be tested without that dependency.

### Background installation baseline

The upstream custom branding name and app icon patches also failed through
the same signature dependency. The independently selected Clone app patch
succeeded for the same stock APK. Android SDK tools verified the signature
and the distinct package ID, `com.reddit.frontpage.morphe`, before the
existing ADB route installed it with streamed install. Both the stock and
clone package were present afterward, and Android resolved the clone's
launcher activity. The clone was not opened and runtime UI, account access
and custom design are unverified. The APK and its signing data stay local.

`build-reddit-clone.sh` reproduces the build with a trusted local Reddit APK
and the pinned assets under `.cache`. It checks the output before any manual
install step. The installed clone is a baseline for future design tests.

## Debugs 0.1.0

This independent resource patch gives the Reddit clone the application
label Reddit Debugs so it can be told apart from stock Reddit. The bundle
compiles against the pinned Morphe Desktop CLI and the CLI lists the patch.
The upstream Clone app patch remains a separate MorpheApp contribution.

Run `sh build-debug-bundle.sh` and apply the resulting bundle to a clone
using `patch -p .cache/debugs-0.1.0.mpp --exclusive -e 'Debugs launcher label'`.
Keep the same signing identity for updates. The patch accepts only the
clone package. The output APK's package ID and app label were checked with
aapt. The bundle is tested in Morphe Desktop; Manager import is unverified.

Android accepted the same-signature update through background ADB.

## Maximum-mods compatibility pass

- Reddit 2026.24.0 with Morphe Patches 2.3.0: 31 selected in a diagnostic
  build, 29 failed, Clone app and Start as guest applied. The partial
  output was not installed. The Debugs label build remains installed.
- YouTube and YouTube Music stock inputs are split APKs, at
  21.47.483-BETA and 9.46.55 respectively. The pinned bundle reports
  117 patches for YouTube 21.30.216 and 56 for Music 9.30.53. Use a
  compatible, trusted input rather than forcing those stock versions.
- Discord: [Venus Patches v1.21.1 by VenusIsJaded](https://github.com/VenusIsJaded/Venus-Patches/releases/tag/v1.21.1)
  is GPL-3.0 and its release bundle matched GitHub's published SHA-256
  ad8f1ef02e7461286abf725b8205660fd187e6ce3fdb06d64a07b75da094bd47.
  The CLI lists 78 patches for Discord 351.11 Stable, while the phone
  has 350.8 Stable. This is a compatibility finding, not a code audit.
  Candidate UI patches include Material You, landscape chat, system
  emojis, double-tap reply and message highlights. Evaluate individual
  patch implementations and dependencies before installation. No Discord
  build was installed, and the listing does not prove higher stream
  quality or uninterrupted solo calls.

### Discord 350.8 input verification

[Venus v1.20.0](https://github.com/VenusIsJaded/Venus-Patches/releases/tag/v1.20.0)
targets Discord 350.8 Stable. Its MPP matched GitHub's SHA-256
5588f69a5f12b868538112b70f6c666171fbed547719980e979af8b811404f8e.
The current com.discord package reports Morphe Manager as installer.
Its copied APK's Hermes bundle SHA-256 is
a03c3bdebd2afe0f608321de0b2808b072fb0997846dff74680376d7b537638d.
The release's input guard requires
0f2e1735fc0ed5d7f7068aaae8cfb603987a346584b3eea0fd8790df38e2a8b2.
The UI batch stopped in that guard without producing an APK or changing
the installed Discord package. Matching the display version alone is
insufficient. A trusted original APKM matching the pinned bundle is needed.
No account, call, or streaming test was performed.

### Discord 350.8 broad patch build

An original base APK was found in Downloads. Its APK signature verified,
its package/version was com.discord/350008, and its JavaScript bundle
matched the Venus v1.20.0 input guard. All 15 opt-in patches applied
without suppressing errors: Custom branding, Load full-quality images,
Show file sizes when attaching, Tap mentions to open profiles, Custom
themes, Message highlights, Use your phone's emojis, Use your phone's
font, Voice channel options, Material You colors, Pastel name colors,
Jump to first message, Icon packs, Disable analytics, and Disable
advertising identifiers. Credit: VenusIsJaded and upstream contributors.

The signed output had the separate com.discord.venus package, but Android
refused installation with INSTALL_FAILED_MISSING_SPLIT. The local original
was the base APK and is missing companion splits. The complete 350.8
APKM with its companion splits is required for the next install trial.
The existing Discord app was not replaced. Runtime UI, calling and
streaming remain untested. No Discord APK was published.

The rebuilt manifest confirms Android's required split types are
`base__abi` and `base__density`. The source base manifest has the same
requirements. No APKM, XAPK or APKS archive was found in the scoped phone
Downloads, Documents, or Termux home search. One older Venus v1.19.0
export is a single patched APK (another copy is invalid), so it cannot
supply publisher-signed original splits. A versioned mirror query
returned HTTP 403, and another mirror's listed 350.8 download page
returned HTTP 404. Neither supplied bytes for verification. The build
needs the original base plus matching ABI and density splits, verified as
one package/version/signing set before using Morphe's bundle workflow.

The official Manager 2.7.1 APK already in Downloads matched the GitHub
release digest and had the same signing certificate as the installed
2.6.0 APK. Android accepted the in-place background update. The old
APK was retained locally. No Manager import or Discord bundle test was
performed in this update. The public Debugs MPP checksum verified after
a fresh GitHub release download.

### Headless split input verified

Desktop v2.3.0 accepts an APKS archive even though its help calls the input
an APK. A read-only pull of the installed YouTube 21.47.483-BETA base,
ARM64, English and XXHDPI files was assembled into a local ZIP with those
four APKs at its root and the .apks extension. Desktop merged all four
and applied only the upstream Clone app test. The signed output had the
clone package, ARM64 libraries and no required-split declaration.
This verifies the merge workflow using a real complete input set. It
does not establish YouTube patch or runtime compatibility. The output
was not installed. Discord still lacks its original matching splits.

### Broad YouTube trial and Reddit guest batch

The broad Desktop 2.3.0 trial against the complete 21.47.483-BETA YouTube
input selected only Clone app under normal compatibility checks. Its
output stayed local and was not installed. The existing app.morphe.android.youtube
reported 21.20.405 and was not targeted.

Reddit 2026.24.0 was built without continue-on-error by selecting only
the upstream Clone app and Start as guest patches in exclusive mode.
A separate pass applied the Debugs launcher label to the clone. The
result retained com.reddit.frontpage.morphe, the Reddit Debugs label and
the existing certificate. Android accepted a background reinstall over
the exact verified previous APK, and installed bytes matched the new
APK. The previous working labeled APK remains available locally.
In-app guest behavior is not yet verified.

`build-discord-venus.sh` records the exact 15-patch batch and accepts a
complete trusted original split archive. It checks the pinned tools and
signed output, requires the distinct Venus package and refuses an
unresolved required-split declaration. Its base-only refusal was tested.
The complete Discord build is still untested. A listing for the 350.8
XAPK was found on Captain Droid, but the download could not be obtained
through the current route. Do not treat the listing as verified APK bytes.

The Discord recipe now preflights the ZIP members using apksigner and
aapt before processing. It requires the observed original Discord signer,
version code 350008, the Venus-expected JavaScript SHA-256 in the base, and
distinct ARM64 and density split declarations. A renamed base-only APKS
fixture passed signer and base checks and refused for the missing splits.
This negative control does not establish a complete Discord build.

### Complete Discord archive and background install

The versioned APKPure .net route supplied the 350008 XAPK (SHA-256
1495419b4e10051cccd274c9d48de84f2ada98e23f679a615b6f3cc51ba3c88a).
The preflight verified the original signer on all four APKs, their
package/version, the base bundle digest and ARM64 and density declarations.
Desktop merged the base, ARM64, English and XXHDPI modules and applied
all 15 selected patches without suppressing errors. Removed the explicit
keystore path from the recipe because Desktop expects that file to
exist; the normal local Desktop signing workflow signed this fresh clone.

Android accepted com.discord.venus in the background, alongside the
existing com.discord. Installed bytes matched the verified build
(SHA-256 a19b11104f05c87277be7751b77380b34010e5146aff0e7675155a6017ebab55),
and its launcher resolved. Runtime settings, voice, and video have not
been exercised. No APK, archive or keystore was published.

### Expanded Discord Venus batch

The same verified Discord 350008 archive built with all 27 selected
patches. Android accepted the same-certificate background update to
com.discord.venus, and the installed APK hash matched the expanded
build. The 15-patch APK remains available locally. The existing
com.discord remains installed. Credit: VenusIsJaded and contributors.

The exact v1.20.0 MPP embeds a settings parser that accepts a plain JSON
preset through Discord Settings → Venus → Backup and restore. The separate
Discord-Venus-Debugs-Starter.json copy in Downloads matches the checked-in
preset. The preset keys were checked against that bundle. Restore can
reset omitted keys, so save an existing Venus profile before importing.
Import requires in-app confirmation and was not exercised. Build-time
patch inclusion does not confirm a saved preference or runtime behavior.

### Music Debugs 9.30.53

The original 93053240 APK from the versioned APKPure .net endpoint
verified under the same APK signing certificate digests as the installed
Google Play YouTube Music package. A first clone hit a duplicate Android
permission. The [upstream Clone app source](https://github.com/MorpheApp/morphe-patches/blob/v2.3.0/patches/src/main/kotlin/app/morphe/patches/all/misc/clone/CloneAppPatch.kt)
delegates permission and provider namespacing for YouTube Music to
GmsCore support. With that patch included, the compiled manifest declared
the receiver permission and app-specific providers under the clone ID.

The exact successful selections were Clone app
(-OpackageName=com.google.android.apps.youtube.music.debugs),
Custom branding (-OcustomName='Music Debugs'), GmsCore support, Crossfade,
A-B loop, Remember repeat state, Remember shuffle state, Navigation bar,
Change miniplayer color, Miniplayer previous and next buttons, Theme,
Force original audio, Media notification controls, Sanitize sharing links,
Open system share sheet, and Playback speed. These were direct CLI options
in exclusive mode. An earlier options-file experiment selected 57 because
the generated config had upstream defaults enabled, and was not installed.
Android accepted the 16-patch build and the installed APK hash matched.
Both existing Music packages remain present. Playback, sign-in and UI are
unverified. Credit: MorpheApp and the individual upstream patch contributors.

### YouTube source search and cache reconciliation

The versioned download requests for compatible YouTube 21.30.216,
21.28.208, 21.23.492 and 20.26.46 ended at HTTP 403 through the available
APKPure route. APKMirror listed supported versions but also refused the
direct request. No compatible original was obtained in this pass.
The stock YouTube and existing Morphe install were left in place.

Removed 1,146,028,032 allocated bytes from eleven superseded local
trial APKs and the negative-control archive after checking for a Java
build and open or mapped files. Downloaded originals, installed outputs,
known rollback APKs, signing material, source and diagnostics were retained.

Run `sh build-music-debugs.sh ORIGINAL_9.30.53_APK` for the same 16-patch
selection. The recipe pins both Morphe assets, checks the original APK
version and signing certificate, and verifies the output signature and
separate package ID. A full repeat build passed. The installed clone APK
was also refused as an input to this stock-source recipe. The repeat
output was not reinstalled.
