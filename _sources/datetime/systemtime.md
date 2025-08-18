# TwinCAT内部のシステム時計

IPC上には、マザーボード上にボタン電池とクロック回路があり、これによって **Real Time Clock 略して RTC** と呼ばれるハードウェア上の時計があります。ここから、Windows等のOS用の時計、TwinCAT内部の時計、そしてEtherCATのDistributed clock用の時計を個別に3つのソフトウェア時計が生成されます。

```{admonition} 参考InfoSys

[TwinCAT time sources](https://infosys.beckhoff.com/content/1033/ethercatsystem/2469114379.html?id=8514660852001287726)
```

これらのソフトウェア時計は、次の通り初期化時に同期されて以後、CPUの割り込みタイマを基に時刻計測を行います。基本的にCPUの割り込みタイマは単一の発振子によるクロックを基にカウントを行っていますので、個別の時計であっても差が生まれる訳ではありません。しかし、次の要因により差が生まれます。

OSの機能によるシステム時刻の変更
    : WindowsやLinux等は、OSの機能として時刻調整機能を持ちます。また、NTP（Network Time Protocol）を用いてインターネット時刻と自動的に時刻合わせすることもできます。CPUクロックによる時刻カウントでは温度等の影響で誤差が生じますが、これらの手段により時刻合わせする事で常に正しい時刻に合わせることが可能です。対してTwinCATやEthernet DCクロックは、その時刻を用いた制御を行う必要がありますので、標準時刻への追従性や正確性よりも、RUNモードに移行後の時刻連続性が重要視されます。したがって自動的に補正される事はありません。

RTCの時刻変更
    : Windowsは、OSのシステム時刻を変更すると、自動的にBIOSに働きかけてRTCの時刻も変更します。（レジストリで無効化することは可能ですがデフォルト有効です）また、Windowsの由来がデスクトップ向けOSであるように、UTC（世界標準時）ではなくローカルタイムとしてRTCに反映されます。Linuxの場合は次のコマンドを入力しなければOS上のシステム時刻をRTCへ自動反映させることはありません。

    : ```{code} bash
      # hwclock --systohc --utc(local)
      ```
    : また、デフォルトでRTCはUTCとして解釈するため、クラウド等のようにコンピュータの設置場所に依存せず時刻設定することが可能です。代わりにこのコンピュート機能ををユースポイントにおいて、ローカルタイムへの変換を行うことが求められます。

    : このようにOSがRTCを書き換えることによって、TwinCAT内部のシステム時計やEtherCAT DC時計がRTCとの間においても差が発生します。

## TwinCAT内部のシステム時計の仕様

