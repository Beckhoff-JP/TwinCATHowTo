# デモソフトウェア解説

デモソフトウェアは以下から取得できます。本節ではこのソフトウェアについて解説します。

[https://github.com/Beckhoff-JP/TE1111SimulationSample.git](https://github.com/Beckhoff-JP/TE1111SimulationSample.git)

このようにファンクションブロックの単位で機能とそのシミュレータ環境を構築し、Visualizationで、双方の操作ができるようにしておくことで、様々なケースに対する振る舞いをチェックすることができます。

## 制御側

PLCプロジェクト `DevelopmentProject` が制御用のPLCプロジェクトとなります。

### Cylinder FB

次の入出力変数を持つファンクションブロック`Cylinder`をMAINプログラムでインスタンス化して使います。

インスタンスに対する各種プロパティの入出力や操作は、後述するVisualizationにて行います。


入力
    : ```{csv-table}
        :header: 変数, 型, 初期値, 説明
        :widths: 2,1,1,6

        bExecute, BOOL, `False`, Trueにすると周期的なピストン運動を開始します。
        push_edge_time, TIME, `T#0.5S`, 押し側の近接センサの安定確認時間。
        pull_edge_time, TIME, `T#0.5S`, 引き側の近接センサの安定確認時間。
        limit_time, TIME, `T#3S`, 移動開始あとこの時間以内に動作完了しなければ動作超過時間エラー発生する。
        keep_actuator, BOOL, `FALSE`, TRUEにすると移動完了後もその方向で励磁し続ける。2位置電磁弁などを用いる場合はTRUEにする。
        stroke_wait_time, TIME, `T#5S`, 周期的なピストン運動において、片側への移動動作が完了してからの待機時間。
        ```

出力
    : ```{csv-table}
        :header: 変数, 型, 初期値, 説明
        :widths: 2,1,1,6

        status, position_status, `unknow`, "現在の状態がposition_statusで定義した`unknow`, `moving`, `inposition`のどの状態にあるかを返します。"
        position, _2_position, , "`position_1`, `position_2`のいずれかの現在位置を返します。"
        bError, BOOL, `FALSE`, 移動動作時間超過エラーや、安定確認後に近接センサが不正な入力状態となった場合にbErrorとなります。同時にstatusは`unknown`となります。bExecuteを`FALSE`にするとエラーは解除されます。
        ```

入出力
    : ```{csv-table}
        :header: 変数, 型, 初期値, 説明
        :widths: 2,1,1,6

        io, cylinder2IO, , "近接センサ2点, 電磁弁出力2点をまとめた構造体型のIO"

### Visualization

RUNモードにおいてLoginしてからVISUs以下のVisualizationを選択することで{numref}`develop_visu` のようなデバッグ用のHMI操作画面が現れます。

:::{figure-md} develop_visu
![](assets/2023-09-14-10-39-47.png){align=center}

制御側のVisualization操作画面
:::
```{csv-table}
:header: 名称, タイプ,説明
:widths: 2,2,7

Start, ボタン,ピストン動作を開始するモードへ移行（Active）します。Alarmが発生した場合は一度このボタンを押してDeactiveするとリセットできます。
Active,ランプ,Startボタン操作によりActive状態になるとランプが点灯します。
Alarm,ランプ,移動動作時間超過エラーや、安定確認後に近接センサが不正な入力状態となった場合にエラーとなり動作を停止し、このランプが点灯します。
Over time, スライダ, 移動動作時間超過エラーが発生するまでの設定時間を設定します。
push stabilization, スライダ, 押し側の近接センサの安定確認時間を設定します。
pull stabilization, スライダ, 引き側の近接センサの安定確認時間を設定します。
Waiting time, スライダ, ピストン動作の片側移動後の待機時間
Keep excitation, チェックボックス, チェックすると片側移動後にin positionとなっても電磁弁に励磁し続けます。
in position, ランプ, 移動動作にターゲットの近接センサの安定確認時間連続したセンサ入力を確認したらin positionとなり、このランプが点灯します。
四角, アイコン, 近接センサの入力状態。
矢印, アイコン, 押し側、引き側の電磁弁への励磁状態。
```


## シミュレーション側

PLCプロジェクト `SimulationProject` がシミュレーション用のPLCプロジェクトとなります。

### Cylinder FB

次の入出力変数を持つファンクションブロック`Cylinder`をMAINプログラムでインスタンス化して使います。

インスタンスに対する各種プロパティの入出力や操作は、後述するVisualizationにて行います。


入力
    : ```{csv-table}
        :header: 変数, 型, 初期値, 説明
        :widths: 2,1,1,6

        push_time, TIME, `T#3S`, 押し側の動作時間
        pull_time, TIME, `T#1S`, 引き側の動作時間
        push_release_time, TIME, `T#150MS`, 押し側への動作開始後、引き側の近接センサをFALSEにするまでの時間
        pull_release_time, TIME, `T#150MS`, 引き側への動作開始後、押し側の近接センサをFALSEにするまでの時間
        chattering_push, BOOL, TRUE, TRUEにすると、押し側移動動作でpush_time経過後、しばらく押し側の近接センサの状態チャタリング動作を行う。
        chattering_pull, BOOL, TRUE, TRUEにすると、引き側移動動作でpull_time経過後、しばらく引き側の近接センサの状態チャタリング動作を行う。
        chattering_time, TIME, T#2S, チャタリング動作を継続する時間設定
        chattering_hl_time, TIME, T#50MS, チャタリングの半周期（＝High Levelの時間）設定。
        ```

入出力
    : ```{csv-table}
        :header: 変数, 型, 初期値, 説明
        :widths: 2,1,1,6

        io, cylinder2IO, , "近接センサ2点, 電磁弁出力2点をまとめた構造体型のIO"


### Visualization

RUNモードにおいてLoginしてからVISUs以下のVisualizationを選択することで{numref}`simulation_visu` のようなデバッグ用のHMI操作画面が現れます。各設定項目は、前述のCylinderファンクションブロックの入力変数と同名となっていますので、説明は割愛します。

:::{figure-md} simulation_visu
![](assets/2023-09-14-11-32-22.png){align=center}

シミュレータ側のVisualization操作画面
:::

## Scope view

テストの動作状況を目視するには、Scope viewを用いると便利です。PLCのタスクサイクルの粒度での値が記録され、時系列でのグラフ表示が行われます。

サンプルプロジェクトでは、ソリューションエクスプローラの最下部にScopeプロジェクトを同梱しており、電磁弁出力、近接センサ入力状態がプロットできるようなチャート設定となっています。

ターゲットのIPCに併せて{numref}`te1111_simulation_scope_view` に示す手順で設定を変更して記録を行ってください。

1. YT Scope Projectを右クリックし、コンテキストメニューから`Property`を選択し、Property画面を表示します。
2. Headless Mode欄のMain-Serverフィールドを、Local hostではなく接続先のIPCを選択します。
3. 記録開始アイコンをクリックして記録を開始してください。停止させたい場合はこのアイコンの隣の停止アイコンをクリックして停止させることができます。

:::{figure-md} te1111_simulation_scope_view
![](assets/2023-09-14-11-03-32.png){align=center}

Scope view設定と記録
:::

```{note}
Scope viewにて任意の変数を監視対象にしたい場合は、
{ref}`section_reg_target_variable` 以後をご覧ください。
```