# パッケージマネージャ

パッケージマネージャは、TwinCAT 3.1 build 4026 より導入されたTwinCAT関連ソフトウェアのインストール、アンインストールシステムです。特定のソフトウェアのインストールにおいて、依存する関連ソフトウェアを自動的にインストールしたり、個々のインストーラに頼らず、包括的にバージョンアップすることができます。

最初に、以下のサイトからパッケージマネージャの最新を取得して、開発環境、および、IPCにインストールしてください。

[https://www.beckhoff.com/ja-jp/products/automation/twincat/twincat-3-build-4026/](https://www.beckhoff.com/ja-jp/products/automation/twincat/twincat-3-build-4026/)

```{warning}

* パッケージマネージャ経由でインストールするバージョンは、build 4026に限ります。
* build 4024の環境と併用はできません。
* build 4024の環境にパッケージマネージャを導入しますと、build 4026への移行が行われます。
```

```{warning}

2025年3月時点ではパッケージマネージャの開発速度は極めて早く、バージョンによって利用できる機能に大きな差があります。
この節では、`TcPkg 2.1.134` で利用できる機能を基に説明します。
```


build 4026のインストール方法について基本的なことを知りたい場合は、まず次の動画をまずご視聴ください。


```{youtube} msYKl4Bjzio
:align: center
```

## パッケージマネージャコマンドラインインターフェース

パッケージマネージャはGUI版とコマンドインターフェース版の二つがインストールされます。
TwinCAT BSDやLinux等ではコマンドインターフェース版により操作する必要があります。
また、GUI版においては十分なエラー情報が得られない可能性が有ったり、依存関係にある
個々の子パッケージの追加、削除など細かな操作ができない可能性があります。
このため、GUI版において何等かの問題が生じた場合、ここで紹介するコマンドインターフェース
の操作を行う必要があります。インストールするコンポーネントが決まっている場合、
GUIでインストール作業を行うより、コマンドを組合せてシェルスクリプトを組む事でインストール
作業を自動化できますので便利です。

```{note}
コマンドラインインターフェースに関するドキュメントは以下で紹介されています。ただし、パッケージマネージャの最新機能は反映されていません。

[https://infosys.beckhoff.com/content/1033/tc3_installation/15698626059.html?id=5147078465983576506](https://infosys.beckhoff.com/content/1033/tc3_installation/15698626059.html?id=5147078465983576506)
```

### コマンドインターフェースの出現方法

パッケージマネージャは管理者権限で実行する必要があります。このため、Windows環境においては管理者モードによるPowerShellを起ち上げる必要があります。

```{list-table}
:widths: 1,1

- * `Windowsキー` + `X` を押してください。次のメニューが出現しますので、Windows PowerShell(管理者)( A ) を選んで権限昇格のダイアログを許可選択してください。
  * ![](assets/2025-03-26-12-25-11.png){align=center height=500px}
```

BSDの場合、管理者権限で実行するためには、コマンド発行前に`doas`を付加します。また、Linuxの場合は、`sudo` を付加します。

```{code-block}
$ doas pkg list
```

### パッケージを一覧する

インストール可能な全てのパッケージを一覧する方法は、`tcpkg list` を発行します。現在インストールされているパッケージだけを一覧するには、これに `-i` オプションを追加し、`tcpkg list -i` コマンドを発行します。次の通りの書式でパッケージが一覧されます。

```
<パッケージ名> <バージョン番号>
```

以下はインストール済みパッケージを一覧させる例です。

```{code-block} powershell
PS C:\> tcpkg list -i
TcPkg 2.1.86

TC170x.UsermodeRuntime.XAR 4026.14.0
TE1300.ScopeViewProfessional.XAE 34.49.0
TF3300.ScopeServer.XAR 34.49.0
 :
vcredist100.Beckhoff 10.0.40219.325
vcredist140.Beckhoff 14.38.33130
191 package(s) found.
PS C:\>
```

一画面に収まらない場合は、ページネーションしてくれるコマンド `more` と組合せます。パイプ `|` に続いて次の通りコマンド発行してください。

```{code-block} powershell
PS C:\> tcpkg list -i | more
TcPkg 2.1.86

TC170x.UsermodeRuntime.XAR 4026.14.0
TE1300.ScopeViewProfessional.XAE 34.49.0
TF3300.ScopeServer.XAR 34.49.0
 :
TwinCAT.XAE.HART 1.0.4
TwinCAT.XAE.Integration 2.11.0
-- More  --
```

`Enter`キーを押しながら行送りができます。

### パッケージをインストールする

指定したパッケージをインストールするには下記のコマンドを発行します。依存関係にあるパッケージも自動的にインストールされます。リポジトリに登録された最新のパッケージがインストールされます。`-y` オプションを付加することで、インストールしてよいかどうかの確認は行わず、ただちにインストールを開始します。

``` powershell
PS C:\> tcpkg install <パッケージ名> -y
```

任意のバージョンのソフトウェアをインストールしたい場合は `-v` オプションを指定します。

``` powershell
PS C:\> tcpkg install <パッケージ名> -v <バージョン番号>
```

### パッケージをアンインストールする

指定したパッケージをアンインストールするには下記のコマンドを発行します。このコマンドでは依存関係にあるパッケージは連携してアンインストールされることはありません。

``` powershell
PS C:\> tcpkg uninstall <パッケージ名>
```

依存関係にあるパッケージを連携して削除するには、 `--include-dependencies` オプションを付加します。

``` powershell
PS C:\> tcpkg uninstall <パッケージ名> --include-dependencies
```

全てを削除する場合は、パッケージ名を `all` とします。

``` powershell
PS C:\> tcpkg uninstall all
```

### 構成のエクスポート

次のコマンドにより、現在インストールされているTwinCATコンポーネントの構成を定義ファイルとしてエクスポートできます。

```{code-block} powershell
PS C:\> tcpkg export -o twincat_required.xml
```

上記により、次のように構成定義ファイル `twincat_required.xml` が作成されます。

### 構成のインポート

前節でエクスポートしたパッケージ構成ファイルに基づいて同じ構成のTwinCATコンポーネントをインストールします。

```{code-block} powershell
PS C:\> tcpkg import -i twincat_required.xml
```

各オプションの説明は以下の通りです。

`-i`（必須）
    : 読み込む構成定義ファイル。

`-y`
    : インストールするかどうか確認プロンプトは出現せず、インストールを開始します。

`--no-cache`
    : パッケージリポジトリからダウンロードしたファイルをキャッシュせず、インストール完了後ただちに削除します。ディスク容量が節約できます。

`--all-sources`
    : これを指定すると、読み込んだ定義ファイルに指定されたバージョンより最新のバージョンが利用可能であれば、そちらをインストールします。

