#!/bin/bash

# イメージを手動でプッシュ

# CDに移動&初期化
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # 実行場所を相対パスで取得し、そこにサブシェルで移動、pwdで取得
cd "$sh_dir" || {
    echo "Failure CD command."
    exit 1
}
source ./init.sh

# タグをつける docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
docker tag unjdk:openjdk-N-manual unserori/unjdk:openjdk-N-manual

# ログイン
docker login -u unserori -p $1

# プッシュ
docker push unserori/unjdk:openjdk-N-manual
