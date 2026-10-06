# オーバーサンプリング入出力ターミナル同士でDC同期させてYT Scopeへプロットする

Beckhoffのアナログ出力ターミナル **EL4732** と、高精度アナログ入力モジュール **ELM3004** を例に相互接続し、**DC（Distributed Clocks）タイムスタンプを用いて完全同期** させたデータを TwinCAT 3 Scope View にオーバーサンプリング表示させるための設定手順です。

---

## EtherCAT I/O 側のオーバーサンプリング・DC設定

両ターミナルでDC同期およびオーバーサンプリングのPDO（プロセスデータ）を有効化します。

### EtherCAT マスタの確認
1. TwinCATの I/O ツリーから **EtherCAT Master** を選択します。
2. **`DC`** タブを開き、`Advanced Settings...` ＞ `Distributed Clocks` から、マスタがDC動作（基準クロックが有効）していることを確認します。

### EL4732（アナログ出力側）の設定
1. EL4732 の **`DC`** タブを開き、Operation Mode を **`DC-Synchron (Oversampling)`** に設定します。
2. **`Process Data`** タブ（またはSync Manager 2）を開きます。
3. **`StartTimeNextOutput`**（インデックス `0x1A82` 等に含まれるタイムスタンプ情報）のチェックボックスをオンにし、PDOマッピングに追加します。

### ELM3004（アナログ入力側）の設定
1. ELM3004 の **`DC`** タブを開き、同様に **`DC-Synchron (Oversampling)`** に対応するモードを選択します。
2. **`Process Data`** タブを開き、入力配列データとともに **`Timestamp`** がPDO（有効なプロセスデータ）に含まれていることを確認します。

```{attention}
双方の「EtherCATタスクサイクルタイム」と「オーバーサンプリング倍率」から計算されるサンプリング周期（例：1ms ÷ 10倍 ＝ 100kHz）が一致、または同期の取れる整合性のある値になっていることを確認してください。
```
---

## PLCプログラムでのデータ受けと定義

Scope Viewで「配列データ」として認識させるため、PLC側で変数（ARRAY）を定義してI/Oとリンクします。

### PLC変数の定義（例：10倍オーバーサンプリングの場合）

``` iecst
VAR
    // ELM3004用（10倍オーバーサンプリング入力）
    aInputData   AT %I* : ARRAY[1..10] OF INT; 
    nInputTime   AT %I* : ULINT; // ELM3004から受け取る Timestamp
    
    // EL4732用（10倍オーバーサンプリング出力）
    aOutputData  AT %Q* : ARRAY[1..10] OF INT;
    nOutputTime  AT %I* : UDINT; // EL4732から受け取る StartTimeNextOutput
END_VAR
```

### I/O とのマッピング

1. プログラムを一度ビルド（Build）します。
2. I/Oツリーの各ターミナルから、以下のデータを上記で定義したPLC変数へ **`Link To...`** で結合します。
   
    ```{csv-table}
    :header: ターミナル, IO, リンク先変数 
    ELM3004, `Value`（配列データ全体）, `aInputData`
    ELM3004, `Timestamp`,`nInputTime`
    EL4732, `Value`（配列データ全体）, `aOutputData`
    EL4732, `StartTimeNextOutput`, `nOutputTime`
    ```

## TwinCAT 3 Scope View での設定（タイムスタンプの紐付け）

Scope側で「配列（データ本体）」と「時間情報（タイムスタンプ）」を結びつけ、グラフ上にドットを展開します。

1. **Scopeプロジェクトの追加**
   * TwinCATソリューションに `TwinCAT Measurement Project` を追加し、Scope Viewを開きます。
2. **変数の追加**
   * `Target Browser` から、PLCの **`aInputData`** および **`aOutputData`** をScopeのチャート（Axis）にドラッグ＆ドロップします。
3. **オーバーサンプリング設定の変更**
   * Scope内に配置した各チャネル（aInputData / aOutputData）を選択し、**Properties（プロパティ）ウィンドウ**を開きます。
   * **`Oversampling`** 項目を **`True`** に変更します。
   * **`Time Stamp Symbol`**（または `External Time Stamp`）項目を選択し、それぞれのターミナルに対応する時間変数（入力側は `nInputTime`、出力側は `nOutputTime`）を指定します。

---

## 実行と確認

1. TwinCATを **`Activate Configuration`** してRunモードにします。
2. Scope Viewの **`Start Record`（録画ボタン）** をクリックします。
3. DCによってマイクロ秒単位で同期した、アナログ出力波形（EL4732）とアナログ入力波形（ELM3004）が、サイクル遅れやジッタによるズレを起こすことなく、時間軸上で完全に一致してプロットされることを確認します。
