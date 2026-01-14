# リモートマネージャのセットアップ

異なるバージョンのランタイム用のプロジェクトをビルドするには、リモートマネージャをインストールする必要があります。XAE自体は最新バージョンであってもリモートマネージャを使うと、任意のバージョン向けのランタイムを生成することができます。

````{warning}
ここでインストールしたTwinCATバージョンはPLCのランタイムに限ります。C++プロジェクトのビルドツールは含まれません。また、他のTFパッケージに依存するライブラリに関しては連動しません。ランタイムにマッチするTFパッケージを別途インストールしてください。

リモートマネージャで切り替え可能なコンポーネント
    : PLCビルドツール, TC1200に含まれるPLCライブラリ, Visualization（PLC HMI）
    
リモートマネージャで切り替え不可能なコンポーネント
    : MATLAB/SIMLINKやC++のビルドツール, 他のTFパッケージに含まれるPLCライブラリ

````

## リモートマネージャのインストール方法

### 事前設定
パッケージマネージャのFeed設定にて、Outdatedサーバを追加します。（{ref}`section_package_manager_feed_setting` 参照）

### インストール

1. パッケージマネージャのBrowseを開きます。以後、{ref}`section_package_manager_gui_ope` の操作に従って次の通り操作します。
2. パッケージマネージャのメインメニューから、Feeds設定にて、Outdated feedが含まれるようにします。（Allを選択すると全て含まれます）
3. 検索フィールドに “Remote” を入力して、Remote Managerを一覧します。
4. Engineering – TwinCAT Standard Remote Manager の帯の部分をクリックします。
5. 右側に該当パッケージの詳細情報が表示されるフレームが現れます。この中のVersionsをクリックします。
6. インストールしたいバージョンのRemote managerを選択して、インストールを行います。

![](assets/2026-01-05-09-21-48.png){align=center}

## 使用方法

1. まずプロジェクトを開かずにXAEを起動し、Remote managerのセレクトタブから目的のバージョンを選んでおきます。
   ![](https://infosys.beckhoff.com/content/1033/tc3_remote_manager/Images/png/9007202409386635__Web.png){align=center}

2. その後、そのバージョンで動作するTwinCATのソリューションプロジェクトを開きます。リモートマネージャであらかじめ設定しておいたバージョンをビルドバージョンとしてプロジェクトを開きますので、これでビルドを行いますと、該当バージョンとしてビルドを行い、ターゲットへのアクティベートを行っていただく事が可能です。


```{note}
具体的な運用手順は、 {ref}`chapter_freeze_build_version` も併せてご覧ください。プロジェクトを開く前のバージョン切替の手間を省くために XAE のデフォルトバージョンを設定しておいたり、プロジェクトにビルドバージョンを指定する **ピンバージョン** という仕組みがあります。
```

```{warning}
TwinCAT Build 4026には、Visual Studil 2019をベースとしたTcXaeShellの32bit版と、Visual Studil 2022をベースとした64bit版があります。4024以前のリモートマネージャをお使いいただくには、32bit版のTcXaeShellが必要です。

![](assets/2026-01-14-09-27-19.png){align=center}

32bit版のTcXaeShellがみつからない場合は、パッケージマネージャによるインストールが必要です。{ref}`section_select_xae_integration` をご覧ください。
```