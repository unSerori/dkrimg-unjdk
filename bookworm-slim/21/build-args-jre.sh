#!/bin/bash

# 空白を含む文字列のため"で囲むこと、また改行でわかりやすく記述している

args="
  --build-arg JAVA_BOOT_JDK=eclipse-temurin:20.0.2_9-jdk \
  --build-arg JAVA_SOURCE_TAG=jdk-21-ga \
  --build-arg ARTIFACT_PATH=jre \
"
