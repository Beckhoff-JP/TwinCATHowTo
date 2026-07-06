#  チューニング

## Scope viewの準備


Target browser からADS port 350を選択し、Soft Drive - SdScopeVariable に現れる次のの指標を YT Scope 上に記録できるようにします。。

![](assets/target_browser_xts.png){align=center}


Positions
    : * 実位置  ActPos
      * 指令位置　SetPosltp

Velocities
    : * 実速度 ActVelo
      * 指令速度 SetVeloltp

PosError
    : * 位置偏差


![alt scope view chart](assets/scope_view_preperation.png){align=center}

## 共振周波数の除去

可動子および冶具を含めた、固有の共振周波数を除去することで、サーボON時や動作時の共振を抑えることができるようになります。XTSでは「Tuning Assist」機能を用いることで、この共振周波数を除去するための最適値を得ることが可能となります。


1. XtsTuningAssystance用のJobタスクを追加します。
   ![](assets/add_tuning_assystant_task.png){align=center}

2. `TcCOM Objects` にて右クリックのコンテキストメニューかｒ `Add New Item...` を選択し、 XtsMoverTuningAssystant モジュールを追加します。
   
    `XTS Modules` > `Mover Controller Modules` > `XtsMoverTuningAssistant [Module]`
   ![](assets/add_tuning_assystant_object.png){align=center}

3. オブジェクトとタスクを紐づけます
   ![](assets/map_tuning_assystance_objerct_task.png){align=center}


4. チューニングアシスト対象のMoverを選択します。
   ![](assets/tuning_assistance_select_mover.png){align=center}

5. 仮想軸（Axis）の Parameter タブにある `Monitoring` - `Position Lag Monitoring` をFalseに設定変更します。

    ![](assets/tuning_asstance_prep_ignore_lagerror.png){align=center}


