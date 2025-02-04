# データベースの作成

TimescaleDBのテーブルの作成方法は以下の手順に従います。

1. PostgreSQLのデータベースの作成
2. PostgreSQLのテーブル作成
3. 2.で作成したテーブルを、TimescaleDBのハイパーテーブルへ変換

## データベースの作成

最初に、PostgreSQLのデータベースを作成します。下記のコマンドの通りpsqlコマンドでPostgreSQLターミナルにログインします。

``` powershell
PS > psql -U postgres
Password for user postgres: <インストール時に設定した管理者パスワード>
psql (16.3)
Type "help" for help.
postgres=#
```

以下のSQL文を発行し、データベースを作成します。ここでは例としてデータベース名を、`machine_data`とします。

``` sql
postgres=# CREATE database machine_data;
CREATE DATABSE
```

続いて、`\c`コマンドにて作成した`machine_data`データベースに接続し、データベースが正しく作成されたか確認します。

``` sql
postgres=# \c machine_data 
You are now connected to database "machine_data" as user "postgres".
machine_data=# 
```

`\q`コマンドにより、いちどpsqlを終了します。

``` sql
machine_data=# \q
PS >
```

作成したデータベースに、TimescaleDBのエクステンションを有効にするクエリを発行します。

``` powershell
PS > echo "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;" | psql -U postgres -d machine_data
Password for user postgres: <インストール時に設定した管理者パスワード>
CREATE EXTENSION
PS >
```

## テーブル作成

```{code-block} sql
CREATE TABLE database_throughput (
    datetime BIGINT NOT NULL,
    db_insert_queue_count integer,
    current_index integer,
    next_index integer,
    buffer_usage real
);

-- ハイパーテーブル作成。1時間（マイクロ秒精度）毎にチャンクを分割する設定
SELECT create_hypertable('database_throughput', by_range('datetime', 3600000000));

-- 時刻列でのインデックス追加
CREATE INDEX ix_datetime ON database_throughput (datetime DESC);
```

````{note}
時系列データは通常、`timestamp`型を用いますが、[TF6420を通じて`timestamp`型の列にインサートするデータはPLCではDT（DATE_AND_TIME）型](https://infosys.beckhoff.com/content/1033/tf6420_tc3_database_server/7634767883.html?id=1343930976982488153)となります。[DT型は秒までの精度](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2529415819.html?id=7132877304198979715)しかありません。それよりも高い精度時刻を記録する場合は、`BigInt`型の列に対して、`ULINT`型（8byte）に格納したUNIX時間をセットします。UNIX時間は、1970-01-01 00:00:00を起点としたマイクロ秒精度のシリアル値です。このデータ形式であればPostgreSQLの`to_timestamp()` 関数を用いて簡単にtimestamp型の列を生成し、様々な時系列処理を行うことができます。

```{code-block} sql
SELECT to_timestamp(datetime::double precision / 1000000) as timestamp, * FROM public.database_throughput ORDER BY datetime DESC Limit 500
```

たとえば上記のクエリを発行すると以下の結果が得られます。datetime列には、PLCからUNIX時刻形式のシリアル値が格納されます。新たにtimestamp列に、timestamptz型の列が生成され、一覧されます。精度はマイクロ秒ですが末尾が1/1000秒未満の'0'の部分は丸められて表示されますのでこの例ではミリ秒（PLCサイクルタイム）単位でのデータが記録できていることがわかります。

```{csv-table}
"timestamp","datetime","db_insert_queue_count","current_index","next_index","buffer_usage"
"2024-06-01 04:02:42.229+00","1717214562229000",0,467,467,"0"
"2024-06-01 04:02:42.228+00","1717214562228000",0,466,467,"0"
"2024-06-01 04:02:42.227+00","1717214562227000",0,465,467,"0"
"2024-06-01 04:02:42.226+00","1717214562226000",0,464,467,"0"
,:
```

しかし、TwinCATはWindowsネイティブなOSですので、UNIX時間を提供するファンクションは提供されていません。デフォルトで高い精度の時刻型を扱う場合は、Windows Filetime時間（T_Filetime64型）と呼ばれる異なるシリアル値が用いられます。こちらは1601-01-01 00:00:00を起点とした100ns精度のシリアル値です。UNIX時間よりは高い精度を持つのですがデータベースシステム上では時刻の取り扱いが極めて困難です。よって、PLC内部で次のSTプログラムによりFiletime型をUNIX時刻型へ変換する必要があります。

```{code} iecst
METHOD Filetime_To_UnixT : ULINT
VAR_INPUT
	datetime : T_filetime64;
END_VAR

Filetime_To_UnixT := (datetime - 116444736000000000) / 10;
```
このコードは、ご紹介したライブラリ内の`FB_DatetimeUtilities`の中の`Filetime_To_UnixT`メソッドでご提供しています。

マイクロ秒未満の精度が必要となる場合は、TwinCATには、T_Filetime64型、1ナノ秒精度まで必要な場合はT_Dctime64型まで用意されており、いずれも8byteデータです。このため、データベース側にはBigInt列にそのまま記録することが可能です。データベースクエリを発行する際のアプリケーション側で時刻表現との間で相互にエンコード、デコードして運用してください。

````
