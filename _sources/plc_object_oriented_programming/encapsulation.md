# カプセル化

量産設備の制御プログラムでは、同じ機能を持つ複数モジュールが存在することがよくあります。このようなモジュールを制御するPLCプログラムの作り方として、現在多くの開発現場ではグローバル変数を使って、モジュール毎に異なるアドレスや変数を割り当てる方法で実装されているケースが多いのではないでしょうか。

![](assets/no_encapsulated_model.png){align=center}

このようなプログラム構造では、次の問題が生じます。

* 3つのモジュールは全て同じ機能であるにも関わらず、モジュール毎に個々に正しい動作を行うかテストする必要がある。
* テスト中にバグが発生すると、3つのモジュールともに修正が必要となる。
* 今後10, 20, 100とモジュールを増やしていくたびに同じ作業が生じる。
* 改造を行うと既存のモジュール全てにその反映を行う必要がある。また、この場合も反映した全てに対する動作確認が必要になる。
* グローバル変数の状態によって内部ロジックの挙動に影響を与えてしまい、 **タイミングや条件によって何が起こるか分からない** ソフトウェアとなる。

想像しただけで毎日深夜までプログラムを作りこんで、装置の前に座り込んで、何が起こるか分からないプログラムのバグ潰しとの闘い、というライフワークバランスとは程遠いエンジニアの姿が目に浮かびます。

## カプセル化

この問題を解消するのが **カプセル化** です。カプセル化に則って実装するソフトウェアは次のことが実現できています。

1. モジュールの内部機能は「ローカル変数」のみでロジックを組む。これによりコピーしても同一のメモリ上には存在しないことが保証される。
2. 外部とのデータとの受け渡しは、内部のロジックへの影響が全て予測可能となる「アクセッサ」を通して行う。内部の変数やロジックは外部から隠蔽する。
3. アクセッサが定義されたモジュール機能に名前を付けることを「型」と呼ぶ。
4. 他の機能との連携は、「型」を通して行う。互いの内部には、予測不可能な状態で影響を与えることが無く「安全」にアクセスできる。

```{tip}
多くのPLCで採用されているIEC-61131-3の第2版のファンクションブロックの機能で実現できることは1の項目までになります。2～4は、第3版以降でのみ実現できる機能です。同じIEC-61131-3対応と謳っていても、大きな違いがありますのでご注意ください。 TwinCATは第3版まで対応しています。
```

![](assets/encapsulated_model.png){align=center}

上記の図では、`Module control` や、`Module communication` という「型」を定義し、これらの実体（インスタンス）をモジュールとして複数定義しています。まず言えるのは、この「型」をデバッグさえすれば、モジュールが3個だろうが、10個だろうが、100個だろうが、全て同じ振る舞いになることが保証されます。これだけでデバッグや改造工数が減ることが分かるでしょう。

 `Module control` という型には、「Velocity」、「Acceleration」、「Deccleration」というアクセッサを持っています。アクセッサでは、内部のロジックで使われる変数とは **別のもの** です。アクセッサによってのみ外部から影響を与えることが可能ですので、ここだけをテストすれば全てが「予測可能な状態」になります。これにより安全にモジュールへ働きかけることが可能になります。

```{admonition} カプセル化に基づくソフトウェアの品質工程
ソフトウェア用語として `Module Control` のような型を「モデル」、モジュール1, モジュール2, モジュール3のように型を実体化したものを「インスタンス」と呼びます。ソフトウェアの設計フェーズにおいて、モデル定義とインスタンス実装は全く異なるプロセスです。

モデル定義では個々の型となるファンクションブロックそのものの品質検査を行います。この工程を「単体テスト」と呼びます。そのあと実際のシステムとしてモデルからインスタンスを実装し、これらが連携した状態で動作をテストします。この工程を「結合テスト」と呼びます。

単体テストが対象とするソフトウェアは抽象度の高い「モデル」ですから、実際のI/Oが存在していない状態でもシミュレーション上でテストを実施することが容易です。つまり、抽象度の高いモデル設計ができていれば、実機ができあがる前に品質を固められる「フロントローディング」が可能になります。

また、ソフトウェア変更を行った際には、再度単体テストを実施することで、既存機能に対する影響を確認することができます。単体テストは手動で行うのではなく、テストフレームワークを導入すればテストコードを記述して自動化する事も可能です。ソフトウェア変更時には必ず単体テストが自動実行されるようにする事で、ソフトウェア変更に対する品質向上に役立てられます。

最近では、Github等のリポジトリへ変更反映した際、テストコードを自動実行する仕組みがあります。これを用いて自動テストを実行させることができ、テストをパスしたものをTwinCATのブートイメージとして実装（デプロイ）まで自動化するCI/CD（Continuous Integration / Continuous Development）が提唱されています。
```

