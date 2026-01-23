# 技術資料

## システム

### オブジェクト構成

クラス図を{numref}`fig_job_control_class_diagram` に示します。タスクの定義は、`InterfaceFuture`のインターフェースを実装して行いますが、ユーザが実装する基底ファンクションブロック`FB_AbstructFuture`と、各種ジョブコンテナファンクションブロックで実装されています。`FB_Executor`は、ジョブであるFutureオブジェクトの実行主体ですので、1:1の関係で包含します。

また、各種ジョブコンテナは、`FB_Executor`型の配列を内包します。配列サイズはライブラリパラメータ`MAX_FUTURE_NUM`で設定します。これを順に実行する場合はBatchJobContainer、または、QueueJobContainer、並行して同時実行する場合はParallelJobContainer、または、ParallelQueueJobContainerを用います。

このように、ジョブコンテナも、`FB_AbstructFuture`を継承したユーザタスクも、どちらも`InterfaceFuture`が基底インターフェースとなり、同様に`FB_Executor`は実行することができます。

```{tip}
このデータモデルは、コンテナとユーザ定義タスクインスタンスが親子関係を構成し、さらにコンテナの中にコンテナを構成するなど、深いツリーモデルが構築可能です。このデザインパターンを、[GoFのCompositeパターン](https://ja.wikipedia.org/wiki/Composite_%E3%83%91%E3%82%BF%E3%83%BC%E3%83%B3)と呼びます。
```

```{figure} assets/activity_control_class_diag.png
:align: center
:name: fig_job_control_class_diagram

JOB制御クラス図
```

### FB_Executor状態マシン

Futureオブジェクトは処理内容の静的な定義のみ行い、InterfaceFutureのインターフェースをを用いて実行する主体はFB_Executorファンクションブロックです。

FB_ExecutorファンクションブロックではE_FutureExecutionState enum型の変数を持ちた状態を持ち、current_stateプロパティを用いて参照することができます。状態遷移図を{numref}`fig_fb_executor_state_machine`, {numref}`table_state_machine` に示します。

```{figure} assets/fb_executor_state_machine.png
:align: center
:name: fig_fb_executor_state_machine

FB_Executorステートマシン図
```
```{csv-table} E_FutureExecutionState メンバとFB_Executorの状態遷移制御一覧
:header: ステート, 説明, 終了条件
:name: table_state_machine

idle, 初期状態（非活性状態）, FB_Executorが制御するジョブオブジェクトが、idleまたはfinish状態など実行中でない状態であること。
init, futureオブジェクトの初期化処理`init()`を実行している状態。, futureオブジェクトの`init()`が完了する
wait_for_process, 外部からの実行指示待ち状態。, FB_Executorの`start()`メソッドを実行する
process, 実行中状態, futureオブジェクトの`execute()`が完了する
quit, 終了処理状態, futureオブジェクトの`quit()`が完了する
abort, 中断処理中、または中断処理完了状態, 中断処理完了状態で、FB_Executorの`start()`メソッドを実行する
finish, 終了状態（非活性状態）, idleとおなじ
```

## ファンクションブロック

### InterfaceFuture

タスク、および、ジョブコンテナ向けのインターフェースです。

```{csv-table} InterfaceFutureのメソッド一覧
:header: メソッド名, 型, 戻り値 ,説明
:name: table_future_methods

`init`, BOOL , 実行前に必要な変数やオブジェクトの初期化を行います。処理完了時にTRUEを返す必要があります。
`execute`, BOOL , タスク本体の処理を実装します。処理完了時にTRUEを返す必要があります。
`quit`, BOOL , 実行後の変数やオブジェクトの後始末を行います。処理完了時にTRUEを返す必要があります。
`abort`, BOOL , 中断処理が行われた際に実施する処理を実装します。処理完了時にTRUEを返す必要があります。
```

