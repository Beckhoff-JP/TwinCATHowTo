# TF6310によるソケット通信

この章では、TF6310を用いたサンプルコードおよび、その使い方について説明します。
参考にするサイトは以下のとおりです。

[https://infosys.beckhoff.com/content/1033/tf6310_tc3_tcpip/index.html?id=9025637582166106076](https://infosys.beckhoff.com/content/1033/tf6310_tc3_tcpip/index.html?id=9025637582166106076)

## 準備

TF6310は、WindowsのソケットAPIを通じてソケット通信を行います。ADS通信によりTwinCAT PLCにWindowsソケットの機能を提供するサーバを別途インストールする必要があります。

次のソフトウェアをIPCにインストールしてください。

4024の場合
    : 次のURLから`Documentation and downloads` > `Software and tools` > `TF6310 | TwinCAT 3 TCP/IP` をダウンロードしてインストールしてください。

      [https://www.beckhoff.com/ja-jp/products/automation/twincat/tfxxxx-twincat-3-functions/tf6xxx-connectivity/tf6310.html](https://www.beckhoff.com/ja-jp/products/automation/twincat/tfxxxx-twincat-3-functions/tf6xxx-connectivity/tf6310.html)

4026の場合
    : パッケージマネージャより次の通りインストールしてください。
      ```{code} powershell
      C:\ > tcpkg install TF6310.TcpIp.XAR  # ターゲットIPCのランタイム側
      C:\ > tcpkg install TF6310.TcpIp.XAE  # 開発環境側
      ```

      ```{attention}
      さらに Usermode runtimeをお使いの場合、Infosys の以下の節にある Usermode runtimeサーバの設定を行ってください。
      
       [TC170x | TwinCAT3 Usermode Runtime - Integration TwinCAT Functions](https://infosys.beckhoff.com/content/1033/tc170x_tc3_usermode_runtime/15569027467.html?id=8389318871453170433)
      ```

## サンプルコード

TwinCATがクライアント、Pythonのダミーサーバで通信するサンプルコードをGithubで公開しています。

[https://github.com/Beckhoff-JP/tf6310_client_sample](https://github.com/Beckhoff-JP/tf6310_client_sample)

こちらの README を読んでお試しください。通信スタックとして TwinCAT 側 のフレームワークについては次節より説明します。

## フレームワーク解説

TF6310が提供するソケット通信のAPIは{numref}`table_tf6310_fb`のとおりです。

```{csv-table} TF6310のファンクションブロックの種類
:header: ファンクションブロック,状態遷移,説明
:name: table_tf6310_fb

FB_SocketConnect,SYN_SENT,サーバへ接続
FB_SocketClose,"FIN_WAIT, CLOSE_WAIT",接続済みのソケットを閉じる
FB_SocketListen,LISTEN,クライアントからの接続要求を待ち受ける
FB_SocketAccept,SYN_RECEIVED > ESTABLISHED,クライアントからの接続要求を受け付けた
FB_SocketSend,ESTABLISHED,データ送信
FB_SocketReceive,ESTABLISHED,データ受信
```

リクエストメッセージ - レスポンスメッセージ というシンプルなコマンドインターフェースを提供するサーバに対する通信クライアントを実装する場合、通常は次の手順を実行するプログラムを実装します。

```{csv-table} 通信手順例 : シンプルな リクエスト - レスポンス モデル
:header: 手順, 使用するFB, 処理内容
:name: table_communication_sequence

1,FB_SocketConnect, LISTENしているサーバへの接続
2,FB_SocketSend, 送信したいリクエストメッセージを送る
3, , サーバから応答メッセージが返ってくる
4,FB_SocketReceive, 受信用ファンクションブロックを実行。受信したバイト列がバッファに溜まっているので、そのデータを取り出す。
5,, バッファにたまったデータをチェックして、期待通りであれば完了。未完了であれば4へ戻る。
6,FB_SocketClose, サーバとのソケットを切断する
```

サーバが提供するコマンドの種類が少ない場合、この手順のままベタにプログラムを書けば良いのですが、現実には極めて多種多様なコマンドとそのデータフォーマットが規定されているケースが多いでしょう。このような場合、コマンドの種類毎に上記の手順を実行するプログラムを書くと通信ソフトウェアのボリュームだけで大きいものになってしまい、そのテスト工数も多大なものになってしまいます。

これを避けるため、通信手順を定義する **{ref}`section_communication_sequence_def_model`** と、 **{ref}`section_protocol_def_model`** を分けて実装できるようにしました。

(section_protocol_def_model)=
### 通信プロトコル定義モデル

通信プロトコルとは、コマンド毎の送信するリクエストメッセージ、受信するレスポンスメッセージそれぞれのフォーマットの違いを定義するものです。通信シーケンスの中ではこれらの違いを吸収して共通処理とするため、インターフェースを通じて処理を行います。

{numref}`figure_command_sequence` は通信手順を示すものですが、その中で送信するメッセージは、 `ITF_Sender` を経て受け取ります。また、受信する際にバッファに溜まったバイトデータがどこまで揃えば完了とみなすのか、という判断や、そのバイトデータを、TwinCAT PLC内部のデータモデルにマッピングするパース処理を行う機能を、`ITF_Receiver` 通じて行います。
 
```{figure} assets/2025-10-02-00-30-39.png
:align: center
:width: 450px
:name: figure_command_sequence

通信手順
```

```{list-table}

- * 送信処理（ITF_Sender）
  * SendDataプロパティ
      : 送信したいバイト列のデータを取得
- * 受信処理（ITF_Receiver）
  * SetReceivedData() メソッド
      : FB_SocketReceive()実行により取り出した受信バイト列をバッファ領域に蓄積する。

    Receivedプロパティ
      : 蓄積された受信データを解析して受信完了条件を満たしたかどうか判定して結果を返す。

    Parse()メソッド
      : 蓄積された受信データをTwinCATのネイティブな構造体変数へマッピングする。
- * 進捗管理処理（ITF_TaskObserver）
  * キューによる非同期処理のため下記を通じて通信進捗を観察
    * コマンドの現在実行ステップ
    * エラーとエラーコード通知
    * 全シーケンス完了通知
```

この3つのインターフェースを実装したプロトコルオブジェクトを実装します。（{numref}`figure_protocol_model`）

```{figure} ./assets/twincat_socket_communication_model.png
:align: center
:name: figure_protocol_model

Protocolモデルクラス図
```

基本的に、`FB_ProtocolBase` に必要不可欠なメソッドは実相されていますので、ユーザはこれを継承した独自のFBを定義します。（{numref}`figure_protocol_model` の `FB_UserDefinedProtocol` 部分）オーバライドするアクセサは、送信メッセージを取り出す `SendData` プロパティと受信完了条件でTRUEを返す `received` プロパティ、そして、受信バイト列からPLC内の構造体変数などのネイティブデータ型へマッピングする `Parse()` メソッドです。

```{tip}
今回は リクエストメッセージ - レスポンスメッセージ というシンプルな通信手順に合わせて、送信、受信メッセージを多重継承した単一のプロトコルFBを定義しました。しかし、通信手順から独立したメッセージプロトコル定義を行うのであれば、`ITF_Receiver` と `ITF_Sender` と `ITF_Observer` は個別のファンクションブロックで実装する方が良いかもしれません。

とくに `ITF_Observer` は手順を監視する責務を負うので、次節で説明する通信手順定義モデルに包含する方が良いかもしれません。いずれ設計見直します。
```

(section_communication_sequence_def_model)=
### 通信手順定義モデル

ここでは前節で定義した {ref}`section_protocol_def_model` を用いて、{numref}`figure_command_sequence` にあるような通信手順を実行するモデルを定義します。実際の通信シーケンスが定義されているファンクションブロックは `FB_SocketClientController` です。（{numref}`figure_communication_sequence_model`）

```{figure} ./assets/framework_usage_model.png
:align: center
:name: figure_communication_sequence_model

通信手順モデル
```

ただ、通信処理中、PLCのリアルタイム処理において新たなコマンドが発行されるかもしれません。よって通信処理とコマンドリクエストを非同期化するため、`FB_SocketClientController` 内部には、FIFOキューオブジェクト  `FB_MessageQueue` を内包しています。このキューは、`queue` プロパティで参照することができます。

このオブジェクトでキューイングするデータは、`ITF_Sender` と `ITF_Receiver` をパックした構造体 `ST_CommandContainer` です。キュー内部にこのデータ型の配列を持ち、リングバッファを使ってFIFO処理しています。

```{code} iecst
TYPE ST_CommandContainer :
STRUCT
  sender : ITF_Sender;
  receiver : ITF_receiver;
END_STRUCT
END_TYPE
```

これらのキューに備えられた次のメソッドを使ってキューインキューアウトします。

キューイン : put(ITF_Sender, ITF_Receiver)
  : {ref}`section_protocol_def_model`で作成したプロトコルモデルのファンクションブロックのインスタンスを引数に与えることで、コマンドをキューインします。多重継承しているため、二つの引数には同じインスタンスを指定します。そのあと、`ITF_Observer` も実装しているので、`complete` プロパティをウォッチして、TRUEになると、通信シーケンスが完了したことがわかります。また、このとき `error` がTRUEであればコマンドが正常終了しなかったことを示します。

キューアウト : get() : ST_CommandContainer 
  : 実際の通信シーケンスを制御する `FB_SocketClientController` がキューにコマンドがあることを検出するとこのメソッドを実行して、コマンド `ST_CommandContainer` を取り出します。これを基に {numref}`figure_command_sequence` の通信制御を実行します。

以上です。これらを実装することで通信手順と、メッセージモデルを分離してソフトウェア定義することができました。

```{admonition} 拡張性のある通信ソフトウェア
今回は、 リクエストメッセージ - レスポンスメッセージ というシンプルな通信手順でしたが、多段階に分けて送受信が行われるもっと複雑な手順が現れたとしても、 `ITF_Reciever`, `ITF_Sender`, `ITF_Observer` の個々のモデルの集合とみなせる訳ですから、容易に拡張可能です。

たとえば、何等かのサーバ側のソフトウェアバージョンアップで新たな通信手順が現れたとしても、それまでの通信手順を作り直す必要がありませんし、そのプロトコルだけ新たな通信手順定義モデルを追加すればよいだけです。

このように、オブジェクト指向を正しくデザインすると、変更に強いソフトウェアが実現できます。
```