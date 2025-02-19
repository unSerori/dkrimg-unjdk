#!/bin/bash

# CDに移動&初期化
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # 実行場所を相対パスで取得し、そこにサブシェルで移動、pwdで取得
cd "$sh_dir" || {
    echo "Failure CD command."
    exit 1
}

# メイン処理

# Dockerにログイン
if [ -n "$1" ]; then docker login -u unserori -p $1; fi

# 変更点のあったファイルのディレクトリを配列で確保
mapfile -t dirs < <( # 各行を要素として改行を削除して変数に保存、プロセス置換でコマンド結果を仮想ファイルとしてmapfileコマンドに渡している
  git diff-tree --name-only --no-commit-id -r HEAD~1 HEAD | \
  sed 's|/[^/]*$|/|' | \
  grep '/.*' | \
  sort -u
) 
# s|A|B|で置換、^は先頭、$は末尾、[]内で^を使うと否定、[]は文字クラスで中身に指定した文字のどれか一文字を表す # つまり、/の後に任意の/以外の1文字が0回以上マッチするものが末尾にあるかどうか
# .*は任意の文字が0回以上（:*）続くパターン

# 変更のあるファイルのディレクトリを一括処理
for dir in "${dirs[@]}"; do
  # 確認
  echo for_dir_dirs########
  echo "\$dir: ${dir}"

  # Dockerfileを含むディレクトリ（:ビルドコンテキストディレクトリ）のみを対象とするために、ディレクトリでないまたはディレクトリ内にDockerfileを含まないならこんて
  if ! find "../$dir" -maxdepth 1 -type f -name "build-args-*.sh" | grep -q . ; then continue; fi

  # ディレクトリ内のすべてのbuild-args-*を対象に処理
  for build_args_f in "../${dir}build-args-"*".sh"; do
    # 確認
    echo for_build_args_f_{dir}build-args-*.sh########
    echo "\$build_args_f: ${build_args_f}"

    # タグ名のためにビルド情報を集める
    jdk_version="$(basename "$(dirname "${build_args_f}")")" # 1つ上のディレクトリを取得し、basenameでディレクトリ名のみ取得する
    build_args_f_without_ext=$(basename "${build_args_f%.*}") # 拡張子を除外し、パスからファイル名を抜き出す
    custom="${build_args_f_without_ext#build-args}" # カスタム文字列のみ取得
    base_image="$(basename "$(dirname "$(dirname "${build_args_f}")")")" # 2つ上のディレクトリを取得し、basenameでディレクトリ名のみ取得する
    # log
    echo build_info########
    echo "\$jdk_version: ${jdk_version}"
    echo "\$custom: ${custom}"
    echo "\$base_image: ${base_image}"

    # ビルドのための値を設定
    user="unserori"
    repository="unjdk"
    image="unjdk" # リポジトリ名と一致させる
    tag="openjdk-${jdk_version}${custom}-${base_image}"
    # log
    echo build_val########
    echo "\$user: ${user}"
    echo "\$repository: ${repository}"
    echo "\$image: ${image}"
    echo "\$tag: ${tag}"

    # ビルド
    source $build_args_f
    echo ${args}
    docker build -f "../${dir}Dockerfile" --force-rm=true --no-cache=true -t ${image}:${tag} \
     ${args} \
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
