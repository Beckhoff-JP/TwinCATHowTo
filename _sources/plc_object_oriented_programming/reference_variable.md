# 参照型変数

## ファンクションブロックにおける値の受け渡し方

ファンクションブロックにはつぎの3つの外部との受け渡し変数宣言部があります。

```{code-block} iecst
VAR_INPUT
    <入力変数>
END_VAR
VAR_OUTPUT
    <入力変数>
END_VAR
VAR_IN_OUT
    <入出力変数>
END_VAR

```

## リファレンス

ポインタ変数ではデリファレンスしなければ実体変数にアクセスできません。プログラムコード内で暗黙的にそのまま変数名としてデリファレンスしてアクセスできるものを参照変数と呼びます。参照型変数は、変数定義時に `REFERENCE TO ****` として宣言して使用します。この場合もヌルポインタへのアクセスを禁止するために、参照型変数が正しいポインタとなっているか調べるための `__ISVALIDREF()` 関数を用います。

```{code} iecst
VAR
    stParameter : ST_Parameter := (Velocity := 50, Acceleration := 500, Decceleration := 300);
    refParameter  : REFERENCE TO ST_Parameter; // 参照型変数の定義
    lrVelocity  : LREAL; // 取り出したパラメータ値
END_VAR

refParameter REF= stParameter;

IF __ISVALIDREF(refParameter) THEN
    lrVelocity := refParameter.Velocity;
END_IF
```

上記のとおりリファレンスへの値の代入は少し特殊です。通常、値の代入には `:=` を用いますが、参照型変数には、 `REF=` を用います。 **ただしファンクションブロックやファンクション、メソッド等の引数に渡す場合は、 `:=` を使う** 点が極めて特殊ですので注意が必要です。

```{code} iecst
FUNCTION_BLOCK FB_ModuleController
VAR_INPUT
    refParameter  : REFERENCE TO ST_Parameter; // ファンクションブロックの入力変数に参照型変数を定義
END_VAR

VAR
    lrVelocity    : LREAL;
END_VAR

IF __ISVALIDREF(refParameter) THEN
    lrVelocity := refParameter.Velocity;
END_IF
```
上記のファンクションブロックの入力変数は参照型変数ですが、ファンクションブロックの引数として値をセットする場合は `REF=` ではなく `:=` を用います。

```{code} iecst
VAR
    stParameter     : ST_Parameter := (Velocity := 50, Acceleration := 500, Decceleration := 300);
    fbController    : FB_ModuleController;
END_VAR

fbController(refParameter := stParameter);

```

## VAR_IN_OUT

前節で説明したとおり、ファンクションブロックのみの機能です。`VAR_IN_OUT`で受け渡す変数は実体ではなく参照を渡します。ファンクションブロック内では外部の変数そのものを操作します。ファンクションブロック入出力を共に操作したい場合はこの受け渡しかたが必要です。

```{code} iecst
FUNCTION_BLOCK FB_ModuleController
VAR_IN_OUT
    refParameter  : ST_Parameter; // ファンクションブロックの入出変数を定義。暗黙的に参照型となる。
END_VAR

VAR
    lrVelocity    : LREAL;
END_VAR

lrVelocity := refParameter.Velocity;
```

入力変数同様に `:=` を用いて受け渡します。

```{code} iecst
VAR
    stParameter     : ST_Parameter := (Velocity := 50, Acceleration := 500, Decceleration := 300);
    fbController    : FB_ModuleController;
END_VAR

fbController(refParameter := stParameter);
```

VAR_IN_OUT で定義した変数を省略した場合はビルドエラーとなり省略できません。従って、ファンクションブロック内で参照型変数の未定義チェックを行う必要はありません。

