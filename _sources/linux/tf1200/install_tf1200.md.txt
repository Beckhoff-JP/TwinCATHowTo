# TF1200のインストールとHMI画面設定

ここでは、IPC起動後、自動的に sway ウィンドウマネージャが起動し、自動ログインしてブラウザウィンドウをキオスクモード（全画面化）でTF1810-PLC HMI WEBを表示する設定について説明します。

まず、TF1200をインストールします。

```{code} bash
$ sudo apt install tf1200-ui-client
```

## 自動ログイン、自動GUIモード起動設定

インストール後、基本設定スクリプトを実行します。

```{code} bash
$ cd /etc/TwinCAT/Functions/TF1200-UI-Client/scripts
$ sudo ./setup-full.sh --user=TF1200 --autologin --autostart
```

このあと、コンピュータを再起動してください。


```{csv-table}
:widths: 3,7
:header: パラメータ, 説明

`--user`, 上記のとおり `TF1200`を指定すると、`/home/TF1200` のように、LinuxのOSユーザとしてTF1200が追加され、`video`グループに所属します。このユーザでディスプレーマネージャが起動します。設定後はこのユーザへスイッチユーザコマンド `su` にて切り替えて wayland や swayの設定を行う必要があります。
`--autologin`, IPC起動後、`--user` で作成したユーザにオートログインします。
`--autostart`, IPC起動後 wayland および sway が自動起動します。ターミナルモードのままにしておく場合は、この指定を行わないでください。
```

```{warning}
`--user` に管理者権限のある既存ユーザ（rootやAdministrator）を指定しないでください。
```

## TF1810（PLC HMI WEB） 全画面表示化の設定

ブラウザウィンドウを TF1810 のURLへ変更します。まず、TF1200ユーザへ切り替えて、ホームディレクトリへ移動します。

```{code} bash
$ su TF1200
$ cd
```

次に、TF1200の設定ファイルを編集します。

```{code} bash
$ nano ./.config/TF1200-UI-Client/config.json
```

以下の2行の通りに変更します。

```{code-block} json
:caption: `~TF1200/.config/TF1200-UI-Client/config.json` の編集

{
        :
    "enableKioskMode": true,
        :
    "startUrl": "http://127.0.0.1:42341/Tc3PlcHmiWeb/Port_851/Visu/webvisu.htm",
        :
}
```

## 日本語フォントのインストール

```{code} bash
$ sudo apt install fonts-noto-cjk
```

## サウンドと設定ツールのインストール

```{code} bash
$ sudo apt install pulseaudio rtkit pavucontrol
```