# TwinCAT Docker イメージの構築

最初にDockerのイメージ、および、docker-compose のビルドスクリプトを用いてイメージを作成します。composeのデプロイディレクトリは、`/opt/stacks` 以下に作成するものとします。

```{warning}
Dockerはpodman等と異なり、サービスとして管理者権限で動作します。よって、一般ユーザの権限では操作できない場所に配置してください。
```

## 前準備

まず、[TC_XAR_Container_Sample](https://github.com/Beckhoff/TC_XAR_Container_Sample) をクローンします。

```{code} bash
$ cd /opt/stacks
$ sudo git clone https://github.com/Beckhoff/TC_XAR_Container_Sample.git
$ cd ./TC_XAR_Container_Sample
```

```{note}
Githubに習熟されている方は、上記本家リポジトリをご自分のアカウントにフォークした上でクローンしてください。独自の変更を管理することができます。
```

次に、ビルドに必要なツールをインストールします。

```{code} bash
$ sudo apt install --yes make tcsysconf
```

## カスタマイズ

### TwinCAT unstable apt リポジトリへ変更

ホストマシン同様、apt パッケージのリポジトリを unstable へ変更します。 `tc31-xar-base/apt-config/bhf.list` ファイルを編集し、 trixie-stable 部分を trixie-**un**stable へ変更します。

```{code-block}
:caption: /opt/stacks/TC_XAR_Container_Sample/tc31-xar-base/apt-config/bhf.list

deb [signed-by=/usr/share/keyrings/bhf.asc] https://deb.beckhoff.com/debian trixie-unstable main
```

### TF5000とTF1810の追加設定

まず、ビルド前にDockerFileを編集します。

```{code} bash
$ sudo nano tc31-xar-base/DockerFile
```

下記のとおり、`tc31-xar-um` の後に、`tf1810-plc-hmi-web` および `tf5000-nc-ptp-xar` のインストールを指定します。

```{code-block} DockerFile
:caption: tc31-xar-base/DockerFile

# Install TwinCAT runtime package
RUN --mount=type=secret,id=apt \
    apt-get -o "Dir::Etc::netrc=/run/secrets/apt" update \
    && apt-get -o "Dir::Etc::netrc=/run/secrets/apt" install --yes \
    tc31-xar-um \
    tf1810-plc-hmi-web \   # 追加
    tf5000-nc-ptp-xar \    # 追加
    && rm -rf /var/lib/apt/lists/*
```

````{note}
他にどのようなパッケージがあるのか調べたい場合は次の通りパッケージ名を探してください。スペース付きハイフンで区切られた前半がパッケージ名となります。（例：`tf5000-nc-ptp-xar`）

```{code} bash
$ sudo apt-cache search twincat
adstool - command line tool to access TwinCAT systems via ADS
libadscomm - TF6000 ADS Communication Library
libadscomm-dev - TF6000 ADS Communication Library
libtceventloggeradsproxy - Beckhoff TwinCAT TcEventLoggerAdsProxy
libtcrte - Beckhoff TwinCAT realtime Ethernet library
mdp-bhf - Modular Device Profile component of TwinCAT System Service
tc31-xar-ethercatsimulation - TwinCAT EtherCAT Simulation driver
tc31-xar-multiconfigcoupler - TwinCAT MultiConfigCoupler driver
tc31-xar-um - Beckhoff TwinCAT 3 base runtime
tcsysconf - Tools for real-time Ethernet and system configuration management
tcusbsrv - TwinCAT 3 USB Service
tf1200-ui-client - TF1200 TwinCAT UI Client
tf1810-plc-hmi-web - TF1810 | TC3 PLC HMI Web
tf5000-nc-ptp-xar - TF5000 | TwinCAT 3 NC PTP
tf6100-opc-ua-server - TF6100 | TC3 OPC UA Server
tf6250-modbus-tcp - Beckhoff TwinCAT Modbus TCP Server
tf627x-profinet-rt-xar - TwinCAT PROFINET RT driver
tf628x-ethernetip-xar - TwinCAT EtherNet/IP driver
tf6310-tcp-ip - Beckhoff TwinCAT TCP/IP Server
tf6340-serial-communication - TF6340 TC3 Serial Communication
tf6421-xml-server - Beckhoff TwinCAT XML Data Server
tf6620-s7-communication-xar - TwinCAT 3 S7 Communication
tf8020-bacnet-xar - TF8020 | TwinCAT 3 BACnet driver
```
````

### my beckhoffアカウントの設定

ユーザ名、パスワード

```{code} bash
$ sudo nano tc31-xar-base/apt-config/bhf.conf
```

下記の2行を記述します。 `<my beckhoff username>`と`<my beckhoff password>`の部分は、My Beckhoffのユーザ名とパスワードをそれぞれ記載してください。

```{code-block} conf
:caption: tc31-xar-base/apt-config/bhf.conf

machine deb.beckhoff.com login <my beckhoff username> password <my beckhoff password>
machine deb-mirror.beckhoff.com login <my beckhoff username> password <my beckhoff password>
```

パスワード付きファイルなので、ファイル所有者以外は閲覧できないようにパーミションを変更します。

```{code} bash
$ sudo chmod 600 tc31-xar-base/apt-config/bhf.conf
```

### TcRegistry.xml への変数定義

ユーザモードランタイムでNC PTPを稼働させる際には、使用可能なヒープ領域を拡張する必要があります。

参照 : {ref}`section_umr_not_enough_memory`

ここで紹介されている事例はWindows上のユーザモードランタイムでNC PTPを動作させる際に必要な設定として `TcRegistry.xml` ファイルを編集する方法が紹介されています。Linux環境ではこのファイルが `/etc/TwinCAT/3.1/TcRegistry.xml` に配置されています。

コンテナ内のランタイムにおいてもこのファイルの修正が必要ですが、`TcRegistry.xml` ファイル自体は docker compose によってインスタンスが構築される際、`docker-compose.yaml` に定義されたAmsNetID定義を反映して動的に生成されます。

このため、`TcRegistry.xml` はDockerをビルドする際には存在しません。代わりに、`TcRegistry.xml` ファイルに追加で定義したい内容は、 `tc31-xar-base/TwinCAT/SysStartupState.reg` で定義することで反映される仕様となっています。

よって、ヒープメモリ確保の定義 `HeapMemSizeMB` もこのファイルを編集して追加します。

```{code} bash
$ sudo nano tc31-xar-base/TwinCAT/SysStartupState.reg
```

最終行に、`"HeapMemSizeMB"=dword:<heapメモリサイズ MByte>` を定義します。`dword:` につづいて記述する数値は16進数です。たとえば、512MByteのヒープメモリ領域を確保しておく場合は、`dword:00000200`と記述します。

```{code-block} ini
:caption: tc31-xar-base/TwinCAT/SysStartupState.reg

Windows Registry Editor Version 5.00^M
^M
; SysStartupState defines the TwinCAT System Service Startup State^M
; RUN = "SysStartupState"=dword:00000005^M
; CONFIG = "SysStartupState"=dword:0000000f^M
[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Beckhoff\TwinCAT3\System]^M
"SysStartupState"=dword:00000005^M
"HeapMemSizeMB"=dword:00000200 # この1行を追加 追加したいHeapメモリサイズを16進数で表現。（0x0000200 = 512MByte）
```

### ADS-over-MQTTの設定

#### トピックの設定

コンテナのランタイムと、開発環境XAE間をADS-over-MQTTで通信する際には、コンテナ側がサブスクライバとしてどのトピックで通信するのかをXAE間でお互い合わせておく必要があります。この定義が `tc31-xar-base/TwinCAT/StaticRoutes.xml` にあります。

デフォルトのままで変更する必要はありませんが、`<Topic></Topic>`のタグ内のトピック名をチェックしておいてください。`AdsOverMqtt` がデフォルトの値ですので、必要に応じて任意の値に変更可能です。

```{code-block} xml
:caption: tc31-xar-base/TwinCAT/StaticRoutes.xml

<?xml version="1.0" encoding="utf-8"?>
<TcConfig xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:noNamespaceSchemaLocation="http://www.beckhoff.com/schemas/2015/12/TcConfig">
<RemoteConnections>
    <Mqtt>
        <Address Port="1883">mosquitto</Address>
        <Topic>AdsOverMqtt</Topic>
    </Mqtt>
</RemoteConnections>
```

#### nftablesでポート1883を開放する

外部からMQTT通信できるように、nftablesを設定してポート1883アクセスを許可します。 `/etc/nftables.conf.d/60-mosquitto-container.conf` を新規作成して編集します。

```{code} bash
$ sudo nano /etc/nftables.conf.d/60-mosquitto-container.conf
```

{numref}`code_nftables_mqtt` のとおりに記述して保存してください。

```{code-block}
:caption: /etc/nftables.conf.d/60-mosquitto-container.conf
:name: code_nftables_mqtt

table inet filter {
  chain input {
    tcp dport 1883 accept
  }
  chain forward {
    type filter hook forward priority 0; policy drop;
    tcp sport 1883 accept
    tcp dport 1883 accept
  }
}
```

設定反映には、IPCの再起動が必要です。一度再起動を行ってください。

(section_ads_over_mqtt_xae)=
#### XAE側の設定

この設定を確認した上で、接続予定の開発環境のXAEのPC上に、 `C:\Program Files (x86)\Beckhoff\TwinCAT\3.1\Target\Routes\` の場所を探します。存在しなければ、フォルダを作成します。

この場所に、`TC_XAR_Container_Sample` のサンプルに含まれる `mqtt.xml` をコピーします。また、このXMLファイルを編集し、{numref}`mqtt_xml_sample` に示す `ip-address-of-container-host` の部分を、ターゲットIPC（TwinCATコンテナランタイムが稼働しているIPC）のIPアドレスに置き換えます。

また、トピック名を変更している場合は、`<Topic>AdsOverMqtt</Topic>` の内容も合わせておいてください。

```{code-block} xml
:caption: C:\Program Files (x86)\Beckhoff\TwinCAT\3.1\Target\Routes\mqtt.xml
:name: mqtt_xml_sample

<?xml version="1.0" encoding="utf-8"?>
<TcConfig xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:noNamespaceSchemaLocation="http://www.beckhoff.com/schemas/2015/12/TcConfig">
<RemoteConnections>
    <Mqtt Unidirectional="true">
        <Address Port="1883">ip-address-of-container-host</Address>
        <Topic>AdsOverMqtt</Topic>
    </Mqtt>
</RemoteConnections>
</TcConfig>
```

```{note}
動作確認は次の節で行いますので、ここでは設定のみ済ませてください。
```

## ビルド

```{warning}
この手順によって Beckhoff のパッケージリポジトリから取得したパッケージを基にコンテナイメージを構築しています。TwinCATの各種コンポーネントが更新されるたびに本手順を実施してビルドしなおしてください。
```

上記の設定を終えましたら、`/opt/stacks/TC_XAR_Container_Sample` のディレクトリへ移動して、次のコマンドを発行してDockerイメージを生成します。

```{code} bash
$ cd /opt/stacks/TC_XAR_Container_Sample
$ sudo make image-build
```

管理者パスワードを入力したらビルドを開始します。

```{code}
[sudo] password for Administrator:
Building Docker image: tc31-xar-base:latest
docker build --no-cache --secret id=apt,src=./tc31-xar-base/apt-config/bhf.conf --network host -t tc31-xar-base:latest -f ./tc31-xar-base/Dockerfile ./tc31-xar-base
[+] Building 7.2s (5/14)
  :
 => [stage-0  9/10] WORKDIR /app                                                  0.4s
 => [stage-0 10/10] COPY entrypoint.sh /app/                                      0.4s
 => exporting to image                                                            2.4s
 => => exporting layers                                                           2.2s
 => => writing image sha256:12b2124f166edc15233b28b008e0ef58b747a73071f66979216ff6fac489a665    0.0s
 => => naming to docker.io/library/tc31-xar-base:latest 
```

以上によりコンテナイメージ `tc31-xar-base:latest` が生成されます。続いて、次節にて docker-composeの設定を行います。