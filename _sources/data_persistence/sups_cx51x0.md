# 1 second UPS 制御FB実装

## 1second UPSの仕様

TwinCATが提供している1 second UPSおよびそのファンクションブロックの仕様は以下のとおりです。

### FB_S_UPS_**** ファンクションブロック

機種毎に異なるファンクションブロックがあり、概ね共通して次の仕様となっている。（例：[FB_S_UPS_CX51x0](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_sups/2250113931.html?id=5627610611515898967)）

#### 入力変数

```{csv-table}
:header: 変数名, 型,デフォルト値 ,説明
:widths: 1,1,3,5

sNetID,T_AmsNetId,'',ターゲットコントローラのAmsNetId。自ホストは''
iPLCPort,UINT,0, 複数PLCモジュールがある場合の対象PLCのポート番号の順番。851を先頭とし、0を起点に繰り上げる。
iUPSPort,UINT,16#4A8,1 second UPS状態監視ポート
tTimeout,TIME,DEFAULT_ADS_TIMEOUT,ADS通信のタイムアウト
eUpsMode,E_S_UPS_Mode,eSUPS_WrPersistData_Shutdown,次表参照 
ePersistentMode,E_PersistentMode,SPDM_2PASS,
tRecoverTime, TIME, T#10S, 1次電源断後、再度復活した際に状態が`eSUPS_PowerOK`になるまでの遅延時間。キャパシタ充電が十分でないままこの状態にすると、再度停電になった際に保持変数を行おうとし、この間に電源が完全に失われると保持データが壊れる可能性があります。これを防止するための再充電時間です。
```

#### 出力変数

```{csv-table}
:header: 変数名, 型,説明
:widths: 1,1,8

bPowerFailDetect, BOOL, 1次電源供給されていることを検出されると `TRUE` となる。
eState, E_S_UPS_State, 次表参照
```


### UPS動作モード

次の通り4種類のUPS動作モードを持ちます（[リンク](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_sups/30505867.html?id=7716209737698255724)）

```{csv-table}
:header: 記号, データ型, 説明
:widths: 1,3,7

PS,eSUPS_WrPersistData_Shutdown, 一次電源を失ったら即座にPERSISTENTデータを保存し、その後ただちにシャットダウンする。
P,eSUPS_WrPersistData_NoShutdown, 一次電源を失ったら即座にPERSISTENTデータを保存する。その後は運転を継続する。
S,eSUPS_ImmediateShutdown, 一次電源を失ったら即座にシャットダウンする。
N,eSUPS_CheckPowerStatus, 何もしない。（状態監視のみ）
```

### UPS状態

次の表の通りUPS状態をモニタすることができます。（[リンク](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_sups/30507403.html?id=655678291627447140)）
各動作モード毎に使われる状態が異なります。（モード記号毎に使用される状態に `X` を示します）

```{csv-table}
:header: データ型, 説明, PS, P, S, N
:widths: 2,4,1,1,1,1

eSUPS_PowerOK,1次電源供給,X,X,X,X
eSUPS_PowerFailure,1次電源断（1サイクルのみ）,X,X,X,X
eSUPS_WritePersistentData,保持変数書込中,X,X,,
eSUPS_QuickShutdown,シャットダウン中,X,,X,
eSUPS_WaitForRecover,1次電源断、復活待ち,,X,,X
eSUPS_WaitForPowerOFF,シャットダウン動作開始待ち,X,,X,
```

## 本フレームワークによる動作仕様

TwinCATが提供するファンクションブロックでは、保持変数保存後ただちにシャットダウンするか、シャットダウンを行わないか、の二択だけしか選べません。次の要件を満たすには、`eSUPS_WrPersistData_NoShutdown` モードで制御した上で、電源復活を確認する遅延時間後、[`FB_NT_QuickShutdown`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_sups/30497035.html?id=6766415496240034724)によりPLCからの制御でシャットダウンを行う必要があります。

* 一次電源を失うと、ただちに保持変数を保存する。
* 指定した時間の間電源復活を待つ。この間、および電源復活後もRUNを継続することができる。
* 指定した時間を経過しても1次電源が復活しなかった場合は、直ちにシャットダウンする。

本フレームワークを用いてこれを実現します。

## 実装

次の通り、iUPSのインターフェースからFB_SUPS_CX51x0を実装します。

