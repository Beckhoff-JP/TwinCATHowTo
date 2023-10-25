(chapter_database)=
# TF6420 データベース

TF6420はTwinCAT上のデータをさまざまなデータベースに記録させることができるサービスソフトウェアです。データベースには主に次のタイプに分かれており、TF6420はこれらのデータベースに対応します。

SQLデータベース
    : 表形式のデータベース。SQLという共通の問い合わせ言語を用いてデータを読み書きしたり、テーブルやデータベースのメンテナンスが可能になっている。スキーマ（データの構造）をあらかじめ定義し、そのスキーマに沿ってデータを出し入れする場合はこのデータベースを用いる

NoSQLデータベース
    : KVS型
        : キーバリューストアでデータを格納。非常に高速に読み書きできるが、複雑なデータ構造は表現できない。

    : ドキュメント型
        : MongoDBなどJSON形式のツリーデータをそのまま格納できることが特徴。

    : 時系列型
        : InfluxDB に着目し、制御周期（50 $\mu s$ ～100$ms$）の高密度サイクルの時系列データを記録させる方法について説明します。

```{toctree}
:caption: 目次

../sql/index.md
../influxdb/index.md
```