# TwinCATのドライバセットアップ

TwinCAT側がUDPのクライアントソフトとなり、外部のホストにて、UDPのサーバソフトウェアに対する送受信を実現する例について実装方法を説明します。


### Ethernetドライバの作成

1. TwinCATプロジェクト以下の `I/O` > `Devices` を右クリックし、`Add New Item...`を選択します。

   ![](assets/2023-05-30-17-25-05.png){align=center}

2. `Ethernet` > `RealTime Ethernet Adapter` を選択してOKボタンを押す

   ![](assets/2023-05-30-17-25-41.png){align=center}

3. 作成されたDeviceをダブルクリックして現われたウィンドウから`Adapter`タブを選択し、`Search`ボタンにより、UDPサーバと接続しているネットワークポートを選択します。

   ![](assets/2023-05-30-17-26-41.png){align=center}

   ```{note}
   この操作により選択可能なネットワークポートは、[TwinCATリアルタイムネットワークドライバをインストール](https://infosys.beckhoff.com/content/1033/ethercatsystem/1036996875.html?id=3982258869482331233)したポートのみとなります。
   ```

4. Device1が出来上がっているので、これを右クリックし現われたメニューから`Add Object(s)...` を選びます。

   ![](assets/2023-05-30-17-27-03.png){align=center}

5. `TcIoEth Modules` > `TCP/UDP RT [Module]` を選択してOKボタンを押します。

   ![](assets/2023-05-30-17-27-41.png){align=center}

6. 生成されたオブジェクトをダブルクリックし、現われたウィンドウから`Interface Pointer` タブを開きます。`OTCID` 欄の選択ボタンを押し、追加したデバイスを選択します。

   ![](assets/2023-05-30-17-28-02.png){align=center}

   ![](assets/2023-05-30-17-28-13.png){align=center}

7. 設定したインターフェースのIPアドレスおよびネットワークアドレスを設定します。次図の通り`TcIoIpSettings.ManualSettings`がをTrueに変更し、IPアドレス、サブネットマスク、ゲートウェイ、DHCP有効無効を設定してください。

   ![](assets/2023-09-29-17-15-28.png){align=center}

   ```{note}
   初期値は`TcIoIpSettings.ManualSettings`はFalseとなっています。この設定の場合はリアルタイムドライバを使いつつも、Windowsのネットワーク設定のネットワークカードのTCP/IP V4の設定が反映されます。どちらで設定いただいても構いませんが、反映されるのは`TcIoIpSettings`のパラメータだけですので、その他のパラメータは、[こちら](https://infosys.beckhoff.com/content/1033/tf6311_tc3_tcpudp/1076923531.html?id=1598490380842125290)をご確認の上、必要に応じて適切に設定してください。
   ![](assets/2023-09-29-17-22-18.png){align=center}
   ```