## ファンクションブロック

ファンクションブロックとは、プログラム機能の「型」を定義するものです。あくまでも「型」ですので、実際に動作するプログラムではありません。

型の内部のプログラムロジックは隠蔽されていて、外部とのデータの受け渡しは、入力変数、出力変数を通じて行います。

![](assets/function_block_example.png){align=center}

具体的なプログラム例は下記の通りです。`VAR_INPUT` は入力変数。ロジックが実行した結果は出力変数 `VAR_OUTPUT` に出力されます。また、入力と出力どちらもできる変数は `VAR_IN_OUT` に定義します。

```{code} iecst
FUNCTION_BLOCK FB_ModuleControl
VAR_INPUT
    Position : LREAL;
    Velocity : LREAL;
    Acceleration : LREAL;
    Deceleration : LREAL;
    iCommand : INT;
    bExecute
END_VAR
VAR_OUTPUT
    bBusy : BOOL;
    bError : BOOL;
    iErrorCode : UDINT;
END_VAR
VAR_IN_OUT
    axis : AXIS_REF;
END_VAR
VAR
    nState : UDINT;
    move_absolute : MC_MoveAbsolute;
END_VAR

(* ここからプログラムロジック定義部 *)

IF NOT bExecute THEN
    nState := 0;
ELSE
    nState := 1;
END_IF

CASE nState OF
    0:
        bBusy := FALSE;
    1:
        IF iCommand = 1 THEN
            move_absolute(Execute := FALSE);
            nState := 2;
        END_IF
    2: // PTP moving
        move_absolute(
            Execute := bExeucte,
            Position := Position,
            Velocity := Velocity,
            Acceleration := Acceleration,
                :
        );
        bBusy := move_absolute.Busy;
        bError := move_absolute.Error;
        iErrorCode := move_absolute.ErrorID;
    :
END_CASE
```

上記を「型」として宣言したファンクションブロックを使って、実体化するプログラムをMAIN上に実装します。実体化した変数を **インスタンス変数** と呼び、型を基に複数の実体を生成することが可能です。

下記の例では、module1, module2, module3の3軸分の実体を定義しています。

```{code} iecst
PROGRAM MAIN
VAR

    Axis1 : AXIS_REF;    Axis2 : AXIS_REF;    Axis3 : AXIS_REF;

    module1 : FB_ModuleControl := (Axis := Axis1, Position := 0, Velocity := 150, Acceleration := 500, Deccleration := 500); // モジュール1の制御プログラム
    module2 : FB_ModuleControl := (Axis := Axis2, Position := 200, Velocity := 250, Acceleration := 500, Deccleration := 500); // モジュール2の制御プログラム
    module3 : FB_ModuleControl := (Axis := Axis3, Position := 300, Velocity := 550, Acceleration := 500, Deccleration := 500); // モジュール3の制御プログラム

    move_start  AT%I*   : BOOL; // スタートボタン入力
    nState : UINT;

END_VAR

CASE nState OF
    0: 
        module1(bExecute := FALSE);
        module2(bExecute := FALSE);
        module3(bExecute := FALSE);
        IF move_start THEN
            nState := 1;
        END_IF
    1: 
        // 実行
        module1(iCommand := 1, bExecute := TRUE); // 軸1は0へ移動
        module2(iCommand := 1, bExecute := TRUE); // 軸2は200へ移動
        module3(iCommand := 1, bExecute := TRUE); // 軸3は300へ移動
        IF module1.bBusy THEN
            nState := 0;
        END_IF
END_CASE
```

## IEC-611131-3の第2版でカプセル化を実現する方法

ここで問題となるのは`Velocity`や`Position`などの入力変数です。この変数は何のチェックも経ずそのままロジックで使用されています。したがって、不正な値をセットした場合でもその通り実行しようとします。せっかく「型」として機能を抽象化したにも関わらず、その流用可能なバリエーションの範囲が不明確なので、品質上の問題を引き起こします。

