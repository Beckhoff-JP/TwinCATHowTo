# シリアル通信

USBやシリアルポートといったハードウェアは、TF6340をお使いいただくことでPCのCOMポートにPLCから直接アクセスすることが可能です。

## シリアルポートデバイスの扱いとライブラリ準備

TwinCATでシリアル通信を行うには、次のように3つの方式のデバイスアクセスが可能です。（[参考InfoSys](https://infosys.beckhoff.com/content/1033/tf6340_tc3_serial_communication/84957579.html?id=826160511792033093)
）

![](https://infosys.beckhoff.com/content/1033/tf6340_tc3_serial_communication/Images/png/85954315__en-US__Web.png){align=center}

PC COMポート
    : OS側で容易されたシリアルデバイスにアクセスすることができます。

ELターミナル
    : EL60xxなどのバスターミナルを通じてEtherCAT経由でシリアル通信する方法です。

仮想シリアルポート
    : PCIに接続されたUARTデバイスではなく、USBシリアルデバイスなど、仮想的に作成されたOS上のシリアルデバイスにアクセスすることができます。

```{tip}
仮想シリアルポートを作成するためには、 [TF6340](https://www.beckhoff.com/ja-jp/products/automation/twincat/tfxxxx-twincat-3-functions/tf6xxx-connectivity/tf6340.html?) を別途インストールする必要があります。 
```

また、別途PLCライブラリをインストールすることでPLC上のIOデバイスとして取り扱うことができ、いったん、`ComBuffer` という通信データバッファ構造体を経由することで、3つのデバイス方式が違っていても同じPLCプログラムロジックでデータ送受信を行うことができます。

## 開発手順

まずはTwinCATでシリアルポートの受信データにアクセスする物理的なIOを作成します。

[参考InfoSys](https://infosys.beckhoff.com/content/1033/tf6340_tc3_serial_communication/85875723.html?id=6382383804496181965)

この物理IOにアクセスするには、TF6340パッケージを別途インストールしていただく必要があります。パッケージマネージャからTF6340を指定してインストールを実施してください。

インストール後、PLCプロジェクトにライブラリを追加します。

[参考InfoSys](https://infosys.beckhoff.com/content/1033/tf6340_tc3_serial_communication/396591499.html?id=2081309549300242125)

このライブラリには、`ComBuffer`という構造体が用意され、ここに蓄えられたデータをファンクションブロックを使って順次アクセスします。

[参考InfoSys](https://infosys.beckhoff.com/content/1033/tf6340_tc3_serial_communication/85871115.html?id=8195232895777850580)

このサイト例のとおり`PcComInData`、`PcComOutData` をそれぞれ先ほど作成したIOにリンクします。

`SerialLineControl` というファンクションブロックが、このIOを通じて、`RxBufferPcCom` 、`TxBufferPcCom` という変数の`ComBuffer`構造体にデータを蓄積していきます。

この`ComBuffer`を通じて、Send*** や、Receive***というファンクションブロックを使ってバッファに溜まったデータを直列化する、という流れになります。

[参考InfoSys](https://infosys.beckhoff.com/content/1033/tf6340_tc3_serial_communication/85865099.html?id=1229754603186087237)

[参考InfoSys](https://infosys.beckhoff.com/content/1033/tf6340_tc3_serial_communication/85884555.html?id=3522409791184920023)
