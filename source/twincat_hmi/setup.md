# TF2000 TwinCAT HMI Server のセットアップ

## Beckhoff RT LinuxへのTF2000のインストール

Beckhoff RT Linuxへ TF2000 TwinCAT 3 HMI Serverをインストールするには次のコマンドを入力します。

```{code-block} bash
$ sudo apt install -y tf2000-hmi-server tf2000-hmi-server-net
```

これによりインストールが始まり、最後に次のメッセージが現れてインストールが完了します。

```{code-block} bash
============================== !!!! WARNING !!!! ==========================

TwinCAT HMI Server has to be initialized first. Please run:

sudo TcHmiSrv --initialize --password=PASSWORD

============================== !!!! WARNING !!!! ==========================
Setting up bhf-dotnet-host (10.0.9+345440) ...
Setting up bhf-dotnet-runtime-deps-8.0 (8.0.28+345440) ...
Setting up bhf-dotnet-hostfxr-8.0 (8.0.28+345440) ...
Setting up bhf-dotnet-runtime-8.0 (8.0.28+345440) ...
Setting up tf2000-hmi-server-net (23.0.421.0-1) ...
Processing triggers for man-db (2.13.1-1) ...
Processing triggers for libc-bin (2.41-12+deb13u4) ...
$ 
```

ここに記載があるとおり、次のとおりサーバの初期化用のスクリプトを実行します。`*****` の部分はサーバ管理者用のパスワードです。任意のパスワード文字列に置き換えて入力してください。

```{code-block} bash
$ sudo TcHmiSrv --initialize --password=*****
Adding service instance /var/lib/tchmisrv/service/TcHmiProject.
[II TcHmiSrv] Domain 'TcHmiSqliteLogger' initialized
[VV TcHmiSrv] The temporary events of the 'TcHmiSqliteLogger' domain were reset.
[II TcHmiSrv] Domain 'TcHmiUserManagement' initialized
[VV TcHmiSrv] The temporary events of the 'TcHmiUserManagement' domain were reset.
Password initialized
[II TcHmiSqliteLogger] Shutdown extension TcHmiSqliteLogger succeeded.
```

これでインストールは完了です。次のコマンドで、systemdへ登録してデーモンを有効にします。これにより次回再起動時も自動的にHMI Serverが起動します。

```{code-block} bash
$ sudo systemctl enable --now TcHmiSrv
```

## nftables による外部からのポートアクセス開放

### 設定ファイルの作成
ターミナルまたはSSHでデバイスに接続し、以下のコマンドを実行して新しく設定ファイルを作成します。

```{code} bash
sudo nano /etc/nftables.conf.d/20-hmi.conf
```

### ルールの記述

開いたファイル内に以下の内容を記述し、保存して閉じます。

```{code-block} nftables
table inet filter {
    chain input {
        # accept TcHmi Server 通信許可
        tcp dport { 2020, 2021 } accept
    }
}
```

### ルールのリロード
作成した設定を反映させるため、`nftables` サービスをリロードします。

```bash
sudo systemctl reload nftables
```

### 設定の確認
ルールが正しく適用されているか確認します。

```bash
sudo nft list ruleset
```
出力結果の中に `tcp dport { 2020, 2021 } accept` が含まれていれば設定完了です。

```{note}
HTTPSのみに制限する場合
    : セキュリティを高めるために暗号化通信のみを許可する場合は、ポート `2020` を除外し、`tcp dport 2021 accept` のみに変更してください。

詳細ドキュメント
    : さらに詳しい仕様については [Beckhoff Infosys](https://infosys.beckhoff.com/content/1033/tf2000_tc3_hmi_server/19752826507.html?id=1616737468107298121) の公式マニュアルを参照してください。
```

(section_te2000_setup)=
## 開発環境のセットアップ

開発環境には、TwinCAT 3 XAEにアドオンするHMI開発環境であるTE2000のインストールが必要となります。注意点としてターゲットとするIPCにインストールしたHMI Serverと同じバージョンが内包されるTE2000をインストールする必要があります。

まずは、IPCにインストールしたTF2000のバージョンを調べます。

```{code} bash
$ sudo apt search tf2000
tf2000-hmi-server/trixie-stable,now 24.0.7.0-1 amd64 [installed]
  Beckhoff TwinCAT 3 HMI Server

tf2000-hmi-server-net/trixie-stable,now 24.0.7.0-1 amd64 [installed]
  TwinCAT 3 HMI .NET Extension Container
```

上記により、`Ver 24.0.7` がインストールされていることが分かります。これが含まれるTE2000のバージョンを調べます。パッケージマネージャを起動し、Browseからパッケージ名検索で`TE2000`を探します。下部灰色のバーをクリックすると右側のサイドバーが現れます。`Versions` タブをクリックして、順にバージョンツリーを開き、`Description` の中にある `TwinCAT.HMI.Server.Engineering` を探し、IPCのTF2000のバージョンと一致するものを探して、インストール指定してインストールを行ってください。

```{figure} assets/tchmi_setup_te2000.png
:align: center
:name: figure_tchmi_setup_te2000

TE2000のバージョン選択
```

## プロジェクトの作成

TE2000 TwinCAT 3 HMI Engineering のプロジェクトは、独立したソリューション、または、既存のTwinCATソリューションに追加する方法のどちらも可能です。

Solutionの作成から、