これを防ぐのがアクセッサの役割です。第2版ではアクセッサの機能はありませんので、次のとおりプログラム内で入力変数や出力変数と内部変数（`_Position` のように `_` を付加した変数）を分離することから始めます。さらに、入力変数などから内部変数へ受け渡す際に想定している正しい値の範囲であることをチェックします。

```{code} iecst
FUNCTION_BLOCK FB_ModuleControl
VAR_INPUT
    Position : LREAL;
    Velocity : LREAL;
    Acceleration : LREAL;
    Deceleration : LREAL;
    iCommand : INT;
    bExecute
END_VAR
VAR_OUTPUT
    bBusy : BOOL;
    bError : BOOL;
    iErrorCode : UDINT;
END_VAR
VAR_IN_OUT
    axis : AXIS_REF;
END_VAR
VAR
    nState : UDINT;
    move_absolute : MC_MoveAbsolute;
    (*内部ロジック用変数*)
    _Position : LREAL;
    _Velocity : LREAL := 600;
    _Acceleration : LREAL := 200;
    _Deceleration : LREAL := 200;
END_VAR

(* ここからプログラムロジック定義部 *)

IF NOT bExecute THEN
    move_absolute(Execute := FALSE);
    bBusy := FALSE;
    RETURN;
END_IF

CASE nState OF
    0:
        bBusy := FALSE;
    1:
        (*直前にパラメータセット。正常範囲チェックを行う*)
        _Position := Position;
        IF Velocity > 0 AND Velocity <= 1500 THEN
            _Velocity := Velocity;
        END_IF
        IF Acceleration > 0 AND Acceleration <= 500 THEN
            _Acceleration := Acceleration;
        END_IF
        IF Deceleration > 0 AND Deceleration <= 500 THEN
            _Deceleration := Deceleration;
        END_IF
        IF iCommand = 1 THEN
            move_absolute(Execute := FALSE);
            nState := 2;
        END_IF
    2: // PTP moving
        move_absolute(
            Execute := bExeucte,
            Position := _Position,
            Velocity := _Velocity,
            Acceleration := _Acceleration,
                :
        );
        bBusy := move_absolute.Busy;
        bError := move_absolute.Error;
        iErrorCode := move_absolute.ErrorID;
    :
END_CASE
```

上記のコードであれば、不正な値がセットされた場合はデフォルト値のままで動作することができ、不正な値で動作させることを防止できます。可能性として不正な値で動きようがありませんから、品質保証できる範囲を絞り込む事も可能です。カプセル化に求められる本質はこのように外部と内部で変数を分けておく **疎結合** ( **Decoupling** ) です。

しかしこの場合、bExecuteやbBusyなど、相変わらず直接ロジックに使用しています。全てを内部変数を経由するコードをプログラム上に定義すると冗長となり、可読性の悪いプログラムとなります。このため、言語仕様として外部アクセスするための機構と内部変数をマッピングする方法を定義する機能を提供するのがオブジェクト指向におけるアクセッサの役割となります。

### 参照型変数

次はファンクションブロック同士の連携方法です。システムをモデル化する際、単一のファンクションブロックだけで成り立つことは稀です。複数のファンクションブロックが互いに関連しあって全体の振る舞いが定義できます。このような重層的なソフトウェア構造のモデル化はどのように実現するのでしょうか。

たとえば、マシン異常時における全体の振る舞いを定義したファンクションブロックがあるものとします。このファンクションブロックは、個々のモータ軸のモジュールに対して停止指示したり、逆に特定のモータモジュールが故障した事を検出して、全体を止める役割を担っているものとします。このように、一つのインスタンスが複数のインスタンスに影響しあう事はよくあるモデルです。

この連携機能をファンクションブロックの入力変数、出力変数だけを用いて実現しようとすると、ファンクションブロック内部のモデル定義だけで実現することは不可能です。なぜなら、この「全体」と「一部」の関係において、幾つのモジュールが存在するかは **MAINプログラムでインスタンス変数を定義するまで分からない** からです。

この場合の唯一の実現方法としては、MAINプログラム内でインスタンス化した各モータ軸モジュールのエラー出力変数を取り出し、マシン異常監視モジュールの入力変数に通知する必要があります。逆に、何れかのアラームが発生している場合は、全モジュール停止するようにロジックを組む必要があります。

