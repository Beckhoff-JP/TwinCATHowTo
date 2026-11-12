(chapter_ads)=
# ADS通信

TwinCATの各モジュール（TwinCAT PLC、ユーザーHMIなど）を独立したデバイスとして扱うことができます。各タスクには、それぞれ対応するソフトウェアモジュール（「サーバー」または「クライアント」）が存在します。

各サーバとクライアント間は「メッセージルータ」によって、統一されたADS（Automation Device Specification）インターフェースを介してメッセージが交換されます。メッセージルータは、同一TwinCATシステム同士のメッセージ交換と、異なるメッセージルータに対するTCP/IP接続を管理し、相互にメッセージ配信します。


![](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/Images/png/27021597880394123__en-US__Web.png){align=center}


## TCPソケットにおけるADSメッセージコマンド

ADSコマンドにはAMSヘッダと呼ばれるアプリケーション層のメッセージヘッダを持ちます。

![](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/Images/png/18014398625375371__Web.png){align=center}

{bdg-link-primary-line}`参考：InfoSys <https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115847307.html?id=7738940192708835096>`

### AMS Net IDとADSポート

AMS Net IDは、ADSルータやEtherCATメインデバイスなど、ADSの宛先を示す6byteのアドレスです。

![](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/Images/png/18014398625377803__Web.png){align=center}

また、ADSルータ内のリアルタイムTwinCATモジュールには、個々にADSポートと呼ばれる固有の番号が割り振られています。たとえばモーション機能であるNC Task SAFであれば 501, PLC機能であれば 851 などです。

{bdg-link-primary-line}`参考：InfoSys <https://infosys.beckhoff.com/content/1033/tc3_ads_intro/116159883.html?id=6824734840428332798>`

### コマンドの種別

ADSのコマンドシーケンスは大きく分けて次の通り2つの方式に分けられます。

非同期通信（Read/Write）
    : クライアントがサーバーにADSリクエストを送信します。クライアントは（ADS確認なしで）動作を継続します。サーバーはADSリクエストを処理し、コールバック（クライアントへのADS確認）によって結果をクライアントに返します。このとき、AMSヘッダの　`Inboke Id` の部分により元のコマンド正しく処理されたかどうかを判定することができます。

通知（Notification）
    : クライアントは、特定のサービスに対するADSリクエストをサーバーに送信して自身を登録します。サーバーは、クライアントがサービスリクエストをキャンセルするまで、コールバック（クライアントへのADS確認）によってクライアントにサービスを自律的に提供します。この通信方式の利点は、クライアントプログラムからの周期的なADSリクエストが発生しないため、ADSプロトコルのオーバーヘッドが少ないことです。

個々のADSコマンドのデータ構成は次のとおりです。

```{csv-table}
:header: Cmd, Description

0x0000, Invalid
0x0001, [ADS Read Device Info](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115875851.html)
0x0002, [ADS Read](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115876875.html)
0x0003, [ADS Write](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115877899.html)
0x0004, [ADS Read State](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115878923.html)
0x0005, [ADS Write Control](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115879947.html)
0x0006, [ADS Add Device Notification](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115880971.html)
0x0007, [ADS Delete Device Notification](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115881995.html)
0x0008, [ADS Device Notification](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115883019.html)
0x0009, [ADS Read Write](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115884043.html)
```

このコマンドでは、変数名を指定するのではなく、Index GroupやIndex Offsetという単位でTwinCAT内のリソースとそのアドレスを指定し、データの送受信を行います。

PLCであれば [このページ](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/117243403.html?id=2409311683675911548) にメモリエリアの解説があります。とくに、変数に対してバイトアドレス単位である`AT%M`やビットアドレス単位である`AT%MX`で指定されたアドレスが格納されます。

これらのアドレスは、`AT%M`や`AT%MX`等でアドレスを明示しない限りビルドによって変動します。
2.0 (Offs: 440006.0)

```{toctree}
:caption: 目次

ads_routing
devtools
../ads_plc/index
../ads_python/index
../powershell_data_edit/powershell
../ads_over_mqtt/dotnet
```