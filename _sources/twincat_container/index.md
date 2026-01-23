(chapter_twincat_container)=
# TwinCAT Container のセットアップ

Linux RT TwinCAT ランタイムは、ユーザモードで動作します。また、Linuxにより提供されているさまざまなコンテナ技術を使ってTwinCATを動作させることもできます。

ここでは、Dockerのコミュニティ版 Docker-CE を使ってTwinCATを動作させる方法をご紹介します。

## システム構成

Beckhoff本社のGithubで提供されているDockerFile、および、docker-compose のひな型を用います。

```{tip}
[https://github.com/Beckhoff/TC_XAR_Container_Sample](https://github.com/Beckhoff/TC_XAR_Container_Sample)
```

### TC_XAR_Container_Sampleの特徴

このGithubのDocker構築スクリプトのサンプルには特徴があります。

コンテナ仕様
    : `debian:trixie-slim` をベースに、`tc31-xar-um` をインストールしたイメージ

TwinCATインスタンスは一つ
    : `docker-compose.yaml` に定義されているTwinCATコンテナインスタンスは一つ。

XAEとの接続に ADS-over-MQTT を使用
    : コンテナ内のTwinCATランタイムと接続するためのADS通信で用いられるTCPポートは通常固定です。アプリケーション側で自由に変更する仕様とはなっていません。
    このため、複数のTwinCATコンテナにおいてADS通信で使用するTCP/UDPポートをEXPOSEすると衝突が起こるため、そのままADSで通信することができません。
    
    : 代替方法として、ADS-over-MQTTを用いて、mosquittoのコンテナイメージを別途起動し、これをブローカとして各コンテナインスタンスと接続する方式を採用しています。 

ランタイムのみ
    : 前述のとおりイメージにインストールされるのは`tc31-xar-um` のみで他のTF製品のインストールは一切ありません。

永続化なし
    : TwinCATのBootフォルダなど、Active Configurationなどを行った際のデータはコンテナ内のメモリイメージで保存されているため、再起動すると再度 Active Configurationをやりなおす必要があります。

Ethernetリアルタイムドライバへのアクセスが可能
    : host上のTwinCATのランタイムサービスを無効化して競合させない状態にした上で、任意のEthernetポート（PCIデバイスIDで指定）をリアルタイムドライバとしてコンテナから直接アクセスすることができます。

### 本マニュアルで目指すシステム

このドキュメントでは、公式サンプルイメージを改造し、次の点を達成できるようにします。

* 2つのTwinCATコンテナが稼働するようにします。
* それぞれのTwinCATコンテナには、TF5000(NC PTP)、TF1810（PLC HMI Web）を追加インストールし、コンテナ上のランタイムによりモーション制御、およびHMI操作が可能にします。
* `/etc/TwinCAT/3.1` 以下のフォルダをホスト側のディレクトリにvolumeを作成し、ファイルとして永続化できるようにします。これにより再起動後もBootイメージが再現され、自動RUN MODE, Auto start boot projectが維持できるようになります。
* PLC HMI WebはPort 42341 でHTTPサービスが起動します。SSLには非対応のため、nginx リバースプロキシを通して外部アクセス可能にします。

![](assets/twincat_container_structure.png){align=center}


```{toctree}
:caption: 目次

build_image
compose
reverse_proxy
```