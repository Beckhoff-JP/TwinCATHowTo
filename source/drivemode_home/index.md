# ドライブモード原点復帰の制御方法

CiA402のモータドライブでは、CoE 6060で位置決めモード(CSP)、速度モード(CSV)、トルクモード(CST)、プロファイルモード(PP)など制御方法を選択することができます。この中で、ドライブに対して原点復帰を指示するモード（Homing mode）があり、これを使って原点復帰する手順、およびサンプルコードをご紹介します。

### ドライブモード原点復帰 シーケンス工程一覧

シーケンスは次の表のとおりです。


| ステップ / 状態 | 処理内容と目的 | 使用するファンクションブロック（FB） / 監視オブジェクト |
| :---: | :--- | :--- |
| **0** | **待機状態**<br>Execute（開始トリガ）の立ち上がりを監視し、シーケンスを開始します。 | （シーケンス開始トリガ待ち） |
| **5** | **現在の動作モードを読み取り・退避**<br>後で元の状態に戻せるよう、現在のモード（CSPやCSVなど）を記憶します。 | [`MC_ReadDriveOperationMode`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_mc2/12849198219.html?id=6751247057582187974) |
| **10** | **動作モードを DriveBasedHoming に変更**<br>ドライブ主導の原点復帰を行うため、通信モードを切り替えます。 | [`MC_WriteDriveOperationMode`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_mc2/12849340043.html?id=9029093790854202744) |
| **20** | **Controlword の Bit 4 を ON**<br>原点復帰の開始ビット（Homing Operation Start）を強制的にキックします。 | [`MC_WriteNcIoOutput`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_mc2/13899413643.html?id=8778460833900641042) |
| **30** | **ドライブ側の原点復帰完了を監視**<br>軸のステータス構造体を参照し、Bit 12（Homing attained）が 1 になるのを待ちます。 | `Axis.Status.StatusWord` （Bit 12 監視） |
| **40** | **Controlword の Bit 4 を OFF**<br>原点復帰が完了したため、開始ビットを 0 に戻します。 | [`MC_WriteNcIoOutput`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_mc2/13899413643.html?id=8778460833900641042) |
| **50** | **退避していた元の動作モードへ自動復帰**<br>ステップ5で記憶しておいた元の制御モード（CSPなど）に安全に戻します。 | [`MC_WriteDriveOperationMode`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_mc2/12849340043.html?id=9029093790854202744) |
| **60** | **TwinCAT NC軸側の現在位置を同期・確定**<br>NC軸の現在位置を原点（0.0など）に同期し、内部の原点完了フラグを立てます。 | [`MC_Home`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_mc2/70117515.html?id=384306359223760562) (HomingMode:= MC_Direct) |
| **完了** | **Done := TRUE**<br>すべての処理が安全に終了し、再びステップ0（待機状態）に戻ります。 | （FBの完了フラグ出力） |


### ドライブモード原点復帰 サンプルコード

以下のファンクションブロックにて、`Execute` を立てることでドライブにて原点復帰を開始し、完了時にNC2内部の現在位置をMC_Homeにて0リセットします。ここまでのシーケンスの実行中は`Busy`がTRUEとなります。

