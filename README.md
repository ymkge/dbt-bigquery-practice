# dbt + BigQuery 実践ハンズオンガイド

このガイドでは、BigQueryをデータウェアハウスとして使用し、dbt (data build tool) の標準的な開発フローを体験します。

## 0. 前提条件
- Google Cloud プロジェクト (`aplab project`) が作成されていること
- Google Cloud CLI (`gcloud`) がインストールされていること
- Python 3.9以上がインストールされていること

---

## 1. 環境構築

まずは仮想環境を作成し、`dbt-bigquery` をインストールします。

```bash
# 仮想環境の作成と有効化
python3 -m venv venv
source venv/bin/activate

# dbt-bigqueryのインストール
pip install dbt-bigquery
```

## 2. GCP認証 (ADCの設定)

ローカル環境からBigQueryを操作するために、アプリケーション・デフォルト認証 (ADC) を設定します。

```bash
gcloud auth application-default login
```
※ブラウザが立ち上がるので、`aplab project` へのアクセス権限を持つアカウントでログインしてください。

---

## 3. dbtプロジェクトの初期化

`jaffle_shop_bq` という名前でプロジェクトを初期化します。

```bash
dbt init jaffle_shop_bq
```
- **Adapterの選択**: `bigquery` を選択
- **Authentication method**: `oauth` を選択
- **Project ID**: `aplab project` を入力
- **Dataset**: `dbt_dev` (または任意のデータセット名) を入力
- **Threads**: `4` (デフォルト)
- **Job execution timeout seconds**: `300` (デフォルト)
- **Desired location**: `asia-northeast1` (東京) または `US`

初期化後、プロジェクトディレクトリに移動します。
```bash
cd jaffle_shop_bq
```

---

## 4. データの準備 (Seeds)

dbtの `seeds` 機能を使って、サンプルCSVデータをBigQueryにロードします。

1. `jaffle_shop` のサンプルデータをダウンロード（または作成）して `data/` フォルダに配置します。
2. 以下のコマンドを実行します。

```bash
dbt seed
```
これで BigQuery 上に `raw_customers`, `raw_orders`, `raw_payments` などのテーブルが作成されます。

---

## 5. モデリング (Run)

### Staging層の作成
元データを整理するビューを作成します。`models/staging/` ディレクトリを作成し、SQLファイルを配置して実行します。

```bash
dbt run --select staging
```

### Marts層の作成
ビジネスロジックを適用した最終的なテーブルを作成します。

```bash
dbt run
```

---

## 6. テストとドキュメント

### テストの実行
データ品質（一意性、非空など）をチェックします。

```bash
dbt test
```

### ドキュメントの生成と表示
リネージ図を含むドキュメントを生成し、ローカルサーバーで確認します。

```bash
dbt docs generate
dbt docs serve
```

---

## 7. クリーンアップ
学習が終わったら、BigQuery上のデータセットを削除してコストを抑えましょう。
