#!/usr/bin/env bash
# Build RC Pair (Android 9 / API 28) with the bare SDK tools, no Gradle. Output: build/rcpair.apk
# Needs: brew openjdk@17, brew cask android-commandlinetools, sdkmanager "platforms;android-28" "build-tools;34.0.0"
set -euo pipefail
cd "$(dirname "$0")"
export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@17}"
export PATH="$JAVA_HOME/bin:$PATH"
SDK="${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}"
BT="$SDK/build-tools/34.0.0"
JAR="$SDK/platforms/android-28/android.jar"
B=build

rm -rf "$B" && mkdir -p "$B/classes" "$B/dex"
"$BT/aapt2" link -o "$B/base.apk" -I "$JAR" --manifest AndroidManifest.xml \
  --min-sdk-version 28 --target-sdk-version 28
# Java 8 API plus the API 28 android.jar: anything missing on Android 9 fails here.
javac -nowarn -Xlint:-options --release 8 -classpath "$JAR" -d "$B/classes" $(find src -name '*.java')
"$BT/d8" --min-api 28 --lib "$JAR" --output "$B/dex" $(find "$B/classes" -name '*.class')
cp "$B/base.apk" "$B/unsigned.apk"
(cd "$B/dex" && zip -q -u ../unsigned.apk classes.dex)
"$BT/zipalign" -f 4 "$B/unsigned.apk" "$B/aligned.apk"
[ -f debug.keystore ] || keytool -genkeypair -keystore debug.keystore -storepass android -keypass android \
  -alias rcpair -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=rcpair" >/dev/null 2>&1
"$BT/apksigner" sign --ks debug.keystore --ks-pass pass:android --out "$B/rcpair.apk" "$B/aligned.apk"
echo "built $B/rcpair.apk ($(wc -c < "$B/rcpair.apk") bytes)"
