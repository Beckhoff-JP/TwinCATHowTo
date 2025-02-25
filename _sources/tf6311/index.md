# TF6311によるソケット通信

TF6311は、TwinCATのリアルタイムモジュールとして動作するソケット通信プログラムです。他の方法として、TF6310というソケット通信のミドルウェアがあります。こちらはADSを経由してWindows上のWinSockを用いた通信を行うため、Windowsのタスク制御の影響を受けて遅延が生じやすい傾向があります。

対してTF6311は、ファイヤウォール機能などのWindowsのセキュリティフレームワークの恩恵は受けられないものの、リアルタイムEthernetドライバを用い、TwinCATのリアルタイムタスクとしてデータフローを制御するため、高速な通信が可能になっています。

この章では、TF6311を用いたサンプルコードおよび、その使い方について説明します。

参考にするサイトは以下のとおりです。

[https://infosys.beckhoff.com/content/1033/tf6311_tc3_tcpudp/index.html?id=9004581143610845071](https://infosys.beckhoff.com/content/1033/tf6311_tc3_tcpudp/index.html?id=9004581143610845071)


## サンプルコードの説明

最初にダミーサーバとしてPythonにてバイトデータを交換するシンプルなUDPサーバを用意します。また、TwinCAT側については、以下のサイトで掲載されているサンプルコードをベースにしたクライアントソフトを実装します。この間で相互に通信するデモ環境を構築することを目指します。

[https://infosys.beckhoff.com/content/1033/tf6311_tc3_tcpudp/1077365387.html?id=5050344951114154524](https://infosys.beckhoff.com/content/1033/tf6311_tc3_tcpudp/1077365387.html?id=5050344951114154524)

詳細は後述しますが、上記サンプルコードはUDPメッセージをそのまま返す、「エコーサーバ」として機能する仕様です。本章ではこれをベースに改造することで、任意の構造体変数に送受信データをマッピングできる仕様とします。

```{toctree}
:hidden:

driver_setup.md
udp_server.md
udp_client.md
```
