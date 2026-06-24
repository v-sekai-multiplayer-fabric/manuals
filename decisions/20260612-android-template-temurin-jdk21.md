---
title: Android template builds with Temurin JDK 21 and config.gradle-pinned SDK
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The Android export template of the merged double-precision assembly is needed for OpenXR builds. The box carries no Android SDK, and Fedora 44 packages only JDK 25 and 26; Gradle rejects Java 25 with "Unsupported class file major version 69".

## Decision Outcome

Chosen option: pin the Android toolchain to what the fork's `platform/android/java/app/config.gradle` declares — NDK `29.0.14206865`, build-tools `36.1.0`, platform `android-36` — installed through `sdkmanager` from the command-line tools, and run Gradle on a Temurin JDK 21 tarball fetched from the Adoptium API, because the distribution ships no Gradle-compatible JDK and the tarball pins the version per checkout.

The verified sequence: `scons platform=android target=template_release arch=arm64 precision=double` produces `libgodot_android.so` (about four minutes on the workstation), then `JAVA_HOME=<temurin-21> ./gradlew generateGodotTemplates` produces `bin/android_release.apk`.

## Consequences

- The Android OpenXR export template exists before the gate, retiring the toolchain risk.
- `config.gradle` is the single source of truth for SDK versions; reading it first avoids guessing.
- The JDK is per-user (`~/jdks`), so system Java stays at the distribution default.

## Confirmation

`bin/android_release.apk` builds from the merged assembly and installs on an Android OpenXR device.
