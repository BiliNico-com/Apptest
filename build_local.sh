#!/bin/bash
export HOME=/root
export PUB_CACHE=/root/.pub-cache
export PATH="$PATH:/opt/flutter/bin"
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export ANDROID_HOME=/usr/lib/android-sdk
export GRADLE_USER_HOME=/root/.gradle

cd /app/91Download-Mobile
echo "开始编译 Flutter APK..."
time flutter build apk --release
