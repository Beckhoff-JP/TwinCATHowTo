(section_package_manager_startup)=
# パッケージマネージャのインストールと基本設定

パッケージマネージャは、TwinCAT 3.1 build 4026 より導入されたTwinCAT関連ソフトウェアのインストール、アンインストールシステムです。特定のソフトウェアのインストールにおいて、依存する関連ソフトウェアを自動的にインストールしたり、個々のインストーラに頼らず、包括的にバージョンアップすることができます。

```{warning}

* パッケージマネージャ経由でインストールするバージョンは、build 4026に限ります。
* build 4024の環境と併用はできません。
* build 4024の環境にパッケージマネージャを導入しますと、build 4026への移行が行われます。
```

## 初期設定

### パッケージマネージャのインストール

以下のサイトからパッケージマネージャをダウンロードします。

[https://www.beckhoff.com/ja-jp/products/automation/twincat/twincat-3-build-4026/](https://www.beckhoff.com/ja-jp/products/automation/twincat/twincat-3-build-4026/)

ダウンロードしたパッケージマネージャをWindowsインストーラにてインストールを行います。インストールしたら、パッケージマネージャを起動してください。

### 4024からのマイグレーション

すでに4024の環境がインストールされている場合は、パッケージマネージャによって4024から4026へのマイグレーションが行われます。

(section_package_manager_feed_setting)=
### Feed設定

左下の歯車アイコンを押して、最初にFeed設定を行います。Feedとは、パッケージの供給を受ける供給元のサーバです。

新規にサーバを登録するには右下の `+` アイコンをクリックしてください。

![](assets/2025-09-24-11-36-27.png){align=center}

Add feed画面が現れますのでサーバのURLや認証情報を設定します。次の表のとおり、少なくとも2つのサーバを登録してください。

```{list-table}
:header-rows: 1
:stub-columns: 1

- * 
  * Stable サーバ
  * Outdated サーバ
- * 説明
  * 4026パッケージサーバ
  * 4024リモートマネージャをインストールするためのサーバ
- * 設定
  * Feed url..
        : https://public.tcpkg.beckhoff-cloud.com/api/v1/feeds/Stable

      Name
        : Beckhoff Stable Feed

      Set credentials
        : ON

      User
        : my beckhoff に登録したユーザ名

      Password
        : my beckhoff に登録したユーザ名のパスワード
  * Feed url..
        : https://public.tcpkg.beckhoff-cloud.com/api/v1/feeds/outdated

      Name
        : Beckhoff Outdated Feed
    
      Set credentials以後
        : Stableサーバと同じ
```

![](assets/2025-09-24-11-41-54.png){align=center}

(section_select_xae_integration)=
### XAEの基本インストール

つづいてサイドのタブから `Integration` を開きます。

![](assets/2025-09-24-10-53-51.png){align=center}


```{note}
インストール、アンインストールを行うには、下記のバーをクリックしてください。

青色でAdd
    : 現在状態が未インストールであることを示します。クリックするとインストールを開始します。

赤色でRemove
    : 現在状態がインストール済みであることを示します。クリックすると **アン**インストールを開始します。
```

TcXaeShell、TcXaeShell64、インストール済み任意のVisual Studioバージョンへのアドオンをそれぞれ必要なものを青色のAddバーをクリックしてインストールします。それぞれのXAEの基本パッケージについては、次の違いがありますので適したものをインストールしてください。

UseTcXaeShell
    : ```{list-table}
      :widths: 4,6
      - * Windows10 20H2未満ではこちらを選択します。Visual Studio 2017 ベースの TwinCAT XAE build 4024と互換のある開発環境がインストールされます。Windows10 20H2以上であっても **4024のリモートマネージャをご利用いただくには** こちらを別途インストールする必要があります。
        * ![](assets/2025-09-24-10-36-20.png){align=center}
      ```

UseTcXaeShell64
    : ```{list-table}
      :widths: 4,6
      - * Windows10 20H2以上、Windows11ではこちらが選択可能です。Visual Studio 2022 ベースの TwinCAT XAE build 4026のネイティブな開発環境がインストールされます。この環境では4024のリモートマネージャはお使いいただけませんので、別途`UseTcXaeShell`も併せて構成してください。
        * ![](assets/2025-09-24-10-45-06.png){align=center}
        ```
UseVS****
    : あらかじめTwinCATがサポートするバージョンのVisual Studioがインストールされていればこの名前で一覧に現れます。これを構成すると指定したVisual Studioバージョンへ、TwinCAT XAE機能のアドオンを行います。お手持ちのVisual Studioとの統合化を行いたい場合はこちらを選択してください。参考：[https://infosys.beckhoff.com/content/1033/tc3_installation/15698621451.html?id=8658116531104156966](https://infosys.beckhoff.com/content/1033/tc3_installation/15698621451.html?id=8658116531104156966)


```{tip}
[InfoSysの情報](https://infosys.beckhoff.com/content/1033/tc3_installation/15698622603.html?id=8249084526473050017) の情報は、古いパッケージマネージャのUIのままとなっています。
```

## 基本パッケージのインストール

設定が完了したら、Finishボタンを押して設定を終えてください。インターネットに接続されていれば、設定したFeedよりパッケージ一覧を取得し、次図のとおり、Browse画面にワークロードが一覧されます。

`TwinCAT Standard` が最上位に現れます。開発環境であれば`Engineering - TwinCAT Standard`を、IPC等のランタイムが必要であれば、`Runtime - TwinCAT Standard`の行の右側にあるバージョンボタンをクリックしてください。

![](assets/2025-09-24-21-59-02.png){align=center}

次に右端のサイドバーから、![](assets/2025-09-24-22-01-54.png)アイコンをクリックします。

Select products が一覧されていますので、最下部の `Apply modifications` ボタンを押してインストールを開始します。

![](assets/2025-09-24-22-02-45.png){align=center}

しばらく待つとプログレスウィンドウが現れます。100%に達するまでしばらく時間を要します。根気よく待ってください。

![](assets/2025-09-24-22-06-30.png){align=center}

````{tip}
万が一インストールを途中で中断した場合、パッケージの整合状態が不正な状態となるため、最初からやり直す必要があります。この場合、まず管理者モードでターミナルを起動し、次のコマンドを発行してください。

```{code} powershell
PS> tcpkg uninstall all
```
````

下記のように緑色背景のウィンドウが現れたら無事インストールは完了です。

![](assets/2025-09-24-22-20-20.png){align=center}

タスクトレーにTwinCATアイコンが現れますので、任意のXAEを起動してインストールできていることを確認してください。

![](assets/2025-09-24-22-22-26.png){align=center}

```{attention}

ひきつづき Usermode runtime をインストールしてください
  : 開発用PCに Windows11 を用いられる場合、仮想化ベースのセキュリティ（VBS）が強化されているためTwinCATのランタイムがカーネルモードでは動作しなくなっています。このため、開発用PCでIPCの動作をシミュレーションするには、ユーザモードランタイムの導入が欠かせません。引き続きユーザモードランタイムをインストールし、{ref}`chapter_usermode_runtime` の章をお読みの上、追加パッケージ `XARUM` 等をインストールしてください。

    ![](assets/2025-09-24-22-25-55.png){align=center}
```

## インストール、アンインストールがエラーとなる場合の解決方法

パッケージマネージャにて、マイグレーションが途中で失敗したり、インストール、アンインストールが途中で失敗する場合、次のとおり対策を行ってください。

MicrosoftProgram_Install_and_Uninstall.meta
  : インストールやアンインストールを途中で中断した場合、レジストリキーが破損したり、インストーラがロックされてインストールや削除のどちらもできない状態となることが起こります。この状態を修復するためのツール[MicrosoftProgram_Install_and_Uninstall.meta](https://support.microsoft.com/ja-jp/topic/%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%A0%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E3%81%BE%E3%81%9F%E3%81%AF%E5%89%8A%E9%99%A4%E3%82%92%E3%83%96%E3%83%AD%E3%83%83%E3%82%AF%E3%81%99%E3%82%8B%E5%95%8F%E9%A1%8C%E3%82%92%E4%BF%AE%E6%AD%A3%E3%81%99%E3%82%8B-cca7d1b6-65a9-3d98-426b-e9f927e1eb4d)がありますので、このリンクからダウンロードを行い、ツールを実行してください。

いちど全てのパッケージをアンインストールする
  : {ref}`section_package_manager_cli_ope` に記載されているとおり、管理者モードでコマンドプロンプトを立ち上げ、次のコマンドを発行して全てのパッケージをアンインストールしてください。
  ```{code} powershell
  > tcpkg uninstall all
  ```
