(section_eip_adapter)=
# TF6280 EtherNet/IP アダプタによるIPCのEthernetポートを使った通信

おおまかな流れ
1. アダプタのIO設定
2. EtherNet/IP専用タスクの作成
3. IO Assembly作成
4. TwinCAT PLCの変数とのリンク
5. 設定したノードのEDSファイルをエクスポート
6. スキャナへの設定

(section_eip_adapter_connection_setting)=
## アダプタのIO設定

1. ソリューションウィンドウからTwinCATツリーの `I/O` > `Devices` のポップアップメニューを出現させ、EtherNet/IP Adapter (Slave) を選びOKボタンを押します。

    ![](assets/2024-12-19-16-04-36.png){align=center}

2. `Device * (TC3 EIP Adapter)` ツリーが出現します。これを線悪してAdapterタブからEtherNet/IPの通信を行うIPCのAdapterのポートを選択する設定を行います。

    ```{tip}
    XAEをターゲットIPCに接続した状態でおこなってください。
    ```

    ![](assets/2024-12-19-17-24-04.png){align=center}

3. `BOX * (TC EtherNet/IP Slave)` ツリーを選択し、Settingタブから、 `8000:0 Slave Settings (BOX *)` ツリーを展開し、IP Address, Network Mask, Gateway Address をそれぞれ設定します。

    ![](assets/2024-12-19-17-39-05.png){align=center}

    ```{csv-table}
    :header: 設定アドレス, 振る舞い

    0.0.0.0, DHCPによる自動割り当てに従います
    255.255.255.255, Windows のネットワークアダプタのオプションで設定したIPアドレスに従います。
    任意のIPアドレスとサブネット, 任意のIPアドレスとしてふるまいます。
    ```

<!--

    ```{tip}
    特別な意図が無い限り、IP Addressには`255.255.255.255`を設定し、Windows側のネットワークのプロパティで固定IPアドレスを設定する運用が望ましいでしょう。使用するアダプタと異なるネットワークアドレスを設定した場合、任意のネットワークカードのIPアドレスを経由したルーティング設定が必要となります。
    ```

    ```{admonition} 任意のアドレスを設定した場合のルーティング設定方法

    任意のIPアドレスに設定する場合は、次の手順が必要となります。

    1. 以下のレジストリパスの`IPEnableRouter`を1に設定します。

           HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters

        ![](assets/2024-12-19-18-21-05.png){align=center}

    2. スキャナと接続しているネットワークカードのIPアドレスを、Windows側のネットワークアドレスと異なるネットワークアドレスに設定します。この上で、管理者権限のターミナルで次のコマンドを入力してください。

        route add <adapter に設定した IP アドレス> 



    ``` 

-->

## EtherNet/IP専用タスクの作成

PLCとリンクしたEtherNet/IPのアダプタIOは、通常スキャナのサイクルによりIOが更新されます。しかし、PLCタスクに依存したままですと、PLCが停止中や、ブレークポイント停止されている間、スキャナとアダプタとの接続が切断されてしまい、スキャナ側から通信異常として認識されてしまいます。

これを防止するため、EtherNet/IP専用タスクを作成し、アダプタにそのタスクを割り当てる設定を行います。

1. タスクを作成します。

    ![](assets/2024-12-24-18-29-45.png){align=center}

2. 次に、I/Oツリーの `Device (TC3 EIP Adapter)` を選択し、 `SyncTask` タブを開き、次の通り設定します。

    Settings
        : Special Sync Taskを選択し、作成した EipTask を選びます。

    Sync Task
        : Cycle ticksに1を設定します。これはEtherNet/IPの最小サイクルタイムが1msであるためです。スキャナ側のサイクルタイムに合わせて設定してください。

    ![](assets/2024-12-24-18-36-15.png){align=center}

(section_create_io_assembly)=
## IO Assembly作成

