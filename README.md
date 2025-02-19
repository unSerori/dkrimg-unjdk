# dkrimg-unjdk

自分用の軽量なJDK/JREが入ったベースイメージを作ろうの会  
GitHub ActionsとかDockerHubとかおさわりしたかった  

## HowTo

### 開発

各ディストリビューション、実行環境のバージョンごとのDockerfileやカスタム引数を記述した`build-args-*.sh`を編集  
mainにpushするとGitHubActionsが処理し、DockerHubにイメージがアップロードされる  

### 手動ビルド

1. `scripts-manual`内の`.env.build-args`を記述
2. ビルドとプッシュを以下コマンド

```bash
# build
bash ./scripts-manual/build.sh "<スクリプトのCDからDockerfileへの相対パス>"
# push
bash ./scripts-manual/push.sh "<Dockerのパスワード>"
```


## めも

### dockerhubリポジトリ

ユーザー名: unserori
リポジトリ名: unjdk
イメージ名: unjdk （リポジトリ名+タグかも？）
タグ: openjdk-${jdk_version}-${jdk | jre}-${base_image}

例: unserori/unjdk:openjdk-21-jre-bookworm-slim
