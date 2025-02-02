#!/bin/bash

# Dockerfileを手動でビルド

# CDに移動&初期化
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # 実行場所を相対パスで取得し、そこにサブシェルで移動、pwdで取得
cd "$sh_dir" || {
    echo "Failure CD command."
    exit 1
}
source ./init.sh

# ビルド
docker build -f ../Dockerfile --force-rm=true --no-cache=true -t unjdk:openjdk-21-jre-bookworm-slim \
  --build-arg JAVA_21_BOOT_JDK=${JAVA_21_BOOT_JDK} \
  --build-arg JAVA_21_SOURCE_TAG=${JAVA_21_SOURCE_TAG} \
  .