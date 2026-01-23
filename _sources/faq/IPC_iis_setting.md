# IPCの各種情報をブラウザで提供するBECKHOFF Device ManagerのWEBサービスを起動させるにはどうすればよいですか？

## BECKHOFF Device Managerへのアクセス方法

IPC上でブラウザを立ち上げ、以下のURLでアクセスしてください。

[http://localhost/config](http://localhost/config)

## BECKHOFF Device Managerを表示しているWEBサーバの有効、無効切替

IPCのPLC HMI WEBや BECKHOFF Device Manager WEB等は、WindowsのInternet Information ServiceのWEBサービス機能を利用しています。

Windows Internet Information Serviceは、以下の手順で有効化してください。

1. スタートメニューのSettingsを開き、検索窓に `Turn Windows features on or off` を入力してエントリを探します。

    ![](assets/2024-09-26-13-47-01.png){align=center}

2. 見つかりましたら起動し、現われたウィンドウのツリーの中のInternet Information Services以下が次図の通りのチェックとなっているか確認してください。
設定変更があればOKボタンを押していただいて、念のためIPCを再起動してください。

    ![](assets/2024-09-26-13-36-02.png){align=center}