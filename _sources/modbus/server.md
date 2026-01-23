# TF6250 Modbus TCP サーバ

## サービスの起動

以下のフォルダへアクセスします。

```{code} powershell
C:\Program Files (x86)\Beckhoff\TwinCAT\Functions\TF6250-Modbus-TCP\Win32\Server
```

この中の `TcModbusSrv.xml.sample` を次節以後で説明する内容でアクセスを許可したい変数エリアをXMLエディタ（テキストエディタでも可）で定義し、同じ場所へ `TcModbusSrv.xml` として保存してください。デフォルトのまま変更が無ければこの操作は不要です。 `TcModbusSrv.xml` は無い状態でもデフォルト値としてこの設定で動作します。

次にWindowsサービス `TcModbusSrv` を開始すると外部からの接続待ち受けを開始します。

![](assets/windows_service.png){align=center}

```{tip}
次節で説明する各種設定変更を行った場合は、都度このサービスの再起動を行って設定を反映させる必要があります。
```

## 設定

次のとおり `TcModbusSrv.xml` ファイルを直接編集して行います。編集後はサービスを再起動して設定を反映してください。

### 待ち受けTCPポートの変更

```{code-block} xml
<Configuration>
    <Port>502</Port>
```

最初の502を別のポートへ変更してください。併せて、このポートを外部からアクセスできるように、Windowsのファイヤウォール設定で、Inbound側のアクセスを許可設定する必要があります。

```{tip}
TwinCAT BSDの場合はiptables, TwinCAT Linux の場合はnftablesで許可設定を行ってください。
```

### 入出力I/OデバイスのModbusクライアントへの共有

`<InputCoils>` や `<OutputCoils>` セクションは、IOツリー以下にある `%IX`（入力） `%QX` （出力）のアドレスを共有定義するエリアです。TwinCAT3のシステム（IO）デバイスに割り当てられるADSメモリは次のサイトに一覧表があります。

