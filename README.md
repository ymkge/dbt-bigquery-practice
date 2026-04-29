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
新しい dbt プロジェクトを作成します（すでに作成済みの場合はこのステップをスキップしてください）。

```bash
dbt init your_project_name
```

対話形式のプロンプトでは、以下の設定を推奨します：
- **Database (adapter)**: `bigquery`
- **Authentication method**: `oauth`
- **Project ID**: `<your-gcp-project-id>` (自身のプロジェクト ID を入力)
- **Dataset**: `dbt_dev` (開発用データセット名)
- **Threads**: `4`
- **Desired location**: `asia-northeast1` (または `US`)

### 接続確認
プロジェクトディレクトリに移動し、接続を確認します。

```bash
cd your_project_name
dbt debug
```

## 4. データの準備 (Seeds)

dbt の `seed` 機能を使用して、`data/` ディレクトリ配下にある CSV ファイルを BigQuery のテーブルとしてロードします。

```bash
dbt seed
```

## 5. モデルの作成と実行 (Run)

SQL を使用してデータモデルを構築します。

- **Staging層**: 元データのクレンジングと型変換を行います。
- **Marts層**: ビジネスロジックを適用し、分析用のテーブルを作成します。

```bash
# stagingモデルのみを実行する場合
dbt run --select staging

# 全てのモデルを実行する場合
dbt run
```

## 6. テストとドキュメント

### データ品質テスト
一意性や非空などの制約をチェックします。

```bash
dbt test
```

### ドキュメントの生成
リネージ図を含むドキュメントを生成し、ローカルサーバーで確認できます。

```bash
dbt docs generate
dbt docs serve
```

## 7. プロジェクト構成のベストプラクティス

本プロジェクトは以下の構造に従うことを推奨しています：
- `models/staging/`: ソースデータ 1 対 1 のクレンジング層。
- `models/marts/`: ビジネスドメインごとに整理された分析層。
- `tests/`: 汎用テスト以外のカスタムデータテスト。
- `macros/`: 再利用可能な SQL ロジック。

## ライセンス

このプロジェクトは [MIT License](LICENSE) の下で公開されています。
