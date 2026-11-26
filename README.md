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