インプリシットデータとして周期通信を行う入出力データのオブジェクトをIO Assemblyと呼びます。ここではIO Assemblyの構成設定を通じて入力、出力それぞれのデータ構造の定義を行います。コネクションはIO Assembly単位で生成されますので、前述のとおりIO Assemblyごとに入出力合わせて上限 502Byte までのデータが構成可能です。ただし、入力、出力双方において先頭には接続状態、および、制御を行うための4Byte（合計8Byte）のデータが割り当てられます。よって、正味ユーザが割り当てられるデータ領域は502-8=494Byteまでとなります。

これを越えるデータを送受信したい場合は、IO Assemblyに分ける必要があります。{ref}`section_multiple_io_assembly` をご参照ください。

1. `BOX * (TC EtherNet/IP Slave)` ツリー上でコンテクストメニューから `Append IO Assembly` を選択します。

    ![](https://infosys.beckhoff.com/content/1033/tf6280_tc3_ethernetipslave/Images/png/2554796427__Web.png){align=center}

2. Assembly 1 (Input/Output)ツリーのコンテキストメニューから `Add New Item...` を選択します。

    ![](https://infosys.beckhoff.com/content/1033/tf6280_tc3_ethernetipslave/Images/png/2554798091__Web.png){align=center}

3. 現われたウィンドウで、データ形式と転送するデータ数を選択します。同じデータ型を複数作りたい場合は、`multiple`に数値を入れてください。変数名の最後が自動的に連番となる番号が付与されます。

    以下の例では ワード型の変数を 4 個、合計 8 バイトのプロセスデータを作成することを設定し、OKボタンを押します。

    ![](https://infosys.beckhoff.com/content/1033/tf6280_tc3_ethernetipslave/Images/png/2554799755__Web.png){align=center}

    また、配列型を新たに作成することもできます。BYTE型をベースとした、16要素の配列を定義する例を下記に示します。

    ![](assets/2024-12-25-10-32-26.png){align=center}

4. 作成後、それぞれの `Name` を設定しなおす事もできます。

    ![](assets/2024-12-24-17-39-25.png){align=center}

    配列の場合は、子ツリーとなります。

    ![](assets/2024-12-25-10-36-25.png){align=center}


5. 作成したプロセスデータのデータサイズは、`BOX * (TC EtherNet/IP Slave)` ツリーを選択した際の `Setting` タブ内の `8001:07` にて確認することができます。502Byteを超えないようにご注意ください。

    ![](https://infosys.beckhoff.com/content/1033/tf6280_tc3_ethernetipslave/Images/png/2554801419__Web.png){align=center}

## TwinCAT PLCの変数とのリンク

EtherCATのIOリンクと同様の手順となります。

1. 下記の通りプログラム上で `AT%I*` や `AT%Q*` 装飾子を付加した変数宣言し、PLCプロジェクトをビルドします。

    ```{code-block} iecst
    PROGRAM MAIN
    VAR
        eip_inputs  AT%I*    : ARRAY [1..4] OF WORD;
    END_VAR
    ```

2. ビルド成功したら、PLCのプロジェクトに、 `PLCプロジェクト名 instance` というツリーが出現します。これによりIOとの変数マッピングが可能になります。

3. 再度 `IO Assembly` 以下の Input / Output ツリーを選択し、一覧に現れるEtherNet/IPのプロセスデータをひとつづつ選択して、PLC変数とマッピング操作を行います。

    ![](assets/2024-12-24-18-05-54.png){align=center}

これにより、EtherNet/IPのスキャナで交換されるプロセスデータにより、サイクリックに処理されるTwinCAT PLC上の変数として取り扱う事が可能になります。

```{admonition} 変数の型変換について
スキャナ側のデータ型の制約により、 `IO Assembly` に設定するデータ型が必ずしもPLCプログラム上のデータ型と一致しないケースも考えられます。この場合、データ型の変換が必要となります。この方法については{ref}`section_unified_address_mapping` に掲載されているように、共用体を用いたマッピングを行ってください。
```

## EDSファイルの出力

`BOX * (TC EtherNet/IP Slave)` のコンテキストメニューから、`Export EDS File`を選択します。確認ダイアログが出現しますが、いいえを選択してください。

![](assets/2024-12-24-18-52-26.png){align=center}

EDSの保存先を選択して名前を付けて保存します。

## スキャナへの設定

Keyence等のPLC側の設定として、前項のEDSを読み込んで子局として登録してください。

1. ユニットエディタから、KV-8000 CPUユニット、または、KV-XLE0*などのEtherNet/IPに対応したインターフェースユニットを選択し、メニューから `EtherNet/IP設定(F)...` を選びます。

    ![](assets/2024-12-25-15-36-11.png){align=center}

2. TwinCATで生成したEDSファイルを読み込みます。

    ![](assets/2024-12-25-15-37-55.png){align=center}

3. EtherNet/IP機器の一覧に、Beckhoff Automationのツリーの中にXAEで作成したアダプタが現われます。これをダブルクリックすると、アダプタとして登録されます。{ref}`section_eip_adapter_connection_setting` で設定したアダプタのIPアドレスを設定します。

    ![](assets/2024-12-25-15-43-35.png){align=center}

4. 続いてコネクション設定を行います。アダプタを選択してコンテキストメニューから `コネクション設定(N)...` を選んでください。

    ![](assets/2024-12-25-15-44-07.png){align=center}

5. コネクション設定では、様々な通信パラメータを設定できますが、少なくとも次の2点を見直してください。

    PRI（通信周期）
        : 最小　$1ms$ です。

    デバイス割付(D)...
        : EDSファイルで定義されたInput/Outputの変数をどのデバイスにマッピングするかの設定です。

    ![](assets/2024-12-25-15-46-07.png){align=center}

6. デバイス割付では、IN(アダプタから入力)と、OUT(アダプタ)の両方で、それぞれの変数サイズに合ったデバイスに割り当ててください。

    ![](assets/2024-12-25-15-52-47.png){align=center}

7. 設定が完了したら各ウィンドウの `適用` ボタンを押して設定を保存します。

    ![](assets/2024-12-25-15-53-40.png){align=center}

8. 保存した設定をPLCにダウンロードします。

    ![](assets/2024-12-25-15-54-14.png){align=center}

9. PLCがRUNし、アダプタとのEthernetの接続が正常であれば、ツリー上に現われるアダプタのアイコンに、緑色の丸印のオーバラップアイコンが描画されます。

    ![](assets/2024-12-25-15-55-22.png){align=center}

(section_multiple_io_assembly)=
## 複数のコネクション（IO Assembly）を登録する

495Byteを越えるデータを送りたい場合、複数のIO Assemblyを作成する必要があります。この場合は、{ref}`section_create_io_assembly`からの手順を繰り返してください。次のとおりPLCの変数とマッピングされたIO Assemblyが複数登録可能です。

![](assets/2024-12-28-11-37-02.png){align=center}

KV-8000側は次のとおり設定します。

1. IO Assemblyが追加された新しいEDSファイルを読み込みます。構成が上書きされます。

2. 子局を選択し、コンテキストメニューからコネクション設定を選びます。

    ![](assets/2024-12-25-15-44-07.png){align=center}

3. 複数のIO Assemblyが設定されたEDSファイルを読み込むと、デフォルトでさいしょのIO Assemblyのみが有効となっています。その他のIO Assemblyを追加するには、`追加(A)` ボタンを押します。

    ![](assets/2024-12-28-11-43-49.png){align=center}

4. 次図のとおり「有効なコネクションがありません」というダイアログがポッポアップされるまで追加ボタンを何度も押すと、EDSファイルに設定されている全てのIO Assemblyのコネクションがリストされます。

    ![](assets/2024-12-28-11-45-48.png){align=center}

このように、複数のコネクションを登録することで、495Byte以上のデータを送受信することが可能になります。

```{warning}
コネクションの単位であるIO Assembly毎にデータの同期が保証されます。複数のIO Assemblyを跨いでデータ同期性が必要な場合、PLCのロジックにて送受信間の同期処理をおこなってください。
```