#!/bin/bash

# CDに移動&初期化
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # 実行場所を相対パスで取得し、そこにサブシェルで移動、pwdで取得
cd "$sh_dir" || {
    echo "Failure CD command."
    exit 1
}

# 変更点のあったファイルのディレクトリを配列で確保
mapfile -t dirs < <( # 各行を要素として改行を削除して変数に保存、プロセス置換でコマンド結果を仮想ファイルとしてmapfileコマンドに渡している
  git diff-tree --name-only --no-commit-id -r HEAD~1 HEAD | \
  sed 's|/[^/]*$|/|' | \
  grep '/.*' | \
  sort -u
) 
# s|A|B|で置換、^は先頭、$は末尾、[]内で^を使うと否定、[]は文字クラスで中身に指定した文字のどれか一文字を表す # つまり、/の後に任意の/以外の1文字が0回以上マッチするものが末尾にあるかどうか
# .*は任意の文字が0回以上（:*）続くパターン

# Dockerにログイン
if [ -n "$1" ]; then docker login -u unserori -p $1; fi

for dir in "${dirs[@]}"; do
  # 確認
  echo for_dir_dirs########
  echo "\$dir: ${dir}"

  # Dockerfileを含むディレクトリ（:ビルドコンテキストディレクトリ）のみを対象とするために、ディレクトリでないまたはディレクトリ内にDockerfileを含まないならこんて
  if ! find "../$dir" -maxdepth 1 -type f -name "Dockerfile*" | grep -q . ; then continue; fi

  # ディレクトリ内のすべてのDockerfile*を対象に処理
  for dkrf in "../${dir}Dockerfile"*; do
    # 確認
    echo for_dkrf_{dir}Dockerfile.*########
    echo "\$dkrf: ${dkrf}"

    # タグ名のためにビルド情報を集める
    jdk_version="$(basename "$(dirname "$(dirname "${dkrf}")")")" # 二つ上のディレクトリを取得し、basenameでディレクトリ名のみ取得する
    if [[ "$(basename "${dkrf}")" == *.* ]];then jdk_or_jre="-${dkrf##*.}";fi # 拡張子があるなら取得
    base_image="$(basename "$(dirname "${dkrf}")")" # 一つ上のディレクトリを取得し、basenameでディレクトリ名のみ取得する
    # log
    echo build_info########
    echo "\$jdk_version: ${jdk_version}"
    echo "\$jdk_or_jre: ${jdk_or_jre}"
    echo "\$base_image: ${base_image}"

    # ビルドのための値を設定
    user="unserori"
    repository="unjdk"
    image="unjdk" # リポジトリ名と一致させる
    tag="openjdk-${jdk_version}${jdk_or_jre}-${base_image}"
    # log
    echo build_val########
    echo "\$user: ${user}"
    echo "\$repository: ${repository}"
    echo "\$image: ${image}"
    echo "\$tag: ${tag}"

    # ビルド
    docker build -f "${dkrf}" --force-rm=true --no-cache=true -t ${image}:${tag} \
    --build-arg ARTIFACT_PATH=jre \
    --build-arg JAVA_21_BOOT_JDK=eclipse-temurin:20.0.2_9-jdk \
    --build-arg JAVA_21_SOURCE_TAG=jdk-21-ga \
    .

    # プッシュ
    docker tag ${image}:${tag} ${user}/${image}:${tag} # タグをつける docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
    docker push ${user}/${image}:${tag} # プッシュ

    echo
  done
  echo
done

# Dockerからログアウト
if [ -n "$1" ]; then docker logout; fi
