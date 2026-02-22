# Inception - 開発者向けドキュメント (DEV_DOC.md)

このドキュメントは、Inceptionプロジェクトの開発者およびレビュアー（評価者）向けに、環境の構築方法や管理コマンド、データ構造について説明するものです 。

## 1. 前提条件 (Prerequisites)

プロジェクトを立ち上げる前に、以下の環境が整っていることを確認してください 。

- OS: Debian 系の Linux ディストリビューション（または macOS 等の Docker 実行環境）

- Docker & Docker Compose: 最新バージョンがインストールされていること。

- ドメイン設定: ローカル環境でアクセスするために、ホストマシンの /etc/hosts ファイルに以下のルーティングを追加してください。

```
127.0.0.1 tobaba.42.fr
```

## 2. セットアップ (Setup)

環境変数を設定し、コンテナを起動する手順です 。

1. リポジトリのルートディレクトリにある srcs フォルダ内に .env ファイルを作成します。

2. .env ファイルに、データベースのパスワードやWordPressの管理者情報など、必要な環境変数を記述します（セキュリティ保護のため、Gitリポジトリにはコミットされません）。

3. ルートディレクトリで make または make all コマンドを実行します。

## 3. Makefile の使用方法 (Makefile Usage)

ルートディレクトリに配置された Makefile を使用して、コンテナのライフサイクルを管理します 。

- make または make all

  - ホストマシン上にデータを永続化するためのディレクトリ（/home/tobaba/data/mariadb および /home/tobaba/data/wordpress）を自動作成します。

  - docker compose を使用してイメージをビルドし、コンテナをバックグラウンド（デタッチモード）で起動します。

- make down

  - 実行中のコンテナ、および作成されたネットワークを安全に停止・削除します。データボリュームは保持されます。

- make clean

  - make down の処理に加え、Docker内のボリューム（Volume）も削除します。

- make fclean

  - 環境を完全に初期化する強力なコマンドです。

  - make clean を実行後、docker system prune -af で未使用のイメージやキャッシュを全削除します。

  - さらに、ホストマシンのデータ保存ディレクトリ（/home/tobaba/data）を sudo rm -rf で物理的に完全消去します。※データがすべて消えるため実行には注意してください。

- make re

  - make fclean を実行して環境を完全に更地にした後、再度 make all を実行してクリーンな状態から立ち上げ直します。

## 4. 便利なコマンド (Useful Commands)

開発やデバッグの際に役立つコマンド一覧です 。
- コンテナの状態確認
```cd srcs && docker compose ps```

## 5. データの永続性 (Data Persistence)

本プロジェクトでは、コンテナが再起動または破棄されてもデータが失われないよう、ホストマシンへの名前付きボリューム（Named Volume）を利用してデータを永続化しています 。

データの実体は、ホストマシンの以下のパスに保存されます。

- データベース（MariaDB）のデータ:
    /home/tobaba/data/mariadb
    (コンテナ内の /var/lib/mysql と同期)

- Webサイト（WordPress）のデータ:
    /home/tobaba/data/wordpress
    (コンテナ内の /var/www/html と同期)

これにより、VMの再起動や make down を行っても、次回起動時に既存の投稿データやアカウント設定がそのまま復元されます。