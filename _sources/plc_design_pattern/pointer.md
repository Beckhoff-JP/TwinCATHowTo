# ポインタ

`ADR`関数を用いる事で、該当する変数のポインタを返します。ポインタの実体は単なるメモリアドレスですので直接変数にアクセスすることはできません。`POINTER TO ****` で定義した「ポインタ型変数」にセットすることで使えるようになります。ポインタ型変数を通して参照先の実体変数へアクセスすることをデリファレンスと呼びます。TwinCATでは、ポインタ変数の最期にカレット `^` を付加することでデリファレンスできます。また、ポインタ変数には、ポインタがセットされていない状態（ヌルポインタ）があり、この状態でデリファレンスを行うとプログラムエラーでPLCが停止します。ポインタ変数が `0` でないことを条件にデリファレンスするプログラムコードとする必要があります。　

```{code} iecst
VAR
    stParameter : ST_Parameter := (Velocity := 50, Acceleration := 500, Decceleration := 300);
    pParameter  : POINTER TO ST_Parameter; // ポインタ型変数の定義
    lrVelocity  : LREAL; // 取り出したパラメータ値
END_VAR

pParameter := ADR(stParameter);

IF pParameter <> 0 THEN
    lrVelocity := pParameter^.Velocity;
END_IF
```

ポインタが危険である所以はこの先にあります。ポインタの実体はリファレンスとことなり、メモリアドレスを直に扱う低レベルな仕様です。次のプログラムはポインタ変数を別の形で取り扱う例です。

モーションの動作パラメータを定義する`ST_Prameter`構造体があります。この型が100の配列で連続的にメモリ上に配置された `stParameters` を宣言します。この配列の先頭アドレスから順にパラメータをサーチし、構造体の中にある速度値(`Velocity`)を取り出して前回の値との差分を計算し、`diff_Velocities` 配列に格納する、というプログラムです。

```{code-block} iecst
:caption: モーションパラメータが定義された100個の配列のうち速度指示データの差分を計算するプログラム

VAR
    stParameters : ARRAY [0..99] OF ST_Parameter;
    diff_Velocities : ARRAY [0..99] OF LREAL; // 前回値との速度差分
    lrVelocity  : LREAL; // 速度値
    prev_lvVelocity : LREAL;  // 前回の速度値
    addr_parameter : PVOID; // stParameterの先頭メモリアドレス
    offset_lrVelocity      : UDINT; // stParameterのうち、Velocityデータがあるメモリアドレスのオフセット
    len_parameter : UDINT; // stParameterのメモリサイズ
    i : UINT;
END_VAR

// Velocityパラメータのメモリ配置上の先頭からのオフセットを格納
offset_lrVelocity := ADR(stParameters[0].Velocity) - ADR(stParameters);

addr_parameter := ADR(stParameters[0]); // 配列の先頭アドレスで初期化
len_parameter := SIZEOF(stParameters[0]); // stParameter構造体のサイズ
diff_Velocities[0] := 0.0;

FOR i := 0 TO 99 DO
    // stParameter配列の各先頭ポインタアドレス計算
    addr_parameter := addr_parameter + (len_parameter * i);

    // 現在アドレスの速度値をlrVelocityへコピー
    MEMCPY(
        ADR(lrVelocicy), 
        addr_parameter + offset_lrVelocity, 
        SIZEOF(lrVelocicy)
    );
    IF i > 0 THEN
        // 前回アドレスの速度値をlrVelocityへコピー
        MEMCPY(
            ADR(prev_lvVelocity), 
            addr_parameter - len_parameter + offset_lrVelocity, 
            SIZEOF(lrVelocicy)
        );
        // 前回値との速度差分を計算
        diff_Velocities[i] := lrVelocity - prev_lvVelocity;
    END_IF
END_FOR
```

上記のとおり、メモリアドレスを調べる`ADR()`ファンクション、1個辺りの構造体変数の占有サイズを調べる`SIZEOF()`ファンクション、この二つから任意の型のデータとしてメモリコピーする`MEMCPY()`を組み合わせることで、メモリ操作という低レベル関数を使ってデータ処理を行うことが可能になります。

しかし、ポインタを用いたメモリアドレスの操作は型を意識せずデータを取り扱うことから不正なメモリアクセスを誘発してしまう恐れがあり、危険ですのであまり推奨されていません。

なお、事例紹介のためMEMCPY()を用いましたが、データコピーが行われるため速度面で不利です。同じ目的であれば次の方が高速に処理可能です。

```{code-block} iecst
:caption: ポインタ型を使って演算する例

VAR
    stParameters : ARRAY [0..99] OF ST_Parameter;
    diff_Velocities : ARRAY [0..99] OF LREAL; // 前回値との速度差分
    lrVelocity  : POINTER TO LREAL; // 速度値
    prev_lvVelocity : POINTER TO LREAL;  // 前回の速度値
    addr_parameter : PVOID; // stParameterの先頭メモリアドレス
    offset_lrVelocity      : UDINT; // stParameterのうち、Velocityデータがあるメモリアドレスのオフセット
    len_parameter : UDINT; // stParameterのメモリサイズ
    i : UINT;
END_VAR

// Velocityパラメータのメモリ配置上の先頭からのオフセットを格納
offset_lrVelocity := ADR(stParameters[0].Velocity) - ADR(stParameters);

addr_parameter := ADR(stParameters[0]); // 配列の先頭アドレスで初期化
len_parameter := SIZEOF(stParameters[0]); // stParameter構造体のサイズ
diff_Velocities[0] := 0.0;

FOR i := 0 TO 99 DO
    // stParameter配列の各先頭ポインタアドレス計算
    addr_parameter := addr_parameter + (len_parameter * i);

    // 現在アドレスの速度値をlrVelocityへコピー
    lrVelocicy := addr_parameter + offset_lrVelocity;

    IF i > 0 THEN
        // 前回アドレスの速度値をlrVelocityへコピー
        prev_lvVelocity := addr_parameter - len_parameter + offset_lrVelocity;
        // 前回値との速度差分を計算
        diff_Velocities[i] := lrVelocity^ - prev_lvVelocity^;
    END_IF
END_FOR
```

速度を格納する変数名をポインタ型変数 `POINTER TO LREAL` として宣言している点が異なります。先ほどはLREAL型の変数そのものを宣言していましたので、これらのメモリコピーしていました。しかし、今回のプログラムは、`stParameters` 配列中の速度変数が格納されているポインタアドレスを計算し、ポインタ型変数にそのアドレスを格納した上で、デリファレンス `^` して速度値にアクセスし、差分を計算しています。

## インターフェースとインターフェースポインタ

IEC-61131-3の第3版特有の機能としてオブジェクト指向があります。この機能の一つとして、ファンクションブロックのメソッド、およびプロパティの雛形を定義する機能がインターフェースです。定義したインターフェースは「型」として変数定義することができます。インターフェース型の変数は、これを実装した様々な具象ファンクションブロックを読み込むことができます。この際、読み込まれた側のファンクションブロックでは、「インターフェースポインタ」と呼ばれるメソッドやプロパティのポインタを通して間接的にアクセスすることができます。

