# ファンクションブロック化

プログラムで一定のロジックパターンが見え、これが並行度の高いモジュール化が可能となる場合、ファンクションブロック化とすると良いでしょう。

ここでは前節で紹介したボタンランプの点滅ロジックをファンクションブロック化するプログラムを用いて様々なリファクタリング例をご紹介します。

```{admonition} 要求仕様

ファンクションブロックの仕様は`bStart`をTRUEにすると`bInterval` で設定した時間間隔で`bBlink`のTRUE/FALSEを切り替えるものとします。

入力変数
    : bStart : BOOL
        : 点滅開始入力

      tInterval : TIME
        : 点滅間隔指定

出力変数
    : bBlink : BOOL
        : 点滅出力
```

上記のファンクションブロックをまず定義し、次にこのファンクションブロックを用いたボタンランプ制御プログラムを実装します。

```{tip}

ファンクションブロックとは、プログラムと異なり実行する主体ではありません。あくまでも型（モデル）の定義です。

型（モデル）とは、言い換えると雛形やテンプレートのようなものです。それ自体を実行することはできず、この雛形を基に「実体化」するという過程を経て実行可能なプログラムにすることが可能になります。よって、開発手順としては次の2段階が必要です。

STEP1 : モデル定義
  : ファンクションブロック自体の定義

STEP2 : プログラム実装
  : ファンクションブロックを **インスタンス変数化（実体化）** してインスタンス変数を用いて実行するプログラムを定義する
```

## モデル定義

新たにPOUを追加します。この際、Typeから `Functtion block` を選びます。使用言語は何でも構いません。

```{list-table}
- * ![](assets/2025-09-30-08-49-00.png){align=center}
  * ![](assets/2025-09-30-08-48-02.png){align=center}
```

仕様に基づき、入力変数、出力変数を定義します。また、前節で作成したプログラムから、入力変数、出力変数に置き換えたロジックを定義します。

```{code-block} iecst
FUNCTION_BLOCK FB_Blinker
VAR_INPUT
  bStart    : BOOL; // 点滅開始入力
  tInterval : TIME; // 点滅間隔指定
END_VAR
VAR_OUTPUT
  bBlink    : BOOL; // 点滅出力
END_VAR
VAR
  interval_timer  : TON;
END_VAR

IF bStart THEN
  interval_timer(IN := NOT interval_timer.Q, PT:=tInterval);

  IF interval_timer.Q THEN 
    bBlink := NOT bBlink;
  END_IF
ELSE
  bBlink := FALSE;
END_IF
```

## プログラム実装

モデル定義で作成した `FB_Blinker` 型の機能モデルを、MAINプログラムで実際にプログラムとして動作するよう **インスタンス化** します

```{code} iecst
VAR
  fbBlinker1        : FB_Blinker;
END_VAR
```

変数宣言部では、このようにモデル定義したファンクションブロック `FB_Blinker` を「型」として取り扱い、その実態（インスタンス）を `fbblinker1` 変数として個別化します。二つのボタンランプとして宣言してそのロジックを実行するプログラムは次の通り記述します。

```{code-block} iecst
PROGRAM MAIN
VAR
  button1  AT%I*    : BOOL;
  light1   AT%Q*    : BOOL;
  fbBlinker1        : FB_Blinker; // ボタンランプ1のためのインスタンス
  
  button2  AT%I*    : BOOL;
  light2   AT%Q*    : BOOL;
  fbBlinker2        : FB_Blinker; // ボタンランプ2のためのインスタンス
END_VAR

// Button & light 1 
fbBlinker1(
  bStart := button1,
  tInterval:= T#0.5S,
  bBlink => light1
);

// Button & light 2 
fbBlinker2(
  bStart := button2,
  tInterval:= T#0.5S,
  bBlink => light2
);
```

ファンクションブロックそのものも配列変数化してみましょう。


```{code-block} iecst
PROGRAM MAIN
VAR CONSTANT
  NUM_OF_BUTTONS : UDINT := 2;
END_VAR

VAR
  buttons  AT%I*    : ARRAY [1..NUM_OF_BUTTONS] OF BOOL;
  lights   AT%Q*    : ARRAY [1..NUM_OF_BUTTONS] OF BOOL;
  fbBlinkers        : ARRAY [1..NUM_OF_BUTTONS] OF FB_Blinker;
    module_number   : UDINT;
END_VAR

FOR module_number := 1 TO NUM_OF_BUTTONS DO
  fbBlinkers[module_number](
    bStart := buttons[module_number], 
    tInterval:= T#0.5S, 
    bBlink => lights[module_number]
  );
END_FOR
```

このプログラムを動作させてみましょう。`AT%I*` 定義した `buttons[1]`, `buttons[2]` 変数にリンクしたIOがあればこのIOアドレスの入力状態を操作すれば良いのですが、IOが存在しない場合は次のとおり`Preparation`列に状態をセットし、`Write value` にて変数の状態を操作してください。

![](assets/2025-09-30-10-58-04.png){align=center}

```{figure} ./assets/twincat_ope.webm
:class: controls
:width: 100%

モニタ、変数への値書き込み、ウォッチ登録、ファンクションブロックモニタ
```

操作した変数に応じて `lights[1]`、`lights[2]` の何れかの点滅が開始するでしょう。

先ほどまでの問題として、配列化してしまうと個々のロジックの動きのモニタができなくなってしまった事でした。しかしファンクションブロックにすることによって、インスタンス変数個々のモニタが可能となります。

また、ファンクションブロック化とは、複数のボタンランプの振る舞いの共通部分に着目し、「点滅制御を行う」という抽象化された機能としてモデルとして再定義するものでした。このおかげで、「機能」という抽象層と、その機能と個々のボタンランプとして実現させる、という具象層で関心領域を分けることができました。

つまり、機能としてのファンクションブロックのロジックの中身の品質テスト（デバッグ）は、たった1回でよく、具象層としてのテストは、ハードワイヤも含めてFBの入力変数、出力変数に正しくリンクされているか？という点だけをチェックすれば良いことになります。

## さらなる課題

ファンクションブロックを活用するだけでも、多くの問題は解決できそうです。しかし、まだまだ次の問題が起こります。

複雑な外部データの受け渡し
  : ボタンランプのように入力1点、出力1点というシンプルな入出力は珍しいです。実際のモジュールは、複雑な入出力アドレスを持ち、しかもそのバリエーションもかなり多いです。このような外部の複雑な構造の入出力データとやり取りするには、都度入力変数、出力変数と紐づけるのはかなり大変です。ベタで書いている分には「入力変数」や「出力変数」といった別の変数にいちど置き換え直す必要が無い分、ファンクションブロック化することで手間が増えています。

オプション機能を詰め込み過ぎて肥大化
  : 入出力だけではなく、中のロジックもいろいろなオプション機能や仕様の違いによるバリエーションに対応しなくてはならなくなります。この場合、ファンクションブロックに全てを詰め込んで、内部でオプション仕様に応じて機能の有効、無効を切り替える、という手法がとられがちです。せっかくテスト工数が削減できたのに、ファンクションブロック内部の条件が複雑化することでテストがより難しくなることが容易に想像できそうです。

こうした悩みへの解決方法として、参照型変数の導入と、オブジェクト指向プログラミングの導入の2点が挙げられます。次節よりこの手法に迫ります。