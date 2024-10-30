(chapter_database_coupling)=
# データベース連携

TF6420 データベースサーバを通じた時系列データベースへの記録機能は、{ref}`chapter_influxdb` の章でご紹介しています。ここで用いるPLCのライブラリ {ref}`section_influxdb_plc_library` と連携し、イベントの発生・解除時とその時刻、テキストをデータベースへ記録させることができます。

これにより、次図の通りGrafana等のオープンソース可視化ライブラリにアラームの発生、解除の推移をバーグラフで可視化したり、イベント履歴をCSVへエクスポートするなどをブラウザ上から操作いただけます。

![](../influxdb/assets/alarm_log.png){align=center}

{ref}`chapter_influxdb` 時系列データベースは、EtherCATで収集した高速高密度データをその密度のまま記録し、ブラウザに可視化することができます。ここに、機械系のアラームイベントを関連付けて表示させると故障停止に至った原因をいち早く特定し、即座に是正することが期待できます。

たとえば、次図の例ではモーションの位置、速度などの時系列データ上にアラームイベントが発生した時点をマークしています。無人で稼働している装置が異常停止した場合でも、どのような状況で停止したのか現場で後から把握することができます。

![](../influxdb/assets/xts_log.png){align=center}

# 実装方法

{ref}`chapter_influxdb` 章の実装に従い、次の通り実装を行います。

1. データベース記録用のタスクと実制御タスクに分けます。
2. グローバル変数にてデータベース接続FBインスタンスを作成します。
3. データベース記録用タスクのプログラムにて、2で作成したデータベース接続FBインスタンスを実行します。

    ```{note} 
    ここまでは{ref}`chapter_influxdb` 章で紹介する時系列データ記録用の接続FBの作成方法と同一です。他の時系列データと併せて、このグローバル変数で定義したデータベース接続FBインスタンスを共用します。
    ```

4. データベース接続FBインスタンスを、コンストラクタ引数に与えた`FB_AlarmDBExporter`インスタンスを作成します。

5. `FB_AlarmDBExporter`インスタンスにデータベース記録時に判別できる装置名称をセットします。

6. アラーム集計用のFB`FB_AlarmCalculator`のexporterプロパティを使って、`FB_AlarmDBExporter`インスタンスをセットします。

7. アラーム集計用のFB`FB_AlarmCalculator`の実行時に、登録したアラームの発生、解除イベントの記録がデータベースに対して行われます。


```{code-block} iecst
:caption: グローバル変数リスト`GVL`へデータベース接続FBを定義

{attribute 'qualified_only'}
VAR_GLOBAL CONSTANT
    // Database ID
    TARGET_DBID : UINT := 1;
END_VAR
VAR
    (* For IoT *)
    // Cycle record data
    fbInfluxDBRecorder    :RecordInfluxDB(DBID := GVL.TARGET_DBID); // データベースコネクタFBインスタンス。他の
END_VAR
```

専用タスクにてデータベース接続FBのインスタンスを実行します。接続先データベースにつき一つだけ実行します。

```{code-block} iecst
:caption: 専用タスクにてデータベース接続FBの実行

// Database driver by TF6420
GVL.fbInfluxDBRecorder();
```

実制御タスクにおいて作成したアラーム集計FBに、データベースエクスポートFBインスタンスをセットします。

```{code-block} iecst
:caption: 実制御タスク内でのアラーム集計部

PROGRAM MAIN
VAR
    // Alarm calculation function block
    alarm_calculator    : FB_AlarmCalculator;    // アラーム集計FB
    alarm_db_listener   : FB_AlarmDBListener(GVL.fbInfluxDBRecorder); // DBエクスポートFBインスタンス
END_VAR

// Initialize alarm event calculatror and IoT service
alarm_db_listener.machine_name := 'Machine-1'; // データベース記録時の装置名を定義
alarm_calculator.lang_code := 1031; // InfluxDBの場合は英語のみ対応なので、必ず1031とします。
alarm_calculator.add_listener(alarm_db_listener); // DBエクスポートFBインスタンスを集計FBに登録
  :
  :
alarm_calculator(); // アラーム集計用のFBインスタンス実行
```