6. ![](https://infosys.beckhoff.com/content/1033/tc3_userinterface/Images/png/2878898315__Web.png) Active Configuration を行って下さい。

7. No.1 可動子の検出を行います。
   ![](assets/tuning_assystance_mover1_detection.png){align=center}

8. 該当の可動子のAxisの`Online`タブの`Enabling`からサーボONしてください

9. チューニングをスタートします
   ![](assets/tuning_asstance_start_tuning.png){align=center}

   実施結果は、隣のタブ `Parameter(Online)` のInfo欄の `TuningState` に現れます。もし何等かのErrorが発生した場合は、下部のError Listのメッセージを合わせて確認して対処を行ってください。

   ![](assets/tuning_asstance_status.png){align=center}

10. 保存したい Parameter Set を選択し、Tuning Assistant オブジェクトのオンライン列にパラメータを書き出します
    ![](assets/tuning_assistance_select_parameter_set.png){align=center}

11. チューニングアシストで得られた値をパラメータセットへ反映します
    ![](assets/tuning_assistance_merge_parameter_set.png){align=center}

12. ParameterSetを確認し、反映されていることを確認してください。
    ![](assets/tuning_assistance_check_applyed_parameters.png){align=center}

13. 背景が赤色になっているものは`XTS Parameter Set 1`に保存されていません。右クリックして `Upload` を選択すると赤色背景が消え、設定が`XTS Parameter Set 1`に保存されていることがわかります。
    ![](assets/tuning_assistance_apply_and_upload.png){align=center}

## 速度ループのゲイン調整

```{note}
速度制御を行わない場合でも本節の調整は実施してください。
```

1. TwinCATがRunモードになっていることを確認して、位置制御のパラメータを無効にします。`XTS Parameter Set 1` - `Position Controller` から `Parameter(Init)` の中の `Kp`、`Kp_standstill` の値を `0` にします。そのあと、右クリックで`Download` をクリックします。
 
    ```{tip}
    以後の手順ではいずれも、設定後はぞれぞれ右クリックで`Download` をクリックして、設定値をドライブへ反映してください。
    ```

    ![](assets/pos_control_param_kpzero.png){align=center}

2. 続いて制御モードを速度制御モードにするため、`General` をクリックして、`Parameter(Init)` タブの `OperationMode` を `CyclicSynchronusVelocity` に変更します。

    ![](assets/soft_drive-opmode_9.png){align=center}

3. `Velocity Controller` の `Init Parameter` タブから `Kp`と`Kp_standstil` を `0.01` 、`Tn`と`Tn_standstill`を `0` にセットしてダウンロードします。

    ![](assets/velo_control_kp.png){align=center}

4. `Axis` をクリックして、`Dynamics` タブで加減速度の調整を行います。`Indirect by Acceleration Time` を選択して、以下設定を行い、`Download` をクリックします。
   
    ```{csv-table}
    :header: パラメータ, 値, 単位

    Maximum Velocity,4000,$mm/s$
    Acceleration Time,0.18,$s$
    Deceleration Time,as above,$s$
    Acceleration Characteristic,stiff (バーを一番右へ),
    ```
    ![](assets/axis_dynamics.png){align=center}

5. 可動子をサーボON後、YT Scope Project のグラフ描画画面にいちど移動し、ツールバー付近の ![](../scope_view/image/scope_monitor_start.png) ボタンを押してScope viewを記録スタートさせます。そのあと、`Axis` - `Function` タブで、`Start Mode` をプルダウンメニューから `Velo Step Sequence` を選択。各種値を入力して（値はシステムにより変わる）、`Start` をクリックすると可動子は速度制御モードで動作します。

    ![](assets/start_velo_step_seq.png){align=center}

6. Scope波形で、`SetVeloItp` と `ActVelo` を確認します。 `SoftDrive` - `VelocityCOntrolObj` 内の `Kp` を `0.01` ずつ変更します。（オーバーシュートがないくらいがベスト。 `Kp_standstill` は問題なければ `Kp` と同じ値に設定）

    ![](assets/ytscope_kp.png){align=center}

7. 続いて、`Tn` を大きな値から `0.01` ずつ下げていく（オーバーシュートが速度の10%以内に収まるくらいがベスト。`Tn_standstill` は `Tn` と同じ値に設定）

    ![](assets/ytscope_tn.png){align=center}

8. 設定終了後、3. で設定した `OperationMode` を位置制御モード `CyclicSynchronusPosition` へ変更する。

    ![](assets/soft_drive-opmode_8.png){align=center}

つづいて次節の位置ループゲイン調整を実施してください。

## 位置ループのゲイン調整

1. 可動子をサーボON後、YT Scope Project のグラフ描画画面にいちど移動し、ツールバー付近の ![](../scope_view/image/scope_monitor_start.png) ボタンを押してScope viewを記録スタートさせます。そのあと、`Axis` - `Function` タブで、`Start Mode` をプルダウンメニューから `Reversing Sequence` を選択。各種値を入力して（値はシステムにより変わる）、`Start` をクリックすると可動子は速度制御モードで動作します。

    ![](assets/start_reversing_seq.png){align=center}

2. `PositionControl_Obj` の `Kp` 、`Kp_standstill` の値を、`0.01` から徐々に大きくします。YT Scope波形で、`ActFollowingError` に注目し、この値が一番少なくなるように `Kp` 値を変更します。（`Kp_standstill`は `Kp` と同じ値に設定）

    ![](assets/ytscope_pos_error.png){align=center}


3. ひととおりチューニングが終了したら、つぎのとおり `Position Lag Monitoring`　を有効設定 `TRUE` にします。

    ![](./assets/tuning_asstance_enable_lagerror.png){align=center}


## エリア設定

ストレート部分とカーブ部分では、可動子にかかるモーメント特性が変わるため（特に鉛直使用時）、同じゲイン設定を使用すると、ストレートからカーブ（またはその反対）に乗り移る際に、発振する可能性があります。これを防ぐために、XTSシステムでは、任意の区間を設定して、その区間特有のゲイン設定が可能です。（これをエリア設定と呼ぶ）エリア設定を行うためには、`SoftDrive` の `Parameter(Init)` タブ内にある `ControlAreas` の右側にあるプルダウンメニューから、エリア設定する区間数（この例では2区間）を選択します。その区間数に応じてパラメータが表示されるようになります。

```{csv-table}

IsEnabled, True
StartPosition,エリア開始位置
EndPosition,エリア終了位置
TransitionLength,エリアの移行区間
```