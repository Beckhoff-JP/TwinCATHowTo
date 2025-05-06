# PLC RUN後 しばらく FB_LocalSystemTime で取得した時刻データがUNIXエポックになるのはなぜですか？


```{admonition} 質問
:class: note

`FB_LocalSystemTime` ファンクションブロックで取得した時刻がしばらくUNIXエポック（起源）となるのはなぜでしょうか？

![](assets/2024-02-20-10-27-49.png){align=center}
```

FB_LocalSystemTimeですが、これはADSを経由してWindowsのシステム時間を取得してPLCの変数で使えるようにしたものです。PLCのスタート直後の数サイクルは、ADS通信のハンドシェークされており、現在時刻が分かりませんので、初期値（UNIXエポックの起源時刻）のままとなります。

```{tip}
参考
[https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35008651.html?id=8493962399582191557](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_utilities/35008651.html?id=8493962399582191557)
```
起源時刻であるかどうかを判別する方法は、`FB_LocalSystemTime`で取得したTIMESTRUCT型のタイムスタンプデータをDT型へ変更し、DINTへ変換してください。

```{code}iecst
PROGRAM MAIN
VAR
    fbLocalTime: FB_LocalSystemTime := (bEnable := TRUE);     // For getting current time as local time
    dt_local_time: DT;
    dw_local_time: DINT;
END_VAR

dt_local_time := SYSTEMTIME_TO_DT(fbLocalTime.systemTime); // Current system time as DATE_AND_TIME type.
dw_local_time := DT_TO_DINT(dt_local_time); // A value of dw_local_time will be 0 if dt_local_time is unix epoch.

IF dw_local_time > 0 THEN
    // fbLocalTime.systemTime is available.
END_IF
```