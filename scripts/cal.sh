#!/usr/bin/env sh
###
 # @Author: khfahqp khfahqp@gmail.com
 # @LastEditors: khfahqp khfahqp@gmail.com
 # Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
### 

set -eu

if [ "$#" -lt 1 ]; then
  echo "Usage: ./cal.sh path/to/app.apk"
  exit 1
fi

APK_PATH=$1

if [ ! -f "$APK_PATH" ]; then
  echo "error: file not found: $APK_PATH" >&2
  exit 1
fi

SIZE=$(stat -c '%s' "$APK_PATH")
SHA256=$(sha256sum "$APK_PATH" | awk '{print tolower($1)}')

printf 'size: %s\n' "$SIZE"
printf 'sha256: "%s"\n' "$SHA256"