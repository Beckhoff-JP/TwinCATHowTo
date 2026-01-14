(section_exceedcounter)=
# 超過カウンター

ExceedCounterとは、設定したタスクの処理時間に間に合わなかったときにインクリメントされる値です。

使用するサンプルコード
:::{code-block} iecst
:name: code_Sample_ExceedCounter
:emphasize-lines: 7
:lineno-start: 1
:caption: 負荷かけるプログラム
PROGRAM PRG_Counter
VAR
    i	: LINT;
    iCounter	: LINT;
END_VAR

FOR i:=1 TO 100000 DO
    iCounter := iCounter + 1;
END_FOR
:::

ハイライトの値別ExceedCounter
:::{csv-table} loop
:header: Loop, Time, Exceed
:widths: 20, 15, 5

1000, 7.8μs, 〇
10000, 45.8μs, 〇
100000, 485.0μs, ×

:::


タスクの処理時間に間に合っているときは、ExceedCounterは積算されません。({numref}`figure_within_counter`)
```{figure} 2025-12-11-14-42-15.png
:align: center
:name: figure_within_counter

ExceedCounter間に合ってる
```
```{figure} 2025-12-11-14-49-06.png
:align: center
:name: figure_without_counter

ExceedCounter間に合ってない
```

%![](2025-12-11-14-42-15.png){align=center width=400px}

%タスクの処理時間に間に合っているときは、ExceedCounterは積算されていきます。
%![](2025-12-11-14-49-06.png){align=center}

繰り上がったExeedCounterをリセットします。

![](https://infosys.beckhoff.com/content/1033/tc3_system/Images/png/5210442251__Web.png){align=center}

これまでの説明は以下を参照してください。

[infosysのExceedCounterの説明](https://infosys.beckhoff.com/content/1033/tc3_system/5210418059.html?id=8177134032076340246)