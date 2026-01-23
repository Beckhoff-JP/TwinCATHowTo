# Windowsイベントロガーとの連携

Windowsイベントロガーは、イベントビューアなどを通じてWindowsアプリケーションのエラー等を統括して監視できる仕組みです。Zabbix等の監視ツールと組み合わせて、TwinCATの稼働状態を統合監視することも可能になります。

ここでは、TwinCATのイベントロガーを、Windowsイベントログに残す設定を行い、そのログの見方をご説明します。

## 連携設定

詳細は、[こちらのサイトの “Save messages in the Windows Error Log” の3つの設定](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/4852763019.html?id=8056479848926168568)をご覧ください。

````{tip}

次のレジストリキー内の、`TypesSuported` の値を 3 へ変更すると、全てのイベントを記録できます。

`Computer\HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Beckhoff\TwinCAT3\EventLogger\WindowsEventLog`

````

この設定を行ってから再起動すると有効になります。

## イベントビューアの見方

その際のTwinCATのログはWindowsイベントビューワで確認する事ができますので、以下の手順でご確認ください。

1. IPCのWindowsデスクトップのタスクトレーのTwinCATアイコンを右クリックし、コンテキストメニューから `Tools` > `Event Viewer` を出現します。

    ![](assets/2025-08-26-11-14-00.png){align=center}

2. イベントビューアが現れたら、ツリーメニューから `Windowsログ` > `Application` を選択します。一覧するのにしばらく時間を要します。

3. 現れたイベント一覧から、ソースが “TcSysSrv” のものがTwinCATのログとなります。この中のエラーを選択して、全般タブの詳細をご確認ください。

    ![](assets/2025-08-26-11-14-46.png){align=center}

4. エラーを保存して誰かへレポートするには、選択してポップアップメニューから `選択したイベントの保存(V)...`を選択して evtx ファイルを保存して報告者へ送ります。

    ![](assets/2025-08-26-11-15-16.png){align=center}

