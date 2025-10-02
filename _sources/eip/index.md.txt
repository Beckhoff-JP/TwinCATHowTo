# EtherNet/IP による通信

## 制限事項

通信データとして取り扱う事ができるデータサイズには以下の制限事項があります。あらかじめご承知ください。

### 接続方法

TwinCATでEtherNet/IP通信を行う接続方法には、次の2つの方法があります。

* EL6652 / EL6652-0010 によりEtherCATを経由したELターミナルによる接続を行う
* TF6280 / TF6281 によりIPCのリアルタイムEthernertドライバを使った接続を行う

ELターミナルによる接続方法の場合、EtherCATによる1フレーム1500bytesの制限を受けます。とくに Scanner として機能するEL6652をお使いの場合、接続可能なAdapterの総バイト数が1500bytesに限られますので、大きな制約となります。

一方、TF6280はこれらの制約を受けませんので、接続数に制限はありません。よってより効率的な通信を行う場合、IPCのリアルタイムEthernetドライバを用いた通信（TF6280 / TF6281）をご利用ください。

### コネクション辺りのフレームデータサイズ

まず第一に、TwinCAT TF6280および、EL6652はどちらもCIPの拡張仕様であるLarge Forward Open（1コネクション辺りの最大データサイズを1444Byteまで拡張するオプション仕様）に対応しておりません。したがって、アダプタとのコネクション辺り、最大502Byteのメッセージの制限があります。

Large Forward Openに対応しない場合、各メーカでEtherNet/IPのコネクション辺りのフレーム最大データサイズが異なります。Adapter機器によっては、日本のPLCの制限に併せて503 Byteのコネクション設定となっているものがあります。この場合、弊社のスキャナでは502Byteの制限を超えてしまい通信を行うことができません。機器メーカに問い合わせて他社スキャナの制限に合ったフレームサイズとしていただくためのファームウェアへ書き換え、そのEDSファイルを読み込ませる必要があります。

Beckhoff(EL6652, TF6280共通)
    : 502 Byte

Rockwell
    : 500 Byte
    : [https://literature.rockwellautomation.com/idc/groups/literature/documents/um/enet-um001_-ja-p.pdf](https://literature.rockwellautomation.com/idc/groups/literature/documents/um/enet-um001_-ja-p.pdf)

OMRON
    : 504 Byte
    : [https://www.fa.omron.co.jp/products/family/1995/specification.html](https://www.fa.omron.co.jp/products/family/1995/specification.html)

Keyence
    : 504 Byte
    : [https://www.keyence.co.jp/products/controls/plc-package/kv_nano/models/kv-nc1ep/](https://www.keyence.co.jp/products/controls/plc-package/kv_nano/models/kv-nc1ep/)

この節では、弊社IPCとKeyence KV-8000と相互に通信する設定について説明いたします。

```{toctree}

ipc_adapter
```