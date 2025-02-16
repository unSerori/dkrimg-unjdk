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

# dockerの使用容量を確認
docker system df
# 未使用のイメージを確認なしで削除
docker image prune -y
# 未使用のコンテナを削除
docker container prune -f
# 未使用のボリュームを削除
docker volume prune -f
# キャッシュを削除
docker builder prune -f
