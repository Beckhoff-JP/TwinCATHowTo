(chapter_timescaledb)=
# TimescaleDB

TimescaleDB は、SQLデータベースであるPostgreSQLをベースとした時系列データベース拡張です。SQLデータベースでありながら、時系列データベースの恩恵を受けられます。

[https://www.sraoss.co.jp/tech-blog/pgsql/timescaledb-intro/](https://www.sraoss.co.jp/tech-blog/pgsql/timescaledb-intro/)

TF6420では、PostgreSQLのドライバを用いて、SQL Expertモード、PLC Expertモードの両方が使えます。

PLC Expertモードで一括インサートする例
    : [https://infosys.beckhoff.com/content/1033/tf6420_tc3_database_server/4802034187.html?id=5764393926101237378](https://infosys.beckhoff.com/content/1033/tf6420_tc3_database_server/4802034187.html?id=5764393926101237378)


SQL Expertモードでインサートする例
    : [https://infosys.beckhoff.com/content/1033/tf6420_tc3_database_server/4830140043.html?id=3693341579483234407](https://infosys.beckhoff.com/content/1033/tf6420_tc3_database_server/4830140043.html?id=3693341579483234407)

SQL ExpertモードであればSQL文を記述することで、データベースの様々な機能をPLC側から操作することが可能です。一方、PLC Expertモードの場合、PLC側のデータ構造に基づいてクエリを発行します。1行づつではなく、bulk insertと呼ばれるまとまった行の一括書き込みが可能ですので、ディスクIOに対する遅延が最小化できます。

よってモーションなどの短いサイクルの時系列データを効率よくインサートするには、PLC Expertモードを用いて構造体配列のまとまりごとに記録する方法が用いられます。この方法はInfluxDBと同様の機能ですが、TimescaleDBがInfluxDBと異なるのはPostgreSQLを用いることからスキーマレスではないことです。データベースのテーブル構造をあらかじめ定義しておき、これに対応した型で変数を用意し、データセットする必要があります。

```{tip}
厳密にはSQL ExpertモードであってもSQL文でbulk insertは可能ですが、全てのデータを文字列に置き換える必要があるためあまり効率的ではありません。
```

ここでは、PLCのプログラムからTimescaleDBのデータテーブルスキーマを定義し、一括インサートする方法について示します。

```{toctree}
:caption: 目次

setup
createdb
plc_program
```