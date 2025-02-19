#!/bin/bash

# Dockerfileを手動でビルド

# CDに移動&初期化
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # 実行場所を相対パスで取得し、そこにサブシェルで移動、pwdで取得
cd "$sh_dir" || {
    echo "Failure CD command."
    exit 1
}
source ./init.sh
echo $ARGS

# ビルド
docker build -f "$1" --force-rm=true --no-cache=true -t unjdk:openjdk-N-manual \
  ${ARGS} \
.

# dockerの使用容量を確認
docker system df
# 未使用のイメージを確認なしで削除
docker image prune -f
# 未使用のコンテナを削除
docker container prune -f
# 未使用のボリュームを削除
docker volume prune -f
# キャッシュを削除
docker builder prune -f
