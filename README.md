# dbt-BigQuery Hands-on Tutorial

このリポジトリは、Google Cloud BigQuery をデータウェアハウスとして使用し、dbt (data build tool) の標準的な開発フローを学習するためのハンズオンガイドです。

## 概要

dbt を使用して、BigQuery 上でデータの変換（ELT）を行う際の手順をステップバイステップで解説します。本チュートリアルでは、dbt 公式のサンプルプロジェクトである `jaffle_shop` のデータ構造を参考に、BigQuery への接続からモデル作成、テスト、ドキュメント生成までを体験します。

## 0. 前提条件

- **Google Cloud プロジェクト**: 管理者権限（または BigQuery 管理者権限）を持つプロジェクトが必要です。
- **Google Cloud CLI (`gcloud`)**: ローカルマシンにインストールされ、認証が済んでいること。
- **Python**: 3.9 以上のバージョンがインストールされていること。

## 1. 環境構築

依存関係を分離するために仮想環境を作成し、必要なライブラリをインストールします。

```bash
# 仮想環境の作成と有効化
python3 -m venv venv
source venv/bin/activate

# 依存ライブラリのインストール
pip install -r requirements.txt
```

## 2. Google Cloud 認証

ローカル環境の dbt が BigQuery に安全にアクセスできるように、アプリケーション・デフォルト認証 (ADC) を設定します。

```bash
gcloud auth application-default login
```

※ 実行後、ブラウザが開きログインを求められます。使用する Google Cloud プロジェクトにアクセス権のあるアカウントを選択してください。

## 3. dbt プロジェクトの設定

### プロジェクトの初期化
新しい dbt プロジェクトを作成します。

```bash
dbt init your_project_name
```

対話形式のプロンプトでは、以下の通りに入力・選択してください：
1. **Which database would you like to use?**: `1` (bigquery)
2. **Desired authentication method**: `1` (oauth)
3. **Project ID**: `あなたのプロジェクトID` (※注意参照)
4. **Dataset**: `dbt_dev`
5. **Threads**: `4`
6. **Job execution timeout seconds**: `300`
7. **Desired location**: `1` (US) または `asia-northeast1`

> [!IMPORTANT]
> **Project ID についての注意**
> GCP コンソールに表示される「プロジェクト名（例: my project）」ではなく、**「プロジェクト ID（例: sharp-crossbar-123456）」**を入力してください。プロジェクト ID は GCP コンソールのダッシュボードや、`gcloud projects list` コマンドで確認できます。

### 接続のトラブルシューティング

#### 'NoneType' object has no attribute 'close' エラー
`dbt debug` でこのエラーが出る場合、OAuth 認証の接続設定が不足している可能性があります。以下の手順で `profiles.yml` を直接修正するのが最も安全です。

1. dbt の設定ファイルを開きます：
   `nano ~/.dbt/profiles.yml`
2. 対象のプロファイルの `outputs -> dev` セクションに `compute_region: US` (または使用しているリージョン) を追記し、`project` ID が正しいか確認します。

```yaml
your_project_name:
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: your-project-id  # プロジェクト名ではなくID
      dataset: dbt_dev
      location: US
      priority: interactive
      threads: 4
      compute_region: US  # ← 接続エラーが出る場合に追記
```

## 4. データの準備 (Seeds)

dbt の `seed` 機能を使用して、CSV ファイルを BigQuery のテーブルとしてロードします。

```bash
# seeds ディレクトリに移動
cd your_project_name/seeds

# サンプルデータの取得 (jaffle_shop)
curl -O https://raw.githubusercontent.com/dbt-labs/jaffle_shop/main/seeds/raw_customers.csv
curl -O https://raw.githubusercontent.com/dbt-labs/jaffle_shop/main/seeds/raw_orders.csv
curl -O https://raw.githubusercontent.com/dbt-labs/jaffle_shop/main/seeds/raw_payments.csv

# プロジェクトルートに戻ってロード実行
cd ..
dbt seed
```

## 5. モデリングフロー

dbt のベストプラクティスに基づいたレイヤー構造でモデルを構築します。

### ステップ 1: Sources の定義
`models/staging/src_jaffle_shop.yml` を作成し、元データを定義します。

### ステップ 2: Staging モデル (クレンジング)
`models/staging/stg_customers.sql` を作成し、型変換やリネームを行います。
- 参照方法: `{{ source('jaffle_shop', 'raw_customers') }}`

### ステップ 3: Marts モデル (ビジネスロジック)
`models/marts/dim_customers.sql` を作成し、Staging モデルを組み合わせて分析用テーブルを作成します。
- 参照方法: `{{ ref('stg_customers') }}`

```bash
# モデルの実行
dbt run
```

## 6. テストとドキュメント

### データ品質の検証
`schema.yml` にテストを記述し、データの整合性をチェックします。

```bash
# テストの実行
dbt test

# 特定のモデルのみテストする場合
dbt test --select stg_customers
```

### ドキュメントとリネージ図
SQL から自動生成されるドキュメントと、モデル間の依存関係図（リネージ）を確認します。

```bash
dbt docs generate
dbt docs serve
```

## 7. 開発のベストプラクティス (Tips)

- **Source -> Staging -> Marts**: 直接ソースを参照せず、必ず Staging 層を経由させることで、ソースの変更に強い構成になります。
- **DRY (Don't Repeat Yourself)**: 共通のロジックはマクロ (`macros/`) に抽出しましょう。
- **テストの習慣化**: `unique` と `not_null` は主要なカラムに必ず設定することを推奨します。

## ライセンス

このプロジェクトは [MIT License](LICENSE) の下で公開されています。
