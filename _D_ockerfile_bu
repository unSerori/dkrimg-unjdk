# グローバルスコープ
ARG JAVA_21_BOOT_JDK

# 開発用やビルド用の共通ステージ

# Stage0: 軽量debian
FROM debian:bookworm-slim AS base

# パッケージリストの更新と共通で必要なツール
RUN \
    apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y git

# # ビルド用のステージ

# Stage1: java（:bootJDK）の入ったイメージ
FROM ${JAVA_21_BOOT_JDK:-eclipse-temurin:latest} AS build-stage

# composeから変数を受け取る
ARG JAVA_21_SOURCE_TAG

# 作業ディレクトリの設定
WORKDIR /usr/build/

# 必要なパッケージやリソースのダウンロードおよびインストール
SHELL ["/bin/bash", "-l", "-c"]
RUN \
    # 必要なツール類 TODO: 
    apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y file git unzip zip \
    # graphviz pandoc gawk
    # ビルドツール
    build-essential autoconf \
    # # Native Compiler (Toolchain) Requirements
    # gcc clang \
    # FreeType
    libfreetype6-dev \
    # Fontconfig
    libfontconfig-dev \
    # CUPS
    libcups2-dev \
    # X11
    libx11-dev libxext-dev libxrender-dev libxrandr-dev libxtst-dev libxt-dev \
    # ALSA
    libasound2-dev \
    # libffi
    libffi-dev \
    # # others
    # zip unzip curl \
    # ソースのdl
    # && mkdir -p ./src/ \
    && git clone --depth 1 -b ${JAVA_21_SOURCE_TAG} https://github.com/openjdk/jdk.git \
    # ビルド
    && cd ./jdk/ \
    && build_conf_name=linux-architecture-server-release \
    && bash configure --help > configure_help.txt \
    && time bash configure --with-conf-name=${build_conf_name} --with-jvm-variants=server --enable-headless-only=yes \
    --with-version-build=35 \
    --with-version-pre= \
    --with-version-opt=unSerori-build \
    --with-vendor-name=unSerori \
    && time make images \
    # JREを取り出す
    && ./build/${build_conf_name}/images/jdk/bin/jlink \
    --module-path ./build/${build_conf_name}/images/jdk/jmods \
    --add-modules ALL-MODULE-PATH \
    --no-man-pages \
    --strip-debug \
    --no-header-files \
    --compress=2 \
    --output ./build/${build_conf_name}/images/jre/

# デプロイ用のステージ

# Stage1: 軽量なベースイメージ
FROM debian:bookworm-slim AS deploy

# ビルドしたJDKをコピー
COPY --from=build-stage /usr/build/jdk/build/linux-architecture-server-release/images/jre/ /opt/java/unjdk/

# 環境変数の設定
ENV JAVA_HOME=/opt/java/unjdk
ENV PATH=$JAVA_HOME/bin:$PATH

CMD [ "java", "--version" ]