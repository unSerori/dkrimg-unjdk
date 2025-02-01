# dkrimg-unjdk

自分用の軽量なJDK/JREが入ったベースイメージを作ろうの会  
GitHub ActionsとかDockerHubとかおさわりしたかった  

## めも

### dockerhubリポジトリ

ユーザー名: unserori
リポジトリ名: unjdk
イメージ名: openjdk-${jdk_version}-${jdk | jre}-${base_image}
タグ: v20250127 OR latest

例: unjdk/openjdk-21-jre-bookworm-slim:v20250127

### 管理方法

1. ディストリビューションごとにディレクトリとDockerfile作成。成果物の各バージョンをタグで管理
2. 成果物の各バージョンごとにディレクトリを作成、その中にサポートする各ディストリビューションディレクトリとDockerfileを作成
3. jdk/jreをマルチステージビルド？