```{code-block} iecst
:caption: 変数定義部
:name: fb_ups_declearation
:linenos:

FUNCTION_BLOCK FB_SUPS_CX51x0 IMPLEMENTS iUPS
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
    eUPSState         :E_UPSState;
    tShutdownDelay    : TIME := T#1S;
    fbShutdownTimer    :Tc2_Standard.TON;
    fbS_UPS_CX51x0    :Tc2_SUPS.FB_S_UPS_CX51x0;
    fbShutdown        :FB_NT_QuickShutdown;
END_VAR
```


```{code-block} iecst
:caption: UPSStateプロパティの実装
:name: fb_ups_state_property
:linenos:

{warning 'add property implementation'}
PROPERTY UPSState : E_UPSState

GET:
    UPSState := eUPSState;

```

```{code-block} iecst
:caption: シャットダウン遅延時間プロパティ実装
:name: fb_ups_shutdown_delay_property
:linenos:

{warning 'add property implementation'}
PROPERTY shutdown_delay : TIME

GET:
    shutdown_delay := tShutdownDelay;
SET:
    tShutdownDelay := shutdown_delay;

```

{numref}`fb_ups_watch_status`ではFB_S_UPS_CX51x0.eStateの状態に応じて、本UPSオブジェクトFBの状態`eUPSState`を制御します。

核心部は、`FB_S_UPS_CX51x0.eState`の状態が`E_S_UPS_State.eSUPS_WaitForRecover`となった場合（保持変数の保存終了後）の制御部分です。この状態のとき `persist_data` メソッド（{numref}`fb_ups_persist_data`）を実行します。ここで1次電源が失われた状態が連続する時間計測を行う`fbShutdownTimer`が計時され、設定値に達すると、`UPSState`を`E_UPSState.critical_error`に遷移します。

`FB_Shutdown`FB（{numref}`fb_shutdown`） はUPSオブジェクトのこの状態検出により、`shutdown`メソッド（{numref}`fb_ups_shutdown`）の実行に切り替えます。

その前に1次電源が復活すると`FB_S_UPS_CX51x0.bPowerFailDetect`はFailとなるためタイマをリセットします。その後、`FB_S_UPS_CX51x0.tRecoverTime`の設定時間に達すると、`FB_S_UPS_CX51x0.eState`の状態は`E_S_UPS_State.eSUPS_PowerOK`に戻ります。

```{code-block} iecst
:caption: watch_statusメソッドの実装
:name: fb_ups_watch_status
:linenos:

METHOD watch_status : BOOL


fbS_UPS_CX51x0(eUpsMode := Tc2_SUPS.E_S_UPS_Mode.eSUPS_WrPersistData_NoShutdown);

CASE fbS_UPS_CX51x0.eState OF
    Tc2_SUPS.E_S_UPS_State.eSUPS_PowerOK:
        eUPSState := E_UPSState.on_power;
    Tc2_SUPS.E_S_UPS_State.eSUPS_PowerFailure:
        eUPSState := E_UPSState.on_battery;
    Tc2_SUPS.E_S_UPS_State.eSUPS_WritePersistentData:
        eUPSState := E_UPSState.on_battery;
    Tc2_SUPS.E_S_UPS_State.eSUPS_WaitForRecover:
        IF fbShutdownTimer.Q THEN
            eUPSState := E_UPSState.critical_error;
        ELSE
            eUPSState := E_UPSState.on_battery;
        END_IF
    Tc2_SUPS.E_S_UPS_State.eSUPS_WaitForPowerOFF:
        eUPSState := E_UPSState.critical_error;
    Tc2_SUPS.E_S_UPS_State.eSUPS_QuickShutdown:
        eUPSState := E_UPSState.critical_error;
    ELSE
        eUPSState := E_UPSState.init;
END_CASE

```
```{code-block} iecst
:caption: persist_dataメソッドの実装
:name: fb_ups_persist_data
:linenos:

METHOD persist_data : BOOL


IF fbS_UPS_CX51x0.eState = Tc2_SUPS.E_S_UPS_State.eSUPS_WaitForRecover THEN
    fbShutdownTimer(IN:=fbS_UPS_CX51x0.bPowerFailDetect, PT:=tShutdownDelay);
END_IF
```

{numref}`fb_ups_shutdown` が実行されるとEPCはただちにシャットダウンを開始します。

```{code-block} iecst
:caption: shutdownメソッドの実装
:name: fb_ups_shutdown
:linenos:

METHOD shutdown : BOOL

fbShutdown(START := TRUE);
```

