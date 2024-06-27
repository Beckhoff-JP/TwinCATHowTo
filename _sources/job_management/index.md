# 並行ジョブ実行フレームワーク

制御システムでは、様々な動作や振る舞いを持つサブコンポーネント機器を取り扱う必要があり、これらの特徴に合わせて制御機器システムのソフトウェア開発とテスト（品質管理）に手間や工数をかけなければなりません。

この工数を定量化し、品質のばらつきを低減させるためには、抽象度に応じた設計の分離が欠かせません。

例えばモーション機器であれば、メーカや機種によってI/Oの入出力構成や通信インターフェースはバラバラですが、これらの機器に求める機能はインチング、JOG、原点復帰、リミット制御、位置決め、トルクなどの共通機能に抽象化できます。さらに、これらの機器がどのようなシーンで使われるか、という視点に移すと、保守・調整、生産運転、段取り替えなどの生産現場におけるさまざまなユースケースまで抽象化できます。

このように抽象度の層の間を共通のインターフェースとしておく事により、抽象度の高い機能レベルから取り扱える機器は簡単に付け替えることが可能となります。

ポリモフィズムは、この抽象度の異なるオブジェクト間を共通インターフェースによって結び付け、共通のロジックから様々な異なる具象オブジェクトを取り扱う事ができるようにするオブジェクト指向の機能概念です。

ここでは、制御でよく使われる状態マシンとアクティビティ制御を抽象化し、様々な機器を一様に制御する方法についてご紹介します。

状態マシンとは、{numref}`state-machine` に示す例のようなプログラムコードをいいます。`_state`変数に格納された状態に応じて処理が順次実行されたり、場合によっては任意の処理ステップへジャンプすることができます。`CASE`文では、マッチしない`_state`番号のブロックは一切処理が行われません。

{numref}`state-machine` のプログラムでは、状態1で3秒のディレイ時間を経て、状態2で外部入力の信号の立ち上がりをカウントし、20回に達するまで`bOutput`をTRUE状態にする、という処理を行っています。

```{code-block} iecst
:caption: 状態マシン例
:name: state-machine

VAR
    _state : UINT;
    bStart :BOOL;
    bOutput AT%Q* :BOOL;
    bInput AT%I* :BOOL;
    bComplete :BOOL;
    delay_timer :TON;
    input_edge :R_TRIG;
    counter : DINT;
    delay_time :TIME := T#3S;
    process_count : DINT := 30;
END_VAR


CASE _state OF
    0:
        bOutput := FALSE;
        bComplete := FALSE;
        counter := 0;
        IF bStart THEN
            _state := 1;
        END_IF
    1:
        delay_timer(IN := TRUE, PT:=delay_time);
        IF process_timer.Q THEN
            _state := 2;
        END_IF
    2:
        bOutput := TRUE;
        input_edge(CLK := bInput);
        IF input_edge.Q THEN
            counter := counter + 1;
        END_IF
        IF counter >= process_count THEN
            _state := 3;
        END_IF
    3:
        bOutput := FALSE;
        bComplete := TRUE;
        IF NOT bStart THEN
            _state := 0;
        END_IF
END_CASE
```

このプログラムコードには欠陥があります。`delay_timer` は状態1の時にしか実行されません。このため、状態2に移行した後も`delay_timer`のTONインスタンスの状態は保持されたままとなります。次回この状態マシンを最初から実行し直すと、状態1を実行し始めた時点ですでに前回のタイマ値を保持しており、ディレイ時間の設定値3秒が経過した状態から始まります。よって、一瞬で状態1が終了してしまうこととなります。

従って、{numref}`state-machine2` の通りタイマファンクションブロックを別の状態の際に初期化しなければなりません。

```{code-block} iecst
:caption: タイマファンクションブロックの初期化を施した状態マシン例
:name: state-machine2

CASE _state OF
    0:
        bOutput := FALSE;
        bComplete := FALSE;
        counter := 0;
        IF bStart THEN
            _state := 1;
            delay_timer(IN := FALSE);
        END_IF
    1:
        delay_timer(IN := TRUE, PT:=delay_time);
        IF process_timer.Q THEN
            _state := 2;
        END_IF
    2:
        delay_timer(IN := FALSE);
        bOutput := TRUE;
        input_edge(CLK := bInput);
        IF input_edge.Q THEN
            counter := counter + 1;
        END_IF
        IF counter >= process_count THEN
            _state := 3;
        END_IF
    3:
        bOutput := FALSE;
        bComplete := TRUE;
        IF NOT bStart THEN
            _state := 0;
        END_IF
END_CASE
```

このように、コアとなる処理内容はタイマにより時間計測を行うことですが、その前後で初期化などを行う必要があります。

この実装例でみられるとおり、本来の目的では、状態1はタイマによる処理、状態2はカウンタによる処理、としたいところですが、タイマの後始末や初期化処理がその前後のステップに食い込むなど、明確にプログラムロジックが分かれていません。

PLCは、TcCOMモジュール全体でサイクリックに処理が繰り返されるもので、機能毎に独立して処理される訳ではありません。よって前述のとおり非活性状態のオブジェクトを含む、全体のオブジェクト状態を常に管理し続けなければなりません。これが徹底されていないことにより、不具合やバグが生じる要因となりえます。

そこで、これらの機能モジュール毎にオブジェクトとして抽象化し、分離して管理できる仕組みである、ジョブフレームワークを構築します。


```{toctree}
:hidden:

usage
library_document
```