```{code-block} iecst

FUNCTION_BLOCK FB_DriveHoming
VAR_INPUT
    Execute             : BOOL;                 // 立ち上がりでシーケンスを開始
END_VAR
VAR_OUTPUT
    Done                : BOOL;                 // シーケンスが正常に完了したらTRUE
    Busy                : BOOL;                 // シーケンス実行中はTRUE
    Error               : BOOL;                 // エラー発生時にTRUE
    nErrId              : UDINT;                // エラーコード (0: 正常)
END_VAR
VAR_IN_OUT
    Axis                : AXIS_REF;             // 対象のNC軸変数
END_VAR
VAR
    // インスタンス化するTwinCAT標準ファンクションブロック (Tc2_MC2)
    fbReadDriveMode     : MC_ReadDriveOperationMode;    // 開始時のモード読み取り用
    fbWriteDriveMode    : MC_WriteDriveOperationMode;   // モード切り替え用
    fbWriteNcOutput     : MC_WriteNcIoOutput;           // Controlword Bit 4 操作用
    fbHomeDirect        : MC_Home;                      // NC軸の座標確定用

    // 内部状態管理
    nState              : INT := 0;
    rTrigExecute        : R_TRIG;                       // Executeの立ち上がり検出

    // モード退避用変数
    eOriginalMode       : E_DriveOperationMode;         // 開始前のモードを保持

    // ドライブ状態監視（毎サイクル抽出）
    nStatusword         : WORD;
    bHomingAttained     : BOOL;                         // Bit 12: 原点完了
    bHomingError        : BOOL;                         // Bit 13: 原点エラー
END_VAR


```

