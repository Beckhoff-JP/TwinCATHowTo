(chapter_freeze_build_version)=
# TwinCATビルドバージョンをフリーズする

PLCのソースコードは、TwinCATのビルドシステムによりコンパイルが行われ、{ref}`ブートイメージ<section_boot_image>` が生成されます。アクティブコンフィギュレーションを行うことでターゲットのXARにこのブートイメージがダウンロードされます。

このコンパイルで使用されるTwinCATのバージョンを選択することができる機能を[リモートマネージャ](https://www.beckhoff.com/ja-jp/support/download-finder/search-result/?download_group=97028330)と呼びます。この節では、リモートマネージャを使って任意のバージョンでビルドを行い、プロジェクトの設定としてビルドバージョンを固定する設定手順を説明します。

## 準備

任意のバージョンの[リモートマネージャ](https://www.beckhoff.com/ja-jp/support/download-finder/search-result/?download_group=97028330)をあらかじめインストールしておく必要があります。これはXAEをインストールしたTwinCATバージョンとは別に用意されています。

リモートマネージャをインストールしておく事で、開発者はインストールされたTwinCAT XAEそのもののバージョンか、別途インストールしたリモートマネージャのバージョンの何れかでビルドする事が可能になります。

```{tip}
* リモートマネージャは、TwinCAT 3.1 build 4026の場合はパッケージマネージャで、4024の場合は[ダウンロードサイト](https://www.beckhoff.com/ja-jp/support/download-finder/search-result/?download_group=97028330)からインストーラをダウンロードしてインストールします。
* ダウンロード可能なリモートマネージャは、代表的なもののみとなっています。任意のバージョンのリモートマネージャが必要な場合は弊社にご相談ください。
```

## 操作手順

1. TwinCAT shellだけ（プロジェクトを読み込まず）に立ち上げてください。
2. 左上のバージョン選択フィールドから以下の何れかのバージョンへ変更します。

    ![](https://infosys.beckhoff.com/content/1033/tc3_remote_manager/Images/png/9007202409386635__Web.png)

    デフォルトバージョン
    : 末尾に `(Default)` と記載されたバージョンです。初期状態ではインストールされたXAEバージョンとなっています。デフォルトバージョンは、XAEの Tools > Option > TwinCAT > XAE Environment > General 設定にて任意のバージョンに設定する事ができます。
    : ![](https://infosys.beckhoff.com/content/1033/tc3_remote_manager/Images/png/9007202409399179__Web.png)

    接続しているリモートのIPC上のXARと同じバージョン
    : `Chose from Target System ...` を選択します。

    インストール済みのリモートマネージャの任意のバージョン
    : インストールされた[リモートマネージャ](https://www.beckhoff.com/ja-jp/support/download-finder/search-result/?download_group=97028330)リストされますので、任意のバージョンを選択します。

    しばらくすると、リモートマネージャの表示が指定したバージョンで（Loaded）になります。

3. TwinCATプロジェクトを読み込みます。
4. 読み込みが終わったら一度ビルドしてください。これでリモートマネージャで指定したバージョンでのビルドイメージが作成されます。
5. そのあと、SYSTEMツリーを選択し、Generalタブの中のPin Versionのチェックを入れてください。これにより、どのバージョンのTwinCATでプロジェクトを開いても、この指定バージョンでビルドされる事になります。

    ![](assets/2023-05-11-11-17-42.png){align=center}

    ```{note}
    * プロジェクトの初期設定はDefaultバージョンです。Pinバージョンを設定した場合、プロジェクトを開く度にリモートマネージャのバージョン切り替えが行われますので、通常よりもプロジェクトを開くのに時間がかかります。
    * リモートマネージャで指定できるバージョンは、現在インストールされているXAEのバージョンよりも古いものに限ります。`Chose from Target System ...` を選択する際、XAR側が現在お使いのXAEのTwinCATバージョンより新しいバージョンである場合はビルドする事ができません。事前にターゲットのXARのバージョンより新しいTwinCAT XAEをインストールしてください。
    ```
