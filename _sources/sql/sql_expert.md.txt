# SQL expertモードによるPLC実装

[SQL Expertモード](https://infosys.beckhoff.com/content/1033/tf6420_tc3_database_server/2674353931.html?id=997028420171989533) とは、PLC上にSQL文を直接記述し、TF6420を通じてデータベースにデータを読み書きする方式です。対してPLC Expertモードと呼ばれるPLCのデータ型を基にデータベースへのデータ読み書きを実現する方法があり、高速に大量のデータを読み書きする場合にはこちらを選択する方が適しています。

しかしSQL固有の機能である、ストアドプロシージャを実行したり、トランザクションにより複数のテーブル間を整合性を保ったまま読み書きしたい場合は、このSQL expertモードを用いることが求められます。

## PLC上でSQL文を記述するためのTips

### 文字列型の扱い

[`STRING` 型](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2529410443.html?id=2168458334941937554)は単体で宣言した場合のサイズは80Byteです。最大値である255Byteを指定する必要があります。

``` iecst
VAR
    sSampleString : STRING(255);
END_VAR
```

UNICODEを使う場合は、[WSTRING型](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2529437323.html?id=7362291921204401557)を使います。

``` iecst
VAR
    sSampleString : WSTRING(255);
END_VAR
```

### TwinCATにおける文字列リテラルの定義方法

文字列結合
    : SQL文の中にTwinCAT上の変数を埋め込むには、複数の文字列を結合させる必要があります。このとき、[`CONCAT` ファンクション](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_standard/74411019.html?id=147199721235531983)を用います。

エスケープ
    : SQL文の中で文字列を示すには、TwinCAT同様シングルクオートで囲う必要があります。SQL文中のシングルクオートとTwinCATの文字列範囲を示すシングルクオートを区別するためには、`$'`のように、SQL文中のシングルクオートの前に `$` を前置きする必要があります。

```iecst
VAR
    query_text      : STRING(255);
    sSensorName     : STRING;
    iMeasuredValue  : UINT;
END_VAR

query_text := 'INSERT INTO test_table(name, value) VALUES ($'';
query_text := Tc2_Standard.CONCAT(query_text, '$'');
query_text := Tc2_Standard.CONCAT(query_text, sSensorName);
query_text := Tc2_Standard.CONCAT(query_text, '$', $'');
query_text := Tc2_Standard.CONCAT(query_text, UINT_TO_STRING(iMeasuredValue));
query_text := Tc2_Standard.CONCAT(query_text, '$'');
query_text := Tc2_Standard.CONCAT(query_text, ');'); 
```

### 時刻型への変換

イベントが発生した時刻などを記録する場合、TwinCAT上のコンピュータの時刻データを、SQLデータベース上のDATETIME型のカラムへ記録するする事が求められます。

DATETIME型にはタイムゾーンの情報は載りません。世界中で稼働しているエッジIPCのローカルタイムをそのままデータベースに記録すると、様々な地域のタイムゾーンの時刻が混在してしまう事になります。

そこで、どの地域のエッジ側のIPCであろうと、データベースへ記録する際にはUTC（世界標準時）へ変換して記録し、データベースからデータを取り出して活用する際に任意のタイムゾーンへ変換する運用が望ましいです。TwinCATでこれを実現するためのファンクションブロックを次に挙げます。

[FB_LocalSystemTime](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35008651.html?id=8493962399582191557)
    : 現在のコンピュータのロケールのタイムゾーンに調整された、Windows（又はBSD）側の時刻を[`TIMESTRUCT`型](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35393035.html?id=8702657298802174446)として取り出すことができます。

[FB_GetTimeZoneInformation](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35004043.html?id=63191963117751641)
    : 現在のコンピュータのロケールのタイムゾーン情報を[ST_TimeZoneInformation](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35373067.html?id=2892811750112150085)型で取得できます。

[FB_TzSpecificLocalTimeToSystemTime](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35028619.html?id=1839078549382949049)
    : [ST_TimeZoneInformation](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35373067.html?id=2892811750112150085)型によるタイムゾーン情報と、[`TIMESTRUCT`型](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35393035.html?id=8702657298802174446)による時刻情報を入力すると、UTC（世界標準時）の[`TIMESTRUCT`型](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35393035.html?id=8702657298802174446)データが取得できます。

[FB_FormatString](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/34990219.html?id=1443593117929724847)
    : C言語のsprintf関数と同じ書式のフォーマットにより、変数を埋め込んだ文字列を生成できます。変数はさまざまな型のデータを入力できるように、[T_Arg型](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35240075.html?id=8764599832541673086)で指定します。

以上を用いたUTCへ変換されたDATETIME型の文字列を取得するプログラムを次に示します。
```iecst
VAR
    fbLocalTime: FB_LocalSystemTime := (bEnable:=TRUE, dwCycle:=1);     // For getting current time as local time
    fbGetTimeZoneInformation: FB_GetTimeZoneInformation := (bExecute := TRUE);      // For getting local timezone information
    fbTzSpecificLocalTimeToSystemTime: FB_TzSpecificLocalTimeToSystemTime;          // FOr converting local time to UTC.    
    sPrintf: Tc2_Utilities.FB_FormatString;
    _text: TEXT; // datetime type strings for SQL databse.
END_VAR

// for 'datetime' value
// Get local time as timestruct type > convert timezone to UTC > output formatted string as "datetime"
fbLocalTime();
fbGetTimeZoneInformation();
fbTzSpecificLocalTimeToSystemTime(in := fbLocalTime.systemTime, tzInfo := fbGetTimeZoneInformation.tzInfo);
sPrintf(sFormat := '%.4d-%.2d-%.2d %.2d:%.2d:%.2d.%.3d',
        arg1 := F_WORD(fbTzSpecificLocalTimeToSystemTime.out.wYear),
        arg2 := F_WORD(fbTzSpecificLocalTimeToSystemTime.out.wMonth),
        arg3 := F_WORD(fbTzSpecificLocalTimeToSystemTime.out.wDay),
        arg4 := F_WORD(fbTzSpecificLocalTimeToSystemTime.out.wHour),
        arg5 := F_WORD(fbTzSpecificLocalTimeToSystemTime.out.wMinute),
        arg6 := F_WORD(fbTzSpecificLocalTimeToSystemTime.out.wSecond),
        arg7 := F_WORD(fbTzSpecificLocalTimeToSystemTime.out.wMilliseconds));
_text := sPrintf.sOut;
```