[TwinCAT time sources](https://infosys.beckhoff.com/content/1033/ethercatsystem/2469114379.html?id=8514660852001287726) の "TwinCAT/TC time" 列に記載されている通り、次の通り動作し、参照することができます。

* CONFIGモードからRUNモードへ移行する際に、Windowsのシステム時計（NTファイルタイム）と同期してシステム時計が初期化されます。
* RUNモード移行後は、現在動作しているPLCタスクのCPUコアのベースタイム割り込みを用いて時刻カウントを続けます。この時刻は、 [`F_GetSystemTime()`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_system/3622991755.html?id=6591934602709167291) ファンクションにより取得することができます。
* TwinCATシステム時計の精度は 100 $ns$ です。ただし、カウンタはCPUコアのベースタイム割り込みを利用していますので、カウンタのステップはPLCタスクが動作しているCPUコアのBase time設定に依存します。

## OSと同期した時刻をPLCに読み出すには

PLC内部で時刻を管理し、これらを基にIoTやイベント管理機構における時刻情報はどのように生成すれば良いでしょうか。先述のとおりTwinCATのシステム時刻はCPUクロックのみに頼り、OSの時刻は自動調整されたもので稼働時間が長くなればなるほど両者の間に差が生じます。とはいえ、この差を埋めるために、RUN中にTwinCATのシステム時刻を変更するのはタイミング同期に時刻を使う処理に影響が出ますので行ってはいけません。（というよりもこれを実現する機能は提供されていません。）

このため、TwinCATシステム時刻には影響を与えず、アプリケーション上でOS時刻を取り出して活用するためのいくつかのファンクションやファンクションブロックが用意されています。

たとえば {ref}`chapter_event_logger` の仕組みを用いる場合、TwinCATの制御上で発生した各種アラームの発生、解除時刻は、IoTやデータベースと連携するため **WindowsやLinux等のOS上の時刻** を取り出してその時刻でイベントが発生したことを記録する必要があります。次節ではイベントロガーによるアラーム発報、確認、解除を例にその使い方を説明します。

### イベントロガーの3つのイベント記録メソッド

イベントロガーのうちアラームを管理する `FB_TcAlarm` ファンクションブロックには、アラームの発生を通知する [`Raise()`](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/5050505739.html?id=8432917619912920197) メソッド、確認したことを通知する [`Confirm()`](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/5050451339.html?id=3569329908820721746) メソッド、解除する [`Clear()`](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/5050438027.html?id=8213494572379476886) メソッドが用意されています。それぞれのメソッドには引数の `nTimeStamp` があり、TwinCATシステムタイムの形式である `T_FILETIME64` 型の 64bit 符号なし整数でイベント発生時刻を設定します。

```{tip}
T_FILETIME64型 は ULINT型 の別名となっていますので、各イベントのメソッドの現在時刻引数が求めるULINT型のシステム時刻を代入可能です。
```

この引数が `0` 設定の場合は、[`F_GetSystemTime()`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_system/3622991755.html?id=6591934602709167291) ファンクションにより取得した値と同じ値として記録されます。

このままではWindowsやLinux側の時刻とズレのある時刻でイベント記録されますので、次の処理によってWindowsのシステム時刻を明示的に引数へ与える必要があります。

1. OS時刻を収集

    [`FB_LocalSystemTime`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35008651.html?id=8493962399582191557) ファンクションブロックにより、IPCのOS時刻を収集します。このファンクションブロックの実行中は、設定したサイクル（デフォルト設定5秒）毎にOS側のシステム時刻を周期的に反映します。取り出した時刻はTwinCAT上の [`TIMESTRUCT`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35393035.html?id=8702657298802174446) 型変数上に展開します。

2. UTCに変換する

    Windowsの場合内部システム時刻はローカルタイムとなっています。ここからTwinCATシステム時刻の仕様であるUTCに変換する必要があります。まず、[`FB_GetTimeZoneInformation`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35004043.html?id=63191963117751641) ファンクションブロックにより、現在動作しているWindowsのタイムゾーン設定を [`ST_TimeZoneInformation`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35373067.html?id=2892811750112150085) 型変数で取り出します。 このタイムゾーン情報と、 [`FB_LocalSystemTime`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35008651.html?id=8493962399582191557) で取り出したOSのローカル現在時刻を、[`FB_TzSpecificLocalTimeToSystemTime`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35028619.html?id=1839078549382949049) ファンクションブロックによってUTC（世界標準時）に変換した [`TIMESTRUCT`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35393035.html?id=8702657298802174446) 型変数を取り出します。

3. TIMESTRUCT型をT_FILETIME64型へ変換する

    TwinCATシステム時刻の形式であるT_FILETIME64型へ変換するため、 [`SYSTEMTIME_TO_FILETIME64`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/10501106571.html?id=5646165147131094852) ファンクションを用います。これを `FB_TcAlarm` の各イベントメソッドの引数に用います。 

```{note}
Linuxの場合はRTCおよび内部システム時計はUTCです。この場合手順 2 のローカルタイムからUTCへの変換処理は不要です。
```

以下にプログラム例を示します。`//Alarm処理` 行までの `current_time` を取得するプログラムはPLCの全体で一つで構いません。最短周期のPLCタスクサイクル上で常時実行してください。これにより取り出した `current_time` をアラームの各種イベント時刻として指定します。

```{code-block} iecst
PROGRAM MAIN

VAR
    fbGetTimeZoneInformation    : FB_GetTimeZoneInformation := (bExecute := TRUE);
    localTime                   : FB_LocalSystemTime := (bEnable := TRUE);
    tzinfo                      : FB_GetTimeZoneInformation := (bExecute := TRUE);
    getSystemtime               : FB_TzSpecificLocalTimeToSystemTime;
    current_time                : T_FILETIME64; // TwinCATシステム時刻形式での現在時刻

    // Alarm
    fbSomeAlarm                 : FB_TcAlarm;
END_VAR

// OS現在時刻の取得。bExecuteがTRUEであれば、RUN以後デフォルト5秒おきにWindowsのシステム時刻を取得して systemTime へセットする。
localTime();
// 現在のOSのタイムゾーン情報を収集する。
tzinfo();
// OSの現在時刻からUTCであるシステムタイムへ変換が行われる。
getSystemtime(in := localTime.systemTime, tzInfo := tzinfo.tzInfo);
// T_FILETIME64形式へ変換
current_time := SYSTEMTIME_TO_FILETIME64(getSystemtime.out);

// Alarm処理

IF <<アラーム発生要因>> THEN
    fbSomeAlarm.Raise(current_time);  // アラーム発生時刻をOSの時刻として記録
END_IF

IF <<アラーム確認動作>> THEN
    fbSomeAlarm.Confirm(current_time);  // アラーム確認時刻をOSの時刻として記録
END_IF


IF NOT  <<アラーム発生要因>> 
    AND  <<アラーム解除操作>> THEN
    fbSomeAlarm.Clear(current_time, TRUE);  // アラーム解除時刻をOSの時刻として記録
END_IF

```

```{warning}
コード例には記載していませんが、Event loggerにて `FB_TcAlarm` を使用可能にするには、事前に`Create()`メソッドにてTMCエディタで登録したイベントクラスの各イベントの何れかと関連付けておく活性化処理が必要です。
```
