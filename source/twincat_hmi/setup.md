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

