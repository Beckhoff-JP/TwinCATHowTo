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

## サンプルコード

TwinCATがクライアント、Pythonのダミーサーバで通信するサンプルコード
    : [https://github.com/Beckhoff-JP/tf6310_client_sample](https://github.com/Beckhoff-JP/tf6310_client_sample)