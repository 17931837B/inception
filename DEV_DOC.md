# 開発者向けドキュメント (DEV_DOC.md)

## 1. アーキテクチャ概要 (Architecture Overview)

このインフラストラクチャは、カスタムブリッジネットワーク（`inception_network`）上で動作する3つの独立したDockerコンテナで構成されています。



### データフロー (Data Flow)
1.  **クライアント (Browser)**: `https://<USER_LOGIN>.42.fr` (ポート 443) へリクエストを送信。
2.  **NGINX コンテナ**: SSL/TLS 終端を行い、リクエストの内容を検査。
    * **静的ファイル**: 共有ボリューム（`wp_data`）から直接配信。
    * **PHPファイル**: **FastCGI** プロトコル経由で、内部ネットワークの **WordPress** コンテナ (ポート 9000) へ転送。
3.  **WordPress コンテナ**: PHPスクリプトを実行。データベース操作が必要な場合、**MariaDB** コンテナ (ポート 3306) へ接続。
4.  **MariaDB コンテナ**: SQLクエリを処理し、結果を返す。

---

## 2. 開発・ビルド環境 (Build & Environment)

### 前提条件
* Make
* `/etc/hosts` に `127.0.0.1 tobaba.42.fr` が設定されていること。

### コマンド (Makefile)
開発時に頻繁に使用するコマンド：

* `make up`: イメージのビルドとコンテナの起動（バックグラウンド）。
* `make down`: コンテナとネットワークの停止・削除。
* `make logs`: 全コンテナのリアルタイムログを表示（デバッグ用）。
* `make clean`: **全データ削除**。コンテナ、ネットワーク、イメージ、およびホスト側の永続化データ（ボリューム）を消去し、初期状態に戻す。

---

## 3. 技術詳細と評価対策 (Technical Details & Defense Points)

評価（Defense）で聞かれる可能性が高い技術的なポイントと回答例です。

### Docker & Docker Compose

#### Q: なぜ `restart: unless-stopped` なのか？
* **回答**: 可用性を高めるためです。MariaDBなどが内部エラーでクラッシュした場合、自動的に再起動させます。
* **always との違い**: `unless-stopped` は、ユーザーが明示的に `docker stop` コマンドで止めた場合（メンテナンス時など）は、PC再起動後も「停止したまま」になります。`always` だとメンテナンス中でも勝手に立ち上がってしまうリスクがあります。

#### Q: PID 1 問題 (なぜ `daemon off;` が必要なのか)
* **回答**: Docker コンテナは「メインプロセス (PID 1) が終了すると、コンテナ自体も停止する」という仕様があるからです。
* **詳細**: NGINX や PHP-FPM はデフォルトでデーモン（バックグラウンド）として動作しようとしますが、そうすると PID 1 が即座に終了扱いになり、コンテナが落ちてしまいます。これを防ぐためにフォアグラウンドで実行させています。

---

### NGINX (Entrypoint)

* **役割**: リバースプロキシ & SSL終端。
* **重要な設定**:
    ```nginx
    location ~ \.php$ {
        fastcgi_pass app:9000;  # WordPressコンテナへ転送
    }
    ```
* **評価ポイント**:
    * **TLS v1.2/v1.3 Only**: `ssl_protocols` ディレクティブで、脆弱性のある古いプロトコル（SSLv3, TLSv1.0/1.1）を拒否しています。
    * **Port 80 無効化**: HTTP（非暗号化通信）を受け付けないことで、厳格なセキュリティ要件を満たしています。

---

### WordPress (Application)

* **役割**: PHP-FPM (FastCGI Process Manager)。**このコンテナには Apache や NGINX は含まれていません。**
* **自動構築 (WP-CLI)**:
    手動インストールではなく、`init-wp.sh` スクリプト内で `wp-cli` ツールを使用しています。
    1.  WordPress コアファイルのダウンロード。
    2.  環境変数に基づいた `wp-config.php` の生成。
    3.  管理者ユーザーと一般ユーザーの作成。
* **評価ポイント**:
    * **なぜポート 9000？**: PHP-FPM が FastCGI リクエストを受け付ける標準ポートだからです。このポートはホストマシンには公開せず（`ports` なし）、内部ネットワークのみに公開（`expose`）しています。

---

### MariaDB (Database)

* **役割**: リレーショナルデータベース。
* **初期化ロジック**:
    `init-mariadb.sh` スクリプトにて、データディレクトリ（`/var/lib/mysql/mysql`）の存在を確認します。
    * **存在しない場合**: `mysql_install_db` を実行して初期化し、ユーザー作成と権限付与を行います。
    * **存在する場合**: 既存データを保持するため、初期化処理をスキップします。
* **評価ポイント**:
    * **セキュリティ**: `docker-compose.yml` で `ports` を使用していません。これにより、外部（ホスト側）からの直接アクセスを遮断し、WordPress からのみアクセス可能な状態にしています。

---

## 4. データの永続化 (Data Persistence)

課題の要件である「Bind Mount (`-v host:container`) の禁止」と「ホストの特定パス (`/home/user/data`) への保存」という矛盾するルールを両立させるため、**Docker Named Volumes with Driver Options** を採用しています。

### 設定内容 (docker-compose.yml)

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/<USER_LOGIN>/data/mariadb  # ホスト側の物理パス