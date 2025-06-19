# Configurator 手順



## EtherCAT接続とFreeRunへの移行

```{list-table}
:widths: 1, 30, 60

* - 1
  - I/O > Devices > Scan を選択する。
  - ![DeviceScan](assets/DeviceScan.png){align=left}

* - 2
  - 注意文が出るので OK を押す。
  - ![Scan警告](assets/scan_warning.png){align=left}

* - 3
  - EtherCAT 接続されたポートを選択(自動)して OK を押す。
  - ![接続先の決定](assets/select_port.png)

* - 4
  - Scan for boxes のダイアログが出るので、Yes を選択する。
  - ![ScanForBoxes](assets/ScanForBoxes.png)

* - 5
  - 接続されたデバイスが登録されます
  - ![](assets/complete.png){height=500px}
```

以上でFreeRun モードでEtherCATサブデバイスが認識されます。

## Configuratorの起動

```{list-table}
:widths: 30, 60

* - TwniCAT > XPlanar > Configurator を選択する。
  - ![MenuBar_Configurator](assets/MenuBar_Configurator.png)
```

## Parts 設定

タイル設定を行います。

1.`Parts`ボタンを押し、中央グラフィックのマトリックスから配置しているタイルの形状となるよう、個々のタイルクリックします。クリックした個所は明るい色にハイライトされます。

  ![Configurator_Parts](assets/Configurator_Parts.png){align=center}
  

```{list-table}
:widths: 1, 60, 40

* - 2
  - 画面左上の Factory Settings から ScanBTN を選択する。
    ````{tip}
    FreeRun モードでないと Scan BTNs で Device が見つかりません。
    ````
  - ![Parts_ScanBTN](assets/Parts_ScanBTN.png)

* - 3
  - Tile Settings から Assign BTNs で適切な BTN を割り当てる。
  - ![Parts_AssignBTN](assets/Parts_AssignBTN.png){width=300px}    
    ![Parts_SelectBTN](assets/Parts_SelectBTN.png){width=300px}

* - 4
  - 全て選択すると下記のようになります。
    (BTN はご使用の XPlanar 固有のものになります。)  
  - ![Parts_RegisterBTN](assets/Parts_RegisterBTN.png){width=300px}
```

## Mover 設定

上部のボタンから使用する Mover 種類を選択し、タイル上に使用する個数だけクリックして可動子を配置します。  

![Configurator_Mover](assets/Configurator_Mover.png)

## Real-Time 設定

1. `Real Time` ボタンを押す
  ![Configurator_Real-Time](assets/Configurator_Real-Time.png)

```{list-table}
:widths: 1, 60, 40

* - 2
  - 使用する Core の割り当てを入力する。  
  - ![Real-Time_SystemSetting](assets/Real-Time_SystemSetting.png){width=300px}

* - 3
  - Reassign Modules を選択する。
    Isolated Core に設定するため`Restrict CPU Count`に 1 を入れます。
  - ![Real-Time_CpuInformation](assets/Real-Time_CpuInformation.png){width=300px}
* - 4
  - Isolated CPUs の 250 µs のコアに割り当てられているか確認する
  - ![Real-Time_IsolatedCore](assets/Real-Time_IsolatedCore.png){width=300px}

```

## 設定データの出力

下記の操作にて次の処理が行われます。処理が完了するまでTwinCATのプロジェクトを閉じない様に注意してください。

* bmlファイルの出力
* TwinCATのモーション軸の生成

次の手順を実行します。
1. 上部メニューから Export を選択する
  ![Configurator_Menu](assets/Configurator_Menu.png)

```{list-table}
:widths: 1, 30, 60

* - 2
  - 確認画面で Yes を選択する。
  - ![Export_Confirmation](assets/Export_Confirmation.png)

* - 3
  - Console 画面が表示される。
  - ![Export_Console](assets/Export_Console.png)

* - 4
  - 処理が完了すると、自動的にbmlファイルが生成されたフォルダをエクスプローラで開かれます。
  - ![TagetFile](assets/TagetFile.png)
    ```
    C:\TwinCAT\Functions\TF5890-TC3-XPlanar-Technology\mllib_toolbox\target
    ```

* - 5
  - これらのファイル全てを選択し、ターゲットIPCの以下のフォルダへ配置してください。
  - ![BmlFile](assets/BmlFile.png)
    ```
    C:\TwinCAT\3.1\Target\Config\XPlanar\bml
    ```

* - 6
  - TwinCAT XAE 上のプロジェクトには、SYSTEM, MOTION に自動でオブジェクトが登録されます。
  - ![FinishConfiguration](assets/FinishConfiguration.png)
```