(chapter_twincat_hmi)=
# TwinCAT HMI

TwinCAT HMI は次の2つの製品から成り立っています。

TE2000 TwinCAT 3 HMI Engineering
    : TF2000 TwinCAT 3 HMI Server上にデプロイするHMIプロジェクトを作成するための開発環境

TF2000 TwinCAT 3 HMI Server
    : IPC上で動作するHTML5 および JavaScriptを用いた動的なWEBページを提供するWEBアプリケーションフレームワーク。TE2000にてビルドしたプロジェクトをこのサーバ上にデプロイしてWEBアプリケーションベースのHMI機能をサービス提供する。クライアントにはWEBブラウザを用いる。

基本的な構成は{numref}`figure_basic_tchmi_system_structure` のとおりです。TwinCATランタイム内の変数シンボルをHMI Serverが読み書きし、これをWEBアプリケーションとしてサービス提供します。クライアント側にはブラウザをKIOSKモードで全画面表示し、IPCのDisplay PortやDVI出力と、USBにてタッチパネルへ表示、入力サポートします。

```{figure} https://infosys.beckhoff.com/content/1033/te2000_tc3_hmi_engineering/Images/jpg/18014402101919243__Web.jpg
:align: center
:name: figure_basic_tchmi_system_structure

基本的なTwinCAT HMIのシステム構成
```

HMI ServerはWEBサーバですから、複数のクライアントからの接続が可能です。フレームワークの機能としてHTML5とJavaScriptをベースとしたWebベースのレスポンシブデザインに対応していますので、解像度と画面の向きが自動的に調整されます。これにより、同じページをさまざまなディスプレイサイズ、アスペクト比、画面の向きで使用できます。

```{figure} https://infosys.beckhoff.com/content/1033/te2000_tc3_hmi_engineering/Images/jpg/18014402101921163__Web.jpg
:align: center
:name: figure_mc_tchmi_system_structure

マルチクライアントのTwinCAT HMIのシステム構成
```

さらに、独立したBeckhoff製 IPCは必要ですが、このIPC内にTwinCAT Serverを設置すると、TCP/IPで接続されたネットワーク内にある他のTwinCAT IPCに接続し、HMI画面のサービスを統合化することができます。

```{figure} https://infosys.beckhoff.com/content/1033/te2000_tc3_hmi_engineering/Images/jpg/18014402101923083__Web.jpg
:align: center
:name: figure_mcmr_tchmi_system_structure

マルチクライアント・マルチランタイムのTwinCAT HMIのシステム構成
```

```{tip}

{numref}`figure_mcmr_tchmi_system_structure` の構成では {ref}`section_ads_over_mqtt` をお勧めします。ご面倒でも mosquitto などのMQTTサーバを別途稼働させてこれを介して接続を行ってください。IPCとHMIとの間の接続以外にも全てのIPCとのTwinCAT XAEの接続が統合的に管理でき、また、TLSを用いたセキュアな接続が可能となりますので安心で便利です。

通常のソケットを使ったADSルータ間通信では相互に信頼関係を結ぶ登録設定を行う必要があります（{ref}`section_ads_routing`参照）。このため、設備IPCが追加されるたびに HMI Server 側にも設備側のIPCのADSルータ情報を登録しなければなりません。これはライン構成によって頻繁にコントローラの構成が変更される場合の運用が煩雑になる原因となります。同様に、IPC上に複数のコンテナを動的に稼働させて運用する場合も同じ問題が発生します。

これを解決するため、中間にMQTTブローカを仲介させてADS通信を行う ADS over MQTT という通信方式をサポートしています。この場合、設備側もTwinCAT HMI Server側もコネクション設定を行うのはMQTTブローカとの1回だけとなります。この中を流れるADSストリームにより自動的にAMS Net IDが識別され、相互に新たなコネクションを登録することなく接続が可能となります。
```


```{note}

いずれの場合も、TwinCAT HMI Clientは弊社製のIPC、TwinCATは不要です。HTML5対応のWEBブラウザをご用意ください。ただし、IPC内でKIOSKモードでWEBブラウザ機能を提供する[TF1200 UI Client](https://www.beckhoff.com/ja-jp/products/automation/twincat/tfxxxx-twincat-3-functions/tf1xxx-system/tf1200.html)を別途ご用意しています。TwinCAT/BSD や、 TwinCAT RT Linux等のCLI（コマンドラインインターフェース）のみを備えているIPCの場合、この製品の導入をご検討ください。くわしくは{ref}`section_linux_tf1200`にて導入方法をご説明しています。
```


```{toctree}
:caption: 目次

setup
component_ec_diag
```