```{csv-table} InterfaceFutureのプロパティ一覧
:header: プロパティ名,型, 方向 ,説明
:widths: 1,1,1,5
:name: table_future_properties

nErrorID, UDINT, GET, エラー発生時は0以外の値を返します。[参照](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/12049349259.html?id=2525089929595466454)
future_name, STRING, GET SET, ジョブ名称を定義します。`FB_Executor`の`job_event_reporter`イベントハンドラにて記録する際に、どのFutureオブジェクトが状態遷移を行ったのか判別できるよう、インスタンスに名前を付けることができます。このプロパティで設定してください。
state, E_FutureExecutionState, GET SET,Futureインスタンスが`FB_Executor`に紐づけられ、init以上の実行状態になると`FB_Executor`の状態をこのプロパティを通じてミラーします。他の`FB_Executor`に同じFutureオブジェクトが共用されてしまった場合、互いの実行状態が競合しないよう、排他を取ることを目的としています。
```

```{admonition} 排他の仕組み
`FB_Executor`内ではidle状態からinit状態に遷移する条件として、リンクされたFutureオブジェクトのstateプロパティを経由して得た状態が、idleまたはfinishである必要があります。すでに他のExecutorにより実行中である場合、Futureオブジェクトのミラーstateの状態がこのいずれの状態でもないため、initへ遷移することができません。先行して取得しているExecutorがfinish状態にすることで後発のExecutorが同じFutureオブジェクトを用いてinitから処理を開始することができるようになります。
```

