#!/usr/bin/env sh
set -eu
if ! command -v java >/dev/null 2>&1; then
  echo "Java 21+ is required." >&2
  exit 1
fi
if ! command -v gradle >/dev/null 2>&1; then
  echo "Gradle was not found. On Windows, run build.bat to bootstrap Gradle and build/install Apex." >&2
  echo "On macOS/Linux, install Gradle 8.14.3+ and then run this script." >&2
  exit 1
fi
exec gradle --no-daemon clean build