```{code-block} iecst
// 1. Executeの立ち上がりを検出
rTrigExecute(CLK := Execute);

// 2. 軸のStatuswordから原点復帰の進捗ビットを抽出
nStatusword     := Axis.Status.StatusWord;
bHomingAttained := (nStatusword AND 16#1000) <> 0; // Bit 12: Homing attained
bHomingError    := (nStatusword AND 16#2000) <> 0; // Bit 13: Homing error

// 3. モード読み出しFBの常時実行（現在の確定モードを出力させるため）
fbReadDriveMode(Axis := Axis, Execute := TRUE);

// 4. ステートマシンによるシーケンス制御
CASE nState OF

    0: // --- 待機状態 ---
        IF rTrigExecute.Q THEN
            // 出力フラグの初期化
            Done   := FALSE;
            Error  := FALSE;
            nErrId := 0;
            Busy   := TRUE;
            
            // ステップ5: 現在の動作モードを読み取り、退避する
            nState := 5;
        END_IF

    5: // --- ステップ5: 現在の動作モードの読み取り確定待ち ---
        IF fbReadDriveMode.Done THEN
            // 現在のモード（DriveOperationMode_Pos1など）を安全に保持
            eOriginalMode := fbReadDriveMode.DriveOperationMode;
            nState := 10;
        ELSIF fbReadDriveMode.Error THEN
            nState := 90; // 読み取りエラー
            nErrId := fbReadDriveMode.ErrorID;
        END_IF

    10: // --- ステップ10: 動作モードを DriveBasedHoming に変更 ---
        fbWriteDriveMode(
            Axis:= Axis,
            Execute:= TRUE,
            DriveMode:= E_DriveOperationMode.DriveOperationMode_DriveBasedHoming,
            Timeout:= DEFAULT_ADS_TIMEOUT
        );

        // モード変更FBが完了し、実際のモードが反映されたか確認
        IF fbWriteDriveMode.Done THEN
            IF fbReadDriveMode.DriveOperationMode = E_DriveOperationMode.DriveOperationMode_DriveBasedHoming THEN
                fbWriteDriveMode(Axis:= Axis, Execute:= FALSE); // FBリセット
                nState := 20;
            END_IF
        ELSIF fbWriteDriveMode.Error THEN
            nState := 90;
            nErrId := fbWriteDriveMode.ErrorID;
        END_IF

    20: // --- ステップ20: Controlword の Bit 4 (Homing Start) をON ---
        fbWriteNcOutput(
            Axis:= Axis,
            Execute:= TRUE,
            Device:= E_NcIoDevice.NcIoDeviceDrive,
            NcIoOutput:= E_NcIoOutput.NcIoOutputnCtrl1, // メインのControlword (0x6040)
            BitSelectMask:= 16#0010,                    // Bit 4 のみを選択
            BitValues:= 16#0010                         // Bit 4 を 1 に上書き
        );

        IF fbWriteNcOutput.Done THEN
            fbWriteNcOutput(Axis:= Axis, Execute:= FALSE); // FBリセット
            nState := 30;
        ELSIF fbWriteNcOutput.Error THEN
            nState := 90;
            nErrId := fbWriteNcOutput.ErrorID;
        END_IF

    30: // --- ステップ30: ドライブ側の原点復帰完了を監視 ---
        IF bHomingAttained THEN
            nState := 40; // 原点完了、次へ
        ELSIF bHomingError THEN
            nState := 95; // ドライブ側でエラーが発生（Bit13検知）
            nErrId := 16#E001; // 独自のドライブ原点エラーコード
        END_IF

    40: // --- ステップ40: Controlword の Bit 4 をOFFにする ---
        fbWriteNcOutput(
            Axis:= Axis,
            Execute:= TRUE,
            Device:= E_NcIoDevice.NcIoDeviceDrive,
            NcIoOutput:= E_NcIoOutput.NcIoOutputnCtrl1,
            BitSelectMask:= 16#0010,                    // Bit 4 のみを選択
            BitValues:= 16#0000                         // Bit 4 を 0 に戻す
        );

        IF fbWriteNcOutput.Done THEN
            fbWriteNcOutput(Axis:= Axis, Execute:= FALSE); // FBリセット
            nState := 50;
        ELSIF fbWriteNcOutput.Error THEN
            nState := 90;
            nErrId := fbWriteNcOutput.ErrorID;
        END_IF

    50: // --- ステップ50: 事前に退避していた元の動作モードへ自動復帰 ---
        fbWriteDriveMode(
            Axis:= Axis,
            Execute:= TRUE,
            DriveMode:= eOriginalMode, // 退避していた列挙型を指定して復帰
            Timeout:= DEFAULT_ADS_TIMEOUT
        );

        IF fbWriteDriveMode.Done THEN
            IF fbReadDriveMode.DriveOperationMode = eOriginalMode THEN
                fbWriteDriveMode(Axis:= Axis, Execute:= FALSE); // FBリセット
                nState := 60;
            END_IF
        ELSIF fbWriteDriveMode.Error THEN
            nState := 90;
            nErrId := fbWriteDriveMode.ErrorID;
        END_IF

    60: // --- ステップ60: TwinCAT NC軸側の現在位置の同期と確定 ---
        fbHomeDirect(
            Axis:= Axis,
            Execute:= TRUE,
            Position:= 0.0,
            HomingMode:= MC_HomingMode.MC_Direct // 座標強制書き換え（Calibrationフラグが立つ）
        );

        IF fbHomeDirect.Done THEN
            fbHomeDirect(Axis:= Axis, Execute:= FALSE); // FBリセット
            
            // すべての処理が正常終了
            Busy   := FALSE;
            Done   := TRUE;
            nState := 0; 
        ELSIF fbHomeDirect.Error THEN
            nState := 90;
            nErrId := fbHomeDirect.ErrorID;
        END_IF

    90: // --- 一般エラーハンドル（各モーションFBのエラー） ---
        Busy   := FALSE;
        Error  := TRUE;
        // 各種インスタンスのExecuteをリセット
        fbWriteDriveMode(Axis:= Axis, Execute:= FALSE);
        fbWriteNcOutput(Axis:= Axis, Execute:= FALSE);
        fbHomeDirect(Axis:= Axis, Execute:= FALSE);
        
        IF NOT Execute THEN
            nState := 0; // 入力Executeが落ちたら待機状態へリセット
        END_IF

    95: // --- ドライブ起因のエラーハンドル（復帰中のタイムアウトやハードエラー等） ---
        // ドライブ起因のエラーでも、安全のためにステップ40・50を走らせて
        // Controlwordのビットを落とし、元の制御モードに戻してからエラー停止させます
        Busy   := FALSE;
        Error  := TRUE;
        nState := 40; // 強制的にビットクリアおよびモード復帰シーケンスへ流す

END_CASE

```