`InterfaceFuture`インターフェースの名前は[Futureパターン](https://ja.wikipedia.org/wiki/Future_%E3%83%91%E3%82%BF%E3%83%BC%E3%83%B3)から由来しています。複数の演算コアで並列処理を行うのではなく、単一の演算コア上にタスクを順次パイプライン実行していく仕組みにより、処理完了を待たされる（ブロックされる）ことなく処理を進めることができます。実際の演算は将来行われることからFutureパターンと呼ばれています。

このインターフェースにより実装したファンクションブロックをタスクとして、次節に示す`FB_Executor`で統一的に実行することが可能になります。

### InterfaceContainer

ジョブコンテナ用のインターフェースです。

```{csv-table} InerfaceContainerのメソッド一覧
:header: メソッド名, 型, 戻り値 ,説明
:name: table_interface_container_method

`add_future`, UINT, 登録されたFuture番号を返す, ジョブコンテナにFutureを登録する。
`reset`, BOOL , コンテナの初期化完了でTRUEを返す, add_futureで登録したFutureを全てクリアする。
get_future_statue, E_FutureExecutionState, 引数で指定したFuture番号の現在の実行状態を返す, 指定したFuture番号の現在状態を調べる。
```

```{csv-table} InerfaceContainerのプロパティ一覧
:header: プロパティ名,型, 方向 ,説明
:widths: 1,1,1,5
:name: table_interface_container_property

active_futures, UINT, Get, `FB_SerialJobContainer`では現在実行中のFutureの連番を返します。`FB_ParallelJobContainer`では実行中のFuture数を返します。
continuous_mode, BOOL, Set, "全てのfutureが実行完了しても終了せず、新たなfutureが追加されるのを待つモードを有効にします。`QueueJobContainer`, `ParallelQueueJobContainer`のみ有効。"
job_event_reporter, InterfaceJobEventReporter, Set, 包含している`FB_Executor`の各配列にセットする`InterfaceJobEventReporter`実装オブジェクトを受け取ります。
num_of_future, UINT, Get, `add_future`で追加されたFuture数を返します。
parent_executor, REFERENCE TO FB_Executor, Set Get, 親のコンテナジョブオブジェクトが有る場合、そのExecutorオブジェクトにアクセスします。
```


### FB_Executor

`FB_Executor`は、`InterfaceFuture`を実装したファンクションブロックを実行するファンクションブロックです。

```{csv-table} FB_Executorのメソッド一覧
:header: メソッド名, 型, 戻り値 ,説明
:widths: 1,1,2,6
:name: table_executor_methods

`init`, BOOL , 初期化処理完了時にTRUEが返る , タスクの処理を開始できる状態に初期化する。
`execute`, BOOL , タスク処理完了時にTRUEが返る , "`future.init()`, `future.execute()`, `future.quit()`を順次実行します。すべて完了したら戻り値がTRUEになります。"
`abort`, BOOL, 中断処理完了時にTRUEが返る, "`future.init()`、`future.execute()`、`future.quit()` 何れか実行中にこのメソッドを実行すると、`E_FutureExecutionState.abort` の状態に遷移し、`future.abort()`を実行する。"
`start`, BOOL , なし, `E_FutureExecutionState.wait_for_process` 状態時にこのメソッド実行すると、`InterfaceFuture.execute()`処理を、`E_FutureExecutionState.abort` の状態の際にこのメソッドを実行すると、中断する前に実行していた`future.init()`、`future.execute()`、`future.quit()`の処理を再開する。
```

```{csv-table} FB_Executorのプロパティ一覧
:header: プロパティ名,型, 方向 ,説明
:widths: 1,1,1,5
:name: table_executor_properties

nErrorID, UDINT, GET, エラー発生時は0以外の値を返します。[参照](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/12049349259.html?id=2525089929595466454)
active_task_id, UINT, GET, `FB_SerialJobContainer`や`FB_ParallelJobContainer`の実行状態がモニタできます。`FB_SerialJobContainer`の場合は現在処理中のFuture番号を返します。`FB_ParallelJobContainer`では、実行するFutureの合計数を返します。いずれも`executing()`メソッド実行中以外は0を返します。
current_state, E_FutureExecutionState, GET, `execute()`中の実行状態を返します。
future, InterfaceFuture, SET, 実装したタスクをセットします。
done, BOOL, GET, InterfaceFutureで実装した`execute()`の処理が完了後TRUEを返します。
ready, BOOL, GET, InterfaceFutureで実装した`init()`の処理が完了後TRUEを返します。
job_event_reporter, InterfaceJobEventReporter, SET, InterfaceJobEventReporter実装ファンクションブロックのインスタンスをセットします。`FB_Executor`の状態遷移時には、イベントハンドラとしてこのインスタンスの`report()`メソッドが呼び出されます。
```

`start()`メソッドや、`ready`、`done`プロパティはタスク同士を連続して実行する際、InterfaceFutureの`init()`や`quit()`の処理によりサイクルの隙間が発生しないようにするトリガやイベントです。

(section_InterfaceJobEventReporter)=
### InterfaceJobEventReporter

`FB_Executor`の状態変化時にコールされるイベントハンドラ用のインターフェースです。このインターフェースを実装したファンクションブロックインスタンスを、`FB_Executor`の`job_event_reporter`にプロパティにセットして使います。

reportメソッド
    : `FB_Executor`の処理で状態遷移が発生した際にコールされるイベントハンドラ。
    : 引数
        : old_state
            : 型
                : E_FutureExecutionState;
            : 説明
                : 状態遷移が発生する旧状態
        : new_state	
            : 型
                : E_FutureExecutionState;
            : 説明
                : 状態遷移が発生する新状態
        : record_time
            : 型
                : Tc2_Utilities.T_FILETIME64;
            : 説明
                : 状態遷移が発生したWindowsファイルタイム（100ns精度）
        : executor
            : 型
                : REFERENCE TO FB_Executor; 
            : 説明
                : 状態遷移の発生元`FB_executor`インスタンスへのリファレンス
    : 戻り値
        : 型
            : BOOL
        : 説明
            : イベントハンドラ処理が終了したらTRUEを返す


## データ型

### E_FutureExecutionState

```{csv-table}
:header: 名称, 値, 説明
:widths: 1,1,8

idle, 0, 未実行状態
init, 1, 初期化中状態
wait_for_process, 2,初期化完了で実行指示待ち。start()メソッドによりprocessへ移行。
process, 3,実行中状態
abort, 4,中断処理中、または、中断処理完了状態。中断処理完了状態であれば、start()メソッド実行することで、再度中断前の状態に遷移する。
pause, 5,未使用
quit, 6,終了処理中状態
finish, 7,全処理完了状態
```