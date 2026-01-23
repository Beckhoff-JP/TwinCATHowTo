# TF6100 OPC UA Client

OPC UAのクライアント機能としては、次の2種類のラインナップがあります。

TF6100 OPC UA Client
    : ADSを通じてOS側のTCP/IPスタックを通じて通信する非リアルタイム通信でOPC UAのクライアント機能を実現します。

TF6105 OPC UA Client PubSub
    : TwinCATのリアルタイムネットワークドライバを用いて、UDPまたはMQTTを通じた高速なリアルタイム通信でOPC UAクライアント機能を実現します。

ここでは、TF6100 OPC UA Clientについて説明します。

```{list-table}
* - ![](https://infosys.beckhoff.com/content/1033/tf6100_tc3_opcua_client/Images/png/9007214807065739__Web.png){align=center}
  - ![](https://infosys.beckhoff.com/content/1033/tf6100_tc3_opcua_client/Images/png/9007215259482635__Web.png){align=center width=300px}
* - TF6100 OPC UA Serverと組み合わせて、クライアント接続を可能にします。
  - 物理IOと同様のデータツリーが再現され、PLCコード等の変数とリンクしてプログラミングできます。
```

## インストール

TwinCAT 3.1 Build 4024では、独立したインストーラがありましたが、4026からは、TF6105 PubSubと統合されたパッケージとなりました。次のコンポーネントを開発環境とランタイム個々にインストールしてください。

Engineering - TF610x | TwinCAT 3 OPC UA Client PubSub
    : 開発環境にインストールします。


Runtime - TF610x | TwinCAT 3 OPC UA Client PubSub
    : IPCにインストールします。

## 使用方法

まずIOのデバイスを作成します。OPC UAカテゴリには2つのデバイスありますが、リアルタイムドライバを用いてUDP IPやMQTTを用いて通信する`Real Time OPC UA Device`を用いるにはTF6105ライセンスが別途必要です。ここでは、TF6100ライセンスで通信を行う非リアルタイムの、`Virtual OPC UA Device` を用います。

![](https://infosys.beckhoff.com/content/1033/tf6100_tc3_opcua_client/Images/png/9007214799884043__Web.png){align=center}

次に、作成されたデバイス以下にクライアントインスタンスを作成します。

![](https://infosys.beckhoff.com/content/1033/tf6100_tc3_opcua_client/Images/png/9007214799885707__Web.png){align=center}

作成したClientインスタンスをダブルクリックし、Settingsタブから接続先のURLを設定します。必要に応じてセキュリティ設定、ノードセットファイルの読み込みを行ってください。`Add Nodes` ボタンを押すと接続を試みます。

```{tip}
* ノードセットとは、読み込むべきサーバの公開するデータ構造を定義したファイルです。
* セキュリティ設定はサーバ側の求めるポリシーに応じてください。ここではセキュリティ無し、ノードセット読み込みを行わない前提として説明を勧めます。
```

`Add Nodes` ボタンを押してサーバへの接続を試みます。

![](assets/2025-11-14-09-33-54.png){align=center}

サーバの公開しているデータ一覧のツリーが現れたら接続成功です。取得したいデータをチェックボックスで選択してOKを押すと、IOツリーに選択したデータノードが一覧されます。

```{list-table}
* - ![](https://infosys.beckhoff.com/content/1033/tf6100_tc3_opcua_client/Images/png/9007215259485835__Web.png){align=center}
  - ![](https://infosys.beckhoff.com/content/1033/tf6100_tc3_opcua_client/Images/png/9007215259482635__Web.png){align=center}
```

続いて変数定義を行います。手動でリンクする事も可能ですが、次のとおりの操作で自動的にリンクされた変数を定義することができます。

`OPC UA Client` > `Settings` タブ > `Create PLC Code` ボタン

![](https://infosys.beckhoff.com/content/1033/tf6100_tc3_opcua_client/Images/png/9007214802186763__Web.png){align=center}

コードジェネレータは、既存のPLCプロジェクト内に、OPC UAクライアントのデバイス名から派生した名前のGVLを作成します。PLC変数はGVL内に自動的に作成され、「TcLinkTo」プラグマを介してI/Oデバイスのプロセスイメージ内の対応するノードにリンクされます。手動でリンク操作を行う必要はありません。

![](https://infosys.beckhoff.com/content/1033/tf6100_tc3_opcua_client/Images/png/9007214802792203__Web.png){align=center}

この変数を用いてPLCプログラミングを行ってください。