[https://infosys.beckhoff.com/content/1033/tc3_ads_intro/117463563.html?id=5698026452165921197](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/117463563.html?id=5698026452165921197)

このうち、ビットデバイスの入力エリアはインデックスグループ : オフセット `0x0000F021:0x000FA000` にあり、出力エリアはインデックスグループ : オフセット `0x0000F031:0x001F4000` に格納されています。

この設定が次のファイルの通り指定された状態となっています。

```{code-block} xml
<Configuration>
    <Port>502</Port>
    <IpAddr/>
    <Mapping>
        <InputCoils>
            <!-- process image of the physical inputs (bit access) -->
            <MappingInfo>
                <AdsPort>851</AdsPort>
                <!-- Modbus Start Address 0 = 0x0000 -->
                <StartAddress>0</StartAddress>
                <!-- Modbus End Address 32767 = 0x7FFF -->
                <EndAddress>32767</EndAddress>
                <!-- IndexGroup 61473 = 0xF021 PLC process diagram of the physical inputs (%IX field). -->
                <IndexGroup>61473</IndexGroup>
                <!-- IndexOffset 1024000 = 0xFA000 -> The index offset contains the bit address which is calculated from base offset (0xFA000) + byte number +8 + bit number -->
                <IndexOffset>0</IndexOffset>
            </MappingInfo>
                :
        </InputCoils>
        <OutputCoils>
            <!--process image of the physical outputs (bit access) -->
            <MappingInfo>
                <AdsPort>851</AdsPort>
                <!-- Modbus Address 0 = 0x0000 -->
                <StartAddress>0</StartAddress>
                <!-- Modbus Address 0 = 0x7FFF -->
                <EndAddress>32767</EndAddress>
                <!-- IndexGroup 61473 = 0xF031 -> PLC process diagram of the physical outputs(%QX field) -->
                <IndexGroup>61489</IndexGroup>
                <!-- IndexOffset 2048000 = 0x1F4000 -> The index offset contains the bit address which is calculated from the base offset (0x1F4000) + byte number *8 + bit number. -->
                <IndexOffset>2048000</IndexOffset>
            </MappingInfo>
                   :
```

ここに記載されているとおり、bit型のデータが1バイトづつ間隔を空けてADSメモリにマッピングされ、Modbusアドレス `0x0000` ～ `0x7fff` に配置されています。たとえば、次のEL2008の各アドレスは、%QX89.0 ～ %QX89.7 に配置されていることがわかります。

![](assets/2025-11-26-14-48-39.png){align=center}

ここから、Modbusアドレス上では、出力コイルの、 0x0000 $+$ 8 $\times$ 89 $+$ 0 $=$ 712 を先頭に、712～719 （16進数では 0x02C8 ～ 0x02CF）のアドレスで Modbus クライアント側はアクセスすることができます。

同様に `<InputRegisters>` や`<OutputRegisters>` セクションは WORDデバイス（16bit整数サイズ）の入出力データエリアです。こちらについても同様の方法で、EtherCATやEtherNet/IPなどの入出力データを直接モニタ、書き込む事ができます。

### PLC変数シンボルを指定したModbusクライアントへの共有

 PLCプログラム内で定義した変数への共有は、以下のとおり変数名とModbusアドレスの開始～終了アドレスを指定する方法で定義します。初期設定は以下のとおりです。

```{csv-table}
:header: エリア, Modbusアドレス, 変数, 型・サイズ

入力ステータス, 0x8000 - 0x80FF, GVL.mb_Input_Coils, 256点 BOOL型 
出力コイル, 0x8000 - 0x80FF, GVL.mb_Output_Coils, 256点 BOOL型 
入力レジスタ, 0x8000 - 0x80FF, GVL.mb_Input_Registers, 256点 WORD型
出力レジスタ, 0x8000 - 0x80FF, GVL.mb_Output_Registers, 256点 WORD型
```

 必要に応じてサイズや変数を変更・追加・削除してください。

 ```{code-block} xml
<Configuration>
    <Port>502</Port>
    <IpAddr/>
    <Mapping>
        <InputCoils>
                :
            <!-- digitial inputs mapping by variable name -->
            <MappingInfo>
                <AdsPort>851</AdsPort>
                <!-- Modbus Address 32768 = 0x8000 -->
                <StartAddress>32768</StartAddress>
                <!-- Modbus Address 33023 = 0x80FF -->
                <EndAddress>33023</EndAddress>
                <VarName>GVL.mb_Input_Coils</VarName>
            </MappingInfo>
        </InputCoils>
        <OutputCoils>
                :
            <!-- digitial outputs mapping by variable name -->
            <MappingInfo>
                <AdsPort>851</AdsPort>
                <!-- Modbus Address 32768 = 0x8000 -->
                <StartAddress>32768</StartAddress>
                <!-- Modbus Address 33023 = 0x80FF -->
                <EndAddress>33023</EndAddress>
                <VarName>GVL.mb_Output_Coils</VarName>
            </MappingInfo>
        </OutputCoils>
               :
 ```

デフォルトのままであれば、次の通り変数定義を行ってください。

```{code-block} iecst
{attribute 'qualified_only'}
VAR_GLOBAL
    mb_Input_Coils        : ARRAY [0..255] OF BOOL;
    mb_Output_Coils       : ARRAY [0..255] OF BOOL;
    mb_Input_Registers    : ARRAY [0..255] OF WORD;
    mb_Output_Registers   : ARRAY [0..255] OF WORD;
END_VAR
```

### PLCデータのADSインデックスグループ・オフセットを指定したModbusクライアントへの共有

シンボル化されていない様々なPLC内部のADSアドレスは、インデックスグループ `0x4040` にてアクセスできます。このインデックスオフセットは、PLCインスタンスの、`Data Area` タブに一覧されるPLC内部データツリーの `Size` 列に表記されています。

![](assets/2025-11-26-16-44-07.png){align=center}

ここから読み取った値は、次の通りModbusアドレスの`0x6000`～`0x7fff`にマッピングされています。デフォルトの場合のインデックスオフセットは `0` のため、最大 `0x00001FFF` のオフセットまでしか読み取ることができません。インデックスグループ `0x4040` のオフセット範囲は`0x00000000`～`0xFFFFFFFF` と広大なため、必要な個所を適切にセグメントを分けて定義する必要があります。この際、先頭の任意のオフセットアドレスを定義してください。

```{code-block} xml
<Configuration>
    <Port>502</Port>
    <IpAddr/>
    <Mapping>
        <OutputRegisters>
                :
            <!--  PLC data area -->
            <MappingInfo>
                <AdsPort>851</AdsPort>
                <!-- Modbus Address 32768 = 0x6000 -->
                <StartAddress>24576</StartAddress>
                <!-- Modbus Address 32767 = 0x7FFF -->
                <EndAddress>32767</EndAddress>
                <!-- IndexGroup 16448 = 0x4040 - PLC data area -->
                <IndexGroup>16448</IndexGroup>
                <!-- The index offset is byte offset -->
                <IndexOffset>0</IndexOffset>
            </MappingInfo>
                  :
        </OutputRegisters>
    </Mapping>
</Configuration>
```