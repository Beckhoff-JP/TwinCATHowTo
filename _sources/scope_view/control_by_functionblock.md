# ファンクションブロックによるスコープ記録開始、停止制御

Scopeサーバをファンクションブロックからリモート制御できます。TE1300 Scope viewにてScopeプロジェクトを生成し、コンフィグファイル`config.tcscopex` というファイル名で保存します。

下記のメインプログラムのとおり、HMI.bRecordToScopeフラグをTRUEにしている間の収集データを、`C:/ProgramData/scope` 以下に、`record_YYYYMMDD_hhmmss-YYYYMMDD_hhmmss.svdx` という書式で開始日時と終了日時の入ったファイル名で記録します。

![](assets/2023-11-09-15-08-37.png){align=center}

## メインプログラム

``` iecst

VAR
    fbScopeController      :FB_ScopeController;
    bReset                 :BOOL;
END_VAR

fbScopeController(
    bExternalTriggerEvent := HMI.bRecordToScope, // 記録スイッチ
    bReset := bReset,                   // エラーリセット信号
    sSaveDir := 'C:/ProgramData/scope', // コンフィグと記録データを保存するディレクトリ指定
    sSaveFileNamePrefix := 'record_',   // 記録データの接頭語
    sConfigFile := 'config.tcscopex'    // コンフィグファイル名
    );

```


## ファンクションブロック

``` iecst

FUNCTION_BLOCK FB_ScopeController
VAR_INPUT
    bExternalTriggerEvent:  BOOL := FALSE; // 立ち上がり時に記録開始。立下りで記録終了。
    bReset:     BOOL := FALSE;   // エラー時のリセットフラグ
    sSaveDir:   STRING; // 保存ファイル、コンフィグファイル保存先ディレクトリ
    sSaveFileNamePrefix:    STRING; // 保存ファイル名の接頭語
    sConfigFile:    STRING; // TE1300で保存したコンフィグファイル名
END_VAR
VAR_OUTPUT
    eCurrentState: E_ScopeServerState := SCOPE_SERVER_IDLE; // 現在のScope制御状態
    bError: BOOL := FALSE; // エラーフラグ
    nErrorId: UDINT := 0; // エラーコード
END_VAR
VAR
    fbScopeServerControl: FB_ScopeServerControl;
    eRequestedState: E_ScopeServerState := SCOPE_SERVER_IDLE;
    fbLocalTime: FB_LocalSystemTime := (bEnable:=TRUE, dwCycle:=1);     // For getting current time as local time
    sPrintf: Tc2_Utilities.FB_FormatString;
    _text_current : STRING;
    _text_start: STRING(255); // datetime type strings for SQL databse.
END_VAR
```



``` iecst

// for 'datetime' value
// Get local time as timestruct type > output formatted string
fbLocalTime();
sPrintf(sFormat := '%.4d%.2d%.2d_%.2d%.2d%.2d',
        arg1 := F_WORD(fbLocalTime.systemTime.wYear),
        arg2 := F_WORD(fbLocalTime.systemTime.wMonth),
        arg3 := F_WORD(fbLocalTime.systemTime.wDay),
        arg4 := F_WORD(fbLocalTime.systemTime.wHour),
        arg5 := F_WORD(fbLocalTime.systemTime.wMinute),
        arg6 := F_WORD(fbLocalTime.systemTime.wSecond));
_text_current := sPrintf.sOut;

CASE eCurrentState OF
SCOPE_SERVER_IDLE:
    IF bExternalTriggerEvent THEN
        eRequestedState := SCOPE_SERVER_CONNECT;
        IF fbScopeServerControl.eReqState = eRequestedState AND NOT fbScopeServerControl.bBusy AND NOT bError  THEN
            eCurrentState := eRequestedState;
        END_IF
    END_IF
SCOPE_SERVER_CONNECT, SCOPE_SERVER_START:
    IF bExternalTriggerEvent THEN
        eRequestedState := SCOPE_SERVER_START;
        IF fbScopeServerControl.eReqState = eRequestedState AND NOT fbScopeServerControl.bBusy AND NOT bError  THEN
            eCurrentState := eRequestedState;
        ELSE
            _text_start := CONCAT(_text_current, '-');
        END_IF
    ELSE
        eRequestedState := SCOPE_SERVER_STOP;
        IF fbScopeServerControl.eReqState = eRequestedState AND NOT fbScopeServerControl.bBusy AND NOT bError  THEN
            eCurrentState := eRequestedState;
        END_IF
    END_IF
SCOPE_SERVER_STOP:
    eRequestedState := SCOPE_SERVER_SAVE;
    IF fbScopeServerControl.eReqState = eRequestedState AND NOT fbScopeServerControl.bBusy AND NOT bError  THEN
        eCurrentState := eRequestedState;
    ELSE
        fbScopeServerControl.sSaveFile := CONCAT(CONCAT(sSaveDir, '/'), CONCAT(sSaveFileNamePrefix,CONCAT(CONCAT(_text_start, _text_current), '.svdx')));
    END_IF
SCOPE_SERVER_SAVE:
    eRequestedState := SCOPE_SERVER_DISCONNECT;
    IF fbScopeServerControl.eReqState = eRequestedState AND NOT fbScopeServerControl.bBusy AND NOT bError  THEN
        eCurrentState := eRequestedState;
    END_IF
SCOPE_SERVER_DISCONNECT:
    IF bExternalTriggerEvent THEN
        eRequestedState := SCOPE_SERVER_CONNECT;
        IF fbScopeServerControl.eReqState = eRequestedState AND NOT fbScopeServerControl.bBusy AND NOT bError  THEN
            eCurrentState := eRequestedState;
        END_IF        
    END_IF
SCOPE_SERVER_RESET:
    eRequestedState := SCOPE_SERVER_IDLE;
    IF fbScopeServerControl.eReqState = eRequestedState AND NOT fbScopeServerControl.bBusy AND NOT bError THEN
        eCurrentState := eRequestedState;
    END_IF
END_CASE

IF bError AND bReset THEN
    eRequestedState := SCOPE_SERVER_RESET;
    IF fbScopeServerControl.eReqState = eRequestedState AND NOT fbScopeServerControl.bBusy THEN
        eCurrentState := eRequestedState;
    END_IF
END_IF

fbScopeServerControl.sConfigFile := CONCAT(CONCAT(sSaveDir, '\'), sConfigFile);

fbScopeServerControl( sNetId:= '',
                    tTimeout:= T#5S,
                    eReqState := eRequestedState,
                    bError=>bError,
                    nErrorId=>nErrorId
                    );
```