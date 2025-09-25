(chapter_job_framework)=
# 並行ジョブ実行フレームワーク

PLCプログラムにおいて実行手順を定義する際には、ST言語であれば状態マシン、ラダー言語であればステップラダーなどが用いられます。ST言語を例にすると、{numref}`state-machine` に示す例のようなプログラムコードをいいます。この例にみられるとおり、`_state`変数に格納された状態に応じて処理が順次実行されたり、場合によっては任意の処理ステップへジャンプすることができます。`CASE`文では、マッチしない`_state`番号のブロックは一切処理が行われません。

{numref}`state-machine` のプログラムでは、`_state = 1`で3秒のディレイ時間を経て、`_state = 2`で外部入力の信号の立ち上がりをカウントし、20回に達するまで`bOutput`をTRUE状態にする、という処理を行っています。

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

この実装例でみられるとおり本来の目的では、状態1はタイマによる処理、状態2はカウンタによる処理、としたいところですが、タイマの後始末や初期化処理がその前後のステップに食い込むなど、明確にプログラムロジックが分かれていません。

PLCは、プログラム全体をサイクリックに処理するので、個々のルーチンが独立して処理される訳ではありません。よって前述のとおり非活性状態のオブジェクトを含む、全体のオブジェクト状態を常に管理し続けなければなりません。これが徹底されていないと変数やオブジェクトが初期化できていないことによる意図しない不具合やバグが生じる可能性があります。

## ジョブフレームワーク

この課題の解決策としてジョブフレームワークについてご紹介します。ジョブフレームワークでは、まず行いたい処理を抽象化し、Futureというインターフェースを実装したファンクションブロックで定義します。

たとえば、`_state = 1`であれば3秒待機する、というシンプルな処理ですが、抽象化するとN秒のパラメータを与えて、実行するとN秒経過してから完了通知が返ってくる、というタスクになります。

これをFutureインターフェースで実装したファンクションブロックで定義します。

まず、N秒という時間を設定する入力変数またはプロパティや、I/O変数を使う場合は入出力変数やREFERENCE等を使ったプロパティで参照渡しします。

次にこれらを用いた処理内容をインターフェースで規定されたメソッドで定義します。まず`init()`で`delay_timer(IN := FALSE)`を定義してTONの初期化を行い、その後`execute()`メソッドでN秒の計測を行い、`quit()`で必要に応じて事後処理を定義します。必要なければ念のために`init()`を実行して変数を初期化してもよいでしょう。（{numref}`fig_future_time_chart`）

これをインスタンス化したものを`FB_executor.future`プロパティにセットすることで、実行することが可能になります。

```{figure} assets/task_time_chart.png
:align: center
:name: fig_future_time_chart

futureオブジェクトの構成
```

簡単に書けるステップシーケンスや状態マシン方式のシーケンスロジックの記述に比べて、わざわざ1ステップの処理毎にファンクションブロック化する必要があり煩わしく思われがちですが、次のメリットがあります。

* 処理毎に必要とする変数やオブジェクトの初期化や後始末ができ、独立性が高まる。つまり、機能の再利用性が高まる。
* プリミティブな処理単位（これ以上割れない単純な単位処理）ごとにファンクションブロック化することで、処理定義を共通化することができる。つまり、いちどFutureを定義すると、様々な個所でインスタンスとして再利用可能なので、むしろ毎回シーケンスロジックを記述する必要性がなくなる。
* 同一フレームワークを用いる限り、様々なマシンに流用することが可能。

このようにFuture単位でライブラリ管理しておくことで、設備開発の生産性は格段に向上することが期待できます。

なお、本フレームワークでは、Futureを定義したファンクションブロックのインスタンスや、これらをまとめて実行するコンテナオブジェクトをまとめて「ジョブ」と呼びます。

### 静的ジョブコンテナ

作成したFutureオブジェクト単体をFB_executorで実行することも可能ですが、多くの場合は複数のタスクを組合せて実行する必要があるでしょう。このためのジョブコンテナと呼ばれるファンクションブロックが提供されます。複数のFutureオブジェクトを逐次実行するFB_BatchJobContainer（{numref}`fig_serial_job_container`）や、並行に同時実行するFB_ParalellJobContainer（{numref}`fig_parallel_job_container`）の2種類があります。

```{figure} assets/run_future_serial.png
:align: center
:name: fig_serial_job_container

逐次処理ジョブコンテナ（`FB_BatchJobContainer`によるJOB配置）イメージ
```

```{figure} assets/run_future_cue.png
:align: center
:name: fig_parallel_job_container

並行処理ジョブコンテナ（`FB_ParallelJobContainer`によるタスク配置）イメージ
```

ジョブコンテナ自身もFutureオブジェクトとしてのインターフェースを実装しています。つまり、それ自体を親となるコンテナオブジェクトの一つのFutureインスタンス（ジョブ）として登録することができます。このように、ツリー状にFutureを構成したジョブを生成することが可能です。（タイミングチャートイメージ：{numref}`fig_job_container_task_image` ）

```{figure} assets/sample_code_job_structure.png
:align: center
:name: fig_job_container_task_image

ジョブコンテナを組み合わせたジョブイメージ
```

### 動的ジョブコンテナ（キュージョブコンテナ）

前節のジョブコンテナは一度Futureを構成すると何度でも再利用可能です。このように一度定義したら変化しないジョブコンテナを静的なジョブコンテナと呼びます。

対して、登録したFutureオブジェクトの実行が終了したら消滅し、随時`add_future()`を実行によりジョブが生成される方式を動的ジョブコンテナと呼びます。

本フレームワークでは、逐次実行する動的ジョブコンテナを`FB_QueueJobContainer`、また、並列実行する動的ジョブコンテナを`FB_ParallelQueueJobContainer`という名前で提供しています。


```{toctree}
:caption: 目次

usage
library_document
```