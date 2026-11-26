# Morphe Debugs

Independent patch design and verification batches. Upstream tools and patches are by MorpheApp and their respective contributors. Preserve upstream notices when distributing derivative source.

## Rebuild the verified batches

Use Java 21 and the Android SDK's `aapt` and `apksigner` on PATH.
The recipes also use `sha256sum` and standard shell utilities. The Reddit
recipe needs `unzip`; the Discord input verifier needs Python 3.11 or newer.

Create a local `.cache` directory and place these release assets there
under the exact names shown. The recipes check their digests before use.

| Local filename | Release |
| --- | --- |
| `morphe-desktop-2.3.0-all.jar` | [Morphe Desktop 2.3.0](https://github.com/MorpheApp/morphe-desktop/releases/tag/v2.3.0) |
| `patches-2.3.0.mpp` | [Morphe Patches 2.3.0](https://github.com/MorpheApp/morphe-patches/releases/tag/v2.3.0) |
| `venus-1.20.0.mpp` | [Venus Patches 1.20.0](https://github.com/VenusIsJaded/Venus-Patches/releases/tag/v1.20.0) |
| `debugs-0.1.0.mpp` | [Debugs reproducible bundle](https://github.com/Sodelin/morphe-debugs/releases/tag/v0.1.0-reproducible), |

Supply the publisher-signed app inputs separately. The recipes expect
Discord 350008 with its ARM64 and density splits, the pinned Reddit
2624051 XAPK, and YouTube Music 9.30.53 (93053240).

```sh
sh build-discord-venus.sh /path/to/original-discord.xapk
sh build-reddit-debugs.sh /path/to/original-reddit.xapk
sh build-music-debugs.sh /path/to/original-music.apk
```

The recipes produce signed APKs in `.cache` and accept an optional
output path. Before updating an installed clone, compare its signing
certificate with the new APK. Keep existing signing material private
and reuse the selected Morphe signing identity for in-place updates.
The device verifier below identifies the exact verified batch signed
with the original build identity; another identity changes the APK hash.

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

For the verified 0.1.0 batch, use the pinned release bundle. Apply it to a
clone using `patch -p .cache/debugs-0.1.0.mpp --exclusive -e 'Debugs launcher label'`.
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
preset. The preset keys were checked against that bundle. Use Restore
for a fresh profile or when you intend to replace the current settings.
The pinned restore dialog explicitly warns that it replaces settings.
During restore Venus supplies defaults for omitted settings in enabled
patch groups. For a profile you already use, enable the desired switches
individually in Venus settings to preserve your other preferences. The
preset enables Voice channel options without selecting a custom volume
or audio output.

A Venus settings export may include private user IDs, custom themes,
icon packs and locally edited server names. Keep any export private. It
is separate from Discord's account recovery codes. Import requires
in-app confirmation and was not exercised.

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

### Reddit Debugs with the publisher-signed ARM64 input

The earlier file named reddit-stock.apk was copied from com.reddit.frontpage,
which reports Morphe Manager as installer and has the synthetic version code
2147483647. It was not an original publisher-signed input. This explains
why the build notes do not generalize to the original 2026.24.0 release.

The versioned APKPure .net XAPKs for 2624050 and 2624051 were verified
member by member using the [published Reddit signing fingerprint](https://www.apkmirror.com/apk/redditinc/reddit/reddit-2026-24-0-release/reddit-2026-24-0-android-apk-download/).
Both built all 14 selected upstream patches. The first variant carried
only ARMv7 native libraries and Android refused it. The second had 33
matching APK members and the rebuilt output retained six ARM64 libraries.
It applied Clone app, Start as guest, Keep feed position, Customize post
layout, Hide navigation buttons, Full width feed media, Feed media max
height, Media viewer black background, Media viewer fade, Remember
collapsed comments, Copy text, Show flairs in home feed, High quality
avatars, and Sanitize sharing links. The independent Debugs launcher
label applied as a second pass.

Android accepted the same-signature background update to the Debugs
clone and installed bytes matched that build. The previous guest-only
build remains the rollback artifact. No account or feature UI was tested.

### Expanded Reddit Debugs batch

The same verified 2624051 ARM64 archive built with 28 selected MorpheApp
patches in exclusive mode. The 14 additions to the first batch were
Custom font, Force system font, Hide Ask button, Hide communities shelf,
Hide media viewer components, Disable modern home, Disable screenshot
popup, Hide Reddit search, Hide sidebar components, Hide Trending
shelves, App icon, Download location, Open links externally, and
Redgifs audio. The independent Debugs label applied in a separate pass.

Android accepted the expanded 29-patch APK as a same-signer background
update. Installed bytes matched the expanded APK, and the 15-patch build
remains available for rollback. App settings, playback and feature
behavior are still unverified. No target APK was uploaded.

The expanded batch can be rebuilt with
`sh build-reddit-debugs.sh ORIGINAL_2624051_XAPK`. The recipe pins the
original archive and all three build assets, verifies the signed clone's
identity and ARM64 libraries, and leaves installation separate. A complete
repeat build passed, and the ARMv7 archive was refused before patching.

## Installed batch checkpoint

The installed APK hashes match the verified 27-patch Venus, 29-patch
Reddit Debugs, and 16-patch Music Debugs artifacts. Each installed clone
also matches the certificate of its retained companion APK. The Venus
companion is the 15-patch build, Reddit's is the 15-patch build, and
Music's is the repeat build. Android resolved all three launcher
activities. Venus had a live process. Reddit and Music were still marked
not launched. No app was opened, stopped or reinstalled for this check.
This checkpoint does not verify settings or feature behavior.

The installed 29-patch Reddit Debugs APK was rolled back with a
same-certificate replacement install to the retained 15-patch APK, then
restored to the 29-patch APK. Android accepted both steps, and the APK
read back from the installed path matched each expected SHA-256 in
sequence. Neither install uninstalled the package, and com.reddit.frontpage
remained present. This verifies package rollback only; the app was not
opened and account, preferences and playback were not exercised.

### Background startup smoke tests

The installed scrcpy 5.0.1 client needed FFmpeg 9.1 libraries. The
Termux package was extracted into an isolated cache and loaded for
scrcpy only. The installed FFmpeg package was not changed.
Two serial 16-second tests used dedicated 720x1280 virtual displays,
with audio and clipboard forwarding disabled and video sent to the
null device. Reddit Debugs reached its resumed launcher on its virtual
display and had a live process. Music Debugs reached its launcher with
a live process, then paused for Android's permission request. No
permission was granted or denied. Both virtual displays disappeared
after their original sessions ended. No app screen was retained.
This verifies startup only. Menus, feature toggles, sign-in, and
playback were not exercised.

A follow-up on a dedicated Reddit Debugs virtual display verified the
expanded build renders a public feed with its Log in button still present.
The initial surface was black while the UI loaded. A later sample showed
the guest feed and Android's notifications prompt labeled Reddit Debugs.
No permission choice or sign-in was submitted. Capture was streamed to
memory, and no screenshot or video file was retained. This verifies the
guest startup path, without verifying individual settings or playback.

The expanded Reddit build opened Settings → Morphe in the signed-out
virtual-display session. Navigation bar and Sidebar controls rendered.
The Hide Games button switch began off, visibly switched on after one
display-scoped tap, and returned to off after a second tap. This tests
the switch interaction. The feed had no visible Games button at the
time, so actual removal or persistence across restart was not tested.
No capture file or account input was retained.

A later virtual-display test verified that enabling Hide Create button
removed the Create item from the signed-out navigation bar. The same
setting still showed enabled after reopening Morphe settings. An off tap
was attempted, but the bar did not immediately restore before the
display's foreground changed, so final preference restoration is
unverified. Further input stopped. The copied frame was memory-only,
and future capture must recheck the resumed package and display before
each capture or interaction.

The expanded Reddit headless recipe pins the published
[v0.1.0 reproducible bundle](https://github.com/Sodelin/morphe-debugs/releases/tag/v0.1.0-reproducible).
An end-to-end rebuild from the pinned 2624051 XAPK verified 28 upstream
patch applications and the separate launcher label. The recipe checked
the APK signature, clone package, Reddit Debugs label, and ARM64 libraries.
This exact rebuild was verified offline and was not installed.

A follow-up compared the rebuilt APK byte for byte with the previously
verified expanded APK and measured the same SHA-256 on the installed
Reddit Debugs clone:
`8ab435348c8508e0affdeefbfe8eef1dedde45a8a2546ce2b6eaf746b25be058`.
This connects the reproducible recipe to the already-installed artifact
and its prior UI and rollback observations. No reinstall was needed.

Run `sh verify-installed-builds.sh` with the intended Android device
connected through ADB to verify this batch. The command checks that each
original package is present and compares each installed clone's base APK
to the digest of its verified build. It reads package metadata and APK
bytes on the device and requires no account credentials.

### Discord native screen-share compatibility

The Discord 350.8 original and installed Venus build declare the same
media-projection foreground-service permission and Discord
`ForegroundService` type bitmask (`0xe1`). The ARM64 `libdiscord.so`
in the original input split and in the merged Venus APK have matching
SHA-256 digests. These checks verify packaging only. A live call with
Android capture consent and receiver-side picture and audio confirmation
remains necessary to verify native screen sharing.

The pinned Venus 1.20.0 bundle's Voice channel options expose starting
call volume, audio output routing, join and leave chimes, and a goodbye
sound. The starter preset selects this patch's settings group. The
current recipe contains no custom solo-call lifetime, screen-share
resolution or frame-rate, or FLAC transmission patch. Those behaviors
should be verified independently of the voice options and the Android
screen-capture manifest check.

Discord's [voice protocol](https://docs.discord.com/developers/topics/voice-connections#transport-encryption-and-sending-voice)
uses Opus and documents a sound-share mode for live media. This Venus
build does not add FLAC passthrough or transfer the source file as part
of a live stream. Sending the source is a separate file transfer.
[Discord mobile video uploads](https://support.discord.com/hc/en-us/articles/9665451164951-Video-Upload-Quality-Settings-on-Mobile-FAQ)
can compress video. Use a private link to the original when exact bytes
matter.

To install a local APK from this exact batch, run
`sh verify-installed-builds.sh --install /path/to/verified.apk`.
It checks the local digest and requires the corresponding original
app to be present. If the verified clone is already installed, it skips
installation. Otherwise it checks the APK signature, uses Android's
streamed in-place install, and checks the installed digest afterward.
Keep the normal ADB device selection pointed at your intended phone.

The install command was exercised on-device with Reddit Debugs. Android
accepted the retained 15-patch same-signer APK first and its installed
digest matched the rollback artifact. The command then detected the
different digest, streamed the 29-patch update, and verified the
installed result. All three clones matched the batch after the test.
This verifies the update path without opening app accounts or checking
their data in the UI.

### Debugs 0.2.0 launcher labels

The next independent bundle also labels the alternate Reddit launcher
icons. Reddit supplies an explicit label on its alternate launcher
aliases, which otherwise overrides the application label. Build
`debugs-0.2.0.mpp` with `sh build-debug-bundle.sh` and apply the same
opt-in patch name to the Reddit clone. The signed candidate was checked
against the previous manifest and all launcher aliases retained their
distinct icons and received the Debugs label. The full 29-patch recipe reproduced the
signed 0.2.0 APK byte for byte. Android accepted the same-signer in-place
update and its installed SHA-256 matched. The prior 0.1.0 APK remains
available locally for rollback. Launcher icon switching was not exercised.

An on-device Android package-manager query with disabled components
included returned 22 launcher activities for the installed clone. All
22 reported the Reddit Debugs label on the activity itself. The APK
manifest check covers 23 aliases; the package-manager result covers
only the activities Android returned. No component state was changed,
and the launcher UI was not opened.

For the installed Music Debugs batch, the patched manifest names
`app.revanced.android.gms` as the GmsCore companion. A read-only check
on the target Android device found that package installed and enabled
for user 0 at version 7.3.0. This confirms the named companion is
available locally. Sign-in and playback still require a live check.

The 0.2.0 patch bundle was rebuilt from release source and matched the
downloaded GitHub asset SHA-256
`cd2c16d24102b6d746c48eb6b94ce0fcfcbf26dc438914843324541873841ea3`.
