(section_event_logger_plc_api)=
# PLC API

TwinCATにより提供されているEvent loggerをPLCから操作するためのファンクションブロック群（[PLC API](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/4278601739.html?id=3417159432122857710)） についての説明です。この中には、TwinCAT 3.1 Build 4026からしかサポートされていないものがあります。ここでは、Build 4024以下でサポートされているものに限定してご紹介します。また、一般的なアラーム管理に必要なファンクションブロックのみピックアップしてご紹介します。

[FB_TcAlarm](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/5001926923.html?id=6291374471499984104)
    : 登録したイベントクラスの個々のアラームイベントを実体化するために使われます。このオブジェクトからアラームの発報、確認、リセットの各種操作を行います。このファンクションブロックのインスタンス自身は土台（ファンデーション）であり、`Create` や `CreateEx` メソッドを用いてイベントクラスの任意のイベントを構築してから使用します。
     `FB_TcEventBase` を基底クラスとしています。

[FB_TcEvent](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/5002372619.html?id=7725123817245952346)
    : オブザーバファンクションブロック `FB_ListenerBase2` のコールバックメソッドである、`OnAlarm***` や `OnMessage****` が呼び出された際に引数に渡されるオブジェクトです。このオブジェクトは `FB_TcAlarm` や `FB_TcMessage` の中身データをコピーしたもので読取専用です。オブジェクトそのものをコピーすることはできず、要素を取り出してコールバックメソッド内でデータ処理する必要があります。また、このオブジェクトはシングルトンです。参照やポインタ等を用いて永続化することができません。
     `FB_TcEventBase` を基底クラスとしています。

[FB_ListenerBase2](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/5001704075.html?id=3592780376884092610)
    : `FB_TcEventFilter` にて定義したフィルタ条件に従い購読（Subscribe2メソッド実行）すると、購読対象の個々のアラームが発生（Raised）、確認（Confirmed）、解除（Cleared）されるたびに各種コールバックメソッドが実行されます。

[FB_TcEventFilter](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/9956773131.html?id=4163773038711954788)
    : `FB_ListenerBase2` の `Subscribe2` メソッドに渡す購読するイベントのフィルタ条件オブジェクトです。フィルタ設定用のAPIの解説がInfoSysでは十分ではありません。ほとんどのケースでは、該当するEventClass（GUID）の全てのイベントを購読する設定で問題がないので、以下の通り実装すれば良いものとします。
    : ```{code-block} iecst
      VAR_INPUT
        event_class : GUID;
      END_VAR
      VAR
        fbListenerFilter : FB_TcEventFilter;
      END_VAR

      // define all events (messages and alarms) from this eventclass  
      fbListenerFilter.Clear().EventClass.EqualTo(event_class);
      ```

[FB_RequestEventText](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/5001250443.html?id=6556863650656521231)
    : イベントクラスにて定義されるテキストは、基本テキストとArgumentsです。`Request`メソッドにて、対象のイベントIdと`FB_TcArguments` のインスタンスを読み込み、`GetString` メソッドでEvent loggerデータベースからADSを経由して文字列を取得します。`GetString` メソッドについては文字列を取得完了するまで連続実行が必要ですので、遅延処理が必要です。`FB_ListenerBase2` によりSubscribeしたアラームが同時に複数発生した場合でも個々に文字列取得完了を待つ必要があります。

[FB_TcArguments](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/5002149771.html?id=8160749167228356488)
    : イベントの Display Textには、最大1024Byteまでの128個の引数を与えて、固定のアラームテキストではなく、動的なテキストを付加することができます。この仕組みを [Arguments](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/5057915915.html?id=6571176282907083451) といいます。この Arguments オブジェクトを作成するためのファンクションブロックです。
    : ![](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/Images/png/5248992779__Web.png)
    : ![](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/Images/png/5248997259__Web.png)


