# UPS Software Componentsのインストールとセットアップ

インストールとセットアップを行う前に、CU81xxのUPSとIPC間をUSBケーブルで接続されていることを確認してください。

## Windows

### インストール

1. 下記のサイトからZIPファイルをダウンロードして、IPC上に解凍してください。
   [UPS configuration software for CU81x0 UPS components](https://www.beckhoff.com/en-en/support/download-finder/search-result/?download_group=860503114)

2. IPC上で `Beckhoff_UPSv*_*_*_*.exe` を管理者モードで実行してインストールを行います。

### 使用方法

[このサイト](https://infosys.beckhoff.com/content/1033/tcupsshellext/15887939979.html?id=49510819811814750)の設定方法をよく読んでお使いください。

## Linux

### インストール

aptパッケージマネージャにて以下の通りUPSサービスをインストールします。

```{code-block} bash
$ sudo apt install upsservice-bhf
[sudo] password for Administrator:
Installing:
  upsservice-bhf

Installing dependencies:
  libupsapi-bhf

Summary:
  Upgrading: 0, Installing: 2, Removing: 0, Not Upgrading: 0
  Download size: 66.9 kB
  Space needed: 346 kB / 9888 MB available

Continue? [Y/n] Y
```

### 使用方法

以下の設定ファイルを編集します。

[参考サイト](https://infosys.beckhoff.com/content/1033/beckhoff_rt_linux/20808458635.html?id=6406935338175224747)

```{code-block} bash
:caption: /etc/upsservice-bhf.conf
## upsservice-bhf.conf ##
Manufacturer Beckhoff
Model Beckhoff_USB_UPS
Interface Beckhoff_USB_UPS
ShutdownOnBatteryEnable 1
ShutdownOnBatteryWait 40
TurnUpsOffEnable 1
TurnUpsOffWait 180
ReplaceNotifyEnable 0
ReplaceNotifyWait 60
```

```{csv-table}
:header: 項目, 単位, 説明

ShutdownOnBatteryEnable, 0/1, 自動シャットダウンを有効にするか否か。1にすると自動シャットダウンする。
ShutdownOnBatteryWait, 秒, 一次電源を消失してから自動シャットダウンを開始するまでの時間
TurnUpsOffEnable, 0/1, IPCのシャットダウン後にUPS電源もOFFするかどうか。1にするとUPS電源もOFFする。
TurnUpsOffWait, 秒, 一次電源を消失してからUPS電源をOFFするまでの時間
ReplaceNotifyEnable, 0/1,Syslogdを通じてUPSのバッテリー交換を通知するかどうか。1にすると通知を行う。
ReplaceNotifyWait, 秒, バッテリー交換通知が必要になった際に通知する周期時間。
```

設定が終わったら、サービスを有効にします。

```{code} bash
$ sudo systemctl enable upsservice-bhf
```

稼働状態は次のコマンドで確認できます。

```{code} bash
$ sudo systemctl status upsservice-bhf
● upsservice-bhf.service - upsservice-bhf
     Loaded: loaded (/usr/lib/systemd/system/upsservice-bhf.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-03-27 01:27:56 UTC; 5min ago
 Invocation: a08c1adbf0ec4008ac904e69557f91a6
   Main PID: 2923 (upsservice-bhf)
      Tasks: 7 (limit: 1048)
     Memory: 1004K (peak: 1.6M)
        CPU: 319ms
     CGroup: /system.slice/upsservice-bhf.service
             └─2923 /usr/bin/upsservice-bhf

Mar 27 01:27:56 BTN-000tr9xa systemd[1]: Started upsservice-bhf.service - upsservice-bhf.
Mar 27 01:27:57 BTN-000tr9xa upsservice-bhf[2923]: Info: upsservice-bhf started.
```

UPSとの通信ができない場合は次のログが出力されます。USBの接続が正しく行われているか確認してください。

```{code} bash
Mar 27 01:27:57 BTN-000tr9xa upsservice-bhf[2923]: Warning: Communication failure!
```

## PLC制御方法

OS側でUPSサービスが稼働していれば、[FB_GetUPSStatus](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_iofunctions/59184523.html?id=2474773387187865285)を使ってUPSの状態を[ST_UPSStatus](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_iofunctions/59234315.html?id=870383754195989439)型で取得することができます。この中の、[ePowerStatus : E_UpsPowerStatus](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_iofunctions/59238923.html?id=6447189444360631604)により一次電源の状態が監視できます。

`PowerOnLine` ではなくなった場合に一次電源を失ったことがわかります。適切なタイミングでPERSISTENT属性の変数を永続化させてください。

また[ST_UPSStatus](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_iofunctions/59234315.html?id=870383754195989439)には、その他にもバッテリー交換の要否やUPSの故障が分かる情報も取得できますので、適切に保守情報の通知機能を実装してください。

これらのPLCの機能をフレームワーク化し、1 second UPS の制御と共通化したい場合は次項へお進みください。