このようにインスタンス変数が無い状態では、モータ軸モジュールのファンクションブロックとマシン異常処理のファンクションブロック間での関連を定義することはできないのです。

この問題を解決するのが「参照型変数」という仕組みです。

![](assets/function_block_var_inout.png){align=center}

ファンクションブロックに用意された `VAR_IN_OUT` は、入出力変数と呼ばれますが、本質的には外部から実体を渡すのではなく、ショートカット（参照）を渡す仕組みを提供しています。ファンクションブロック内部では、実体ではありませんので、複数のモジュール全てが受け取るのは同一のインスタンスです。

![](assets/reference_aggregation.png){align=center}

この例では、module1 ～ module3まで全て、fbErrorHandlerというインスタンスを VAR_IN_OUT で受け取っています。これにより、module1～3全てが、このインスタンスを操作することができるのです。

module1 ～ module3インスタンスのモデルである、FB_ModuleControlの中では、次の様に実装されています。


```{code} iecst
FUNCTION_BLOCK FB_ModuleControl

VAR
    move_absolute : MC_MoveAbsolute;
    stop          : MC_Stop;
END_VAR

     :
VAR_IN_OUT
    axis : AXIS_REF;
    error_hander : FB_ErrorHander;  // FB_ErrorHander の参照型変数を定義
END_VAR

     :

CASE nState OF
    0:
        bBusy := FALSE;
    1:
        IF iCommand = 1 THEN
            move_absolute(Execute := FALSE);
            nState := 2;
        END_IF
    2: // PTP moving
        move_absolute(
            Execute := bExeucte,
            Position := Position,
            Velocity := Velocity,
            Acceleration := Acceleration,
                :
        );
        bBusy := move_absolute.Busy;
        bError := move_absolute.Error;
        iErrorCode := move_absolute.ErrorID;
    :
END_CASE

IF bError THEN
    error_hander.setAlarm(THIS^);  // アラームハンドラーに異常を通知する
END_IF

// アラームハンドラーがエラーを検出したら停止する。
IF error_hander.getState(level := E_Severity.Error) THEN
    stop(Execute := TRUE, Axis := axis);
ELSE
    stop(Execute := FALSE, Axis := axis);
END_IF

```

`error_hander` は、`FB_ErrorHander` 型の参照型変数です。実体ではありませんが、この型が提供する機能を使って、モジュールのエラー状態を通知したり、他のモジュール含めてマシン全体がエラー状態になったことを検出し、停止処理を行っています。

参照型へインスタンスを受け渡すのは、MAINプログラムでは次の通り行います。まず `fbErrorHander` インスタンスを定義し、これを各モジュールの参照型変数にロードします。

```{code} iecst
PROGRAM MAIN
VAR

    Axis1 : AXIS_REF;    Axis2 : AXIS_REF;    Axis3 : AXIS_REF;

    fbErrorHander : FB_ErrorHander; // マシン異常を通知するファンクションブロックのインスタンス変数

    module1 : FB_ModuleControl := (
        axis := Axis1, 
        error_hander := fbErrorHander, 
        Position := 0, Velocity := 150, Acceleration := 500, Deccleration := 500
    ); // モジュール1の制御プログラム

    module2 : FB_ModuleControl := (
        axis := Axis2, 
        error_hander := fbErrorHander,
        Position := 200, Velocity := 250, Acceleration := 500, Deccleration := 500
    ); // モジュール2の制御プログラム
    
    module3 : FB_ModuleControl := (
        axis := Axis3, 
        error_hander := fbErrorHander,
        Position := 300, Velocity := 550, Acceleration := 500, Deccleration := 500
    ); // モジュール3の制御プログラム

    move_start  AT%I*   : BOOL; // スタートボタン入力
    nState : UINT;

END_VAR

CASE nState OF
    0: 
        module1(bExecute := FALSE);
        module2(bExecute := FALSE);
        module3(bExecute := FALSE);
        IF move_start THEN
            nState := 1;
        END_IF
    1: 
        // 実行
        module1(iCommand := 1, bExecute := TRUE); // 軸1は0へ移動
        module2(iCommand := 1, bExecute := TRUE); // 軸2は200へ移動
        module3(iCommand := 1, bExecute := TRUE); // 軸3は300へ移動
        IF module1.bBusy THEN
            nState := 0;
        END_IF
END_CASE
```

このように、モデル設計時にモジュール間の連携機能を定義することができます。
