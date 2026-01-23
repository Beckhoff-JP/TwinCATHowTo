# 変数プログラムの基本

照光式押し釦スイッチにボタンを押すと点滅する制御するプログラムを例に、リファクタリングするプロセスをご紹介します。

## 照光式押し釦スイッチの点滅制御プログラム（基本）

プログラム上に記載した点滅プログラムです。button入力、lightが出力で、buttonがTRUEの間、0.5秒間隔でlight出力に対して点滅を繰り返すSTプログラムです。


```{code-block} iecst
PROGRAM MAIN
VAR
    button  AT%I*   : BOOL;
    light   AT%Q*   : BOOL;
    interval_timer  : TON := (PT := T#0.5S);
END_VAR


IF button THEN
    interval_timer(IN := NOT interval_timer.Q);

    IF interval_timer.Q THEN 
        light := NOT light;
    END_IF
ELSE
    light := FALSE;
END_IF
```

* `AT%I*`を入力変数、`AT%Q*`を出力変数としてEtherCATの任意のデジタル入力、出力に割り当てられます。
* `TON` （タイマオン）ファンクションブロックを使って周期タイマを作ります。以下の実装で `interval_timer.Q` は0.5秒おきに1サイクルだけTRUEとなります。
    ```{code} iecst
    interval_timer(IN := NOT interval_timer.Q, PT := T#0.5S);
    ```
    ラダーで表現するなら、次のとおりで、自己切り回路でT001接点は1パルスONします。    
    ```
      T001           K5
    |--|/|---------(T001)
    ```
    
* `button` 入力が`TRUE`になると、`interval_timer`の周期タイマが動作します。それ以外のとき、`light` 出力はFALSEです。
* `interval_timer.Q`が`TRUE`になるたびに、それまでの`light`の状態を反転させています。

## ボタンランプが増えた場合

まぁまぁ、2つまでなら何とか苦もなく書けるかもしれません。二つ目のボタンランプ用に変数が重ならないように別の変数を宣言し、同じロジックですが新たに宣言した変数に割り振り直します。

```{code-block} iecst
PROGRAM MAIN
VAR
    button1  AT%I*   : BOOL;
    light1   AT%Q*   : BOOL;
    button2  AT%I*   : BOOL;
    light2   AT%Q*   : BOOL;
    interval_timer1  : TON := (PT := T#0.5S);
    interval_timer2  : TON := (PT := T#0.5S);
END_VAR

// Button & light 1 
IF button1 THEN
    interval_timer1(IN := NOT interval_timer1.Q);

    IF interval_timer1.Q THEN 
        light1 := NOT light1;
    END_IF
ELSE
    light1 := FALSE;
END_IF

// Button & light 2 
IF button2 THEN
    interval_timer2(IN := NOT interval_timer2.Q);

    IF interval_timer2.Q THEN 
        light2 := NOT light2;
    END_IF
ELSE
    light2 := FALSE;
END_IF
```

変数を使わないメモリアドレスベースのプログラミングを必要とする時代のPLCではこの手法が当たり前でした。まず、メモリマップと呼ばれる、デバイスの使用目的とそのメモリアドレスの一覧表を作ります。このメモリマップにて2つ目の押しボタンランプのためのアドレス領域を予約して、この領域のメモリを使って同じ様なロジックのプログラムを書き直します。

実際の現場ではもっと大規模なプログラム（モジュール化）されたプログラム構成です。基本となる一つのモジュールプログラムをコピーして、複数モジュールのプログラムを複製して作成します。しかしコピーしただけではアドレスは被ったままなのでメモリマップで予約したメモリアドレスに個々にアドレス変換して作成します。このような作業を手作業で行っている開発現場は未だ多いのではないでしょうか。

```{tip}
本来複数の同じロジックで制御する機能モジュールは、変数プログラミングが備えるビルドツールや、ロジックの隠蔽化（カプセル化）というIPCの機能を用いれば完全自動化できるもので、決して手作業で行うものではありません。

しかし、これらの機能（変数プログラミングやカプセル化機能）が忌み嫌われている理由は、現場で「すべて見える」ソフトウェアが求められているからだと考えます。専門家ではない人にとって構造化されたプログラムは全体を把握するのに不都合です。本来、ソフトウェアのオブジェクト構造に関する専門的なリテラシーが有れば構造化されたプログラムの方が把握しやすいはずなのですが、そうではない場合、巨大な巻き物プログラムの方が直感的で、現場での停止原因をすぐにつきとめ、プログラム修正がしやすい、といった情緒的安心感を生んでいるのでしょう。

しかし裏を返せば、この環境がいつまでも現場で問題が起こり続けるソフトウェア品質を許容し続けている要因にもなっています。すべて手作業を強いられるアドレスプログラミングでは、その非効率さ故に十分な品質作りこみができないまま量産現場に設備が投入されてしまいがちです。結局は現場の保守担当が品質を作りこまざるを得ないのです。

筆者の経験上、正しくカプセル化された設備はフレームワークとしての基盤がしっかりしているため、停止からの復帰までのユースケースシナリオが十分にケアされたものとなっています。停止しても短時間に復旧できるため、保守メンによるラダーモニタを見た原因分析と装置復旧という介在を必要としません。多くの場合に停止したら仕掛中ワークをすべて取り除いて最初からやり直す、などというルーズな仕様のままほったらかしにされていないのです。よって、現場での保守による復旧やプログラム修正を必要としません。

現場での場当たり的なソフト修正を阻止できれば、設備間のプログラムの共通化も容易になります。動作仕様も共通化しやすいのでどの設備でも同じ動作振る舞いが保証されます。このことはその設備を扱う製造現場のエンジニアの人材育成コストの低減、操作ミスの低減にもつながります。ソフトウェアそのものも共通基盤化（フレームワーク化）によってソフトウェア資産の流用度が向上ます。

とくに日本のものづくり現場では「からくり」などに代表されるように、機能とメカを密結合させた複雑な一体システムを好みがちです。このため同じ機能をあちらこちらで個別最適に作りこむ傾向が強いです。反面、シンプルなハードウェア、ソフトウェアフレームワーク上で素早く特殊機能を開発生産する、という指向がなかなか生まれません。こういった文化的背景も相まって、ソフトウェア開発者自身がこうした非効率な開発環境を甘んじて受け入れてしまっているようにも感じます。

せめて本ドキュメントによってIPCが持つこれらの機能を体験してもらうことで、「仕組み化」のすばらしさを知っていただくこと、そしていつかは皆さまの現場の変革につながることを切に願います。
```

## 配列を使ってみる

ラダーで言うところのインデックスレジスタのようなものでしょうか。決まった型のデータを連続的に配置して、これを順にアクセスできるようにしたものです。

各プログラムブロックの先頭で`module_number`を設定し、これを配列の要素番号として指定したプログラムブロックにしています。各プログラムブロックは、デバイス変換せずにコピーでできる範囲になりました。

```{code-block} iecst
PROGRAM MAIN
VAR CONSTANT
    NUM_OF_BUTTONS : UDINT := 2;
END_VAR
VAR
    buttons  AT%I*   : ARRAY [1..NUM_OF_BUTTONS] OF BOOL;
    lights   AT%Q*   : ARRAY [1..NUM_OF_BUTTONS] OF BOOL;
    interval_timers  : ARRAY [1..NUM_OF_BUTTONS] OF TON := [(PT := T#0.5S), (PT := T#0.5S)];
    module_number : UDINT;
END_VAR

// Button & light 1 
module_number := 1;
IF button[module_number] THEN
    interval_timer[module_number](IN := NOT interval_timer[module_number].Q);

    IF interval_timer[module_number].Q THEN 
        light[module_number] := NOT light[module_number];
    END_IF
ELSE
    light[module_number] := FALSE;
END_IF

// Button & light 2 
module_number := 2;
IF button[module_number] THEN
    interval_timer[module_number](IN := NOT interval_timer[module_number].Q);

    IF interval_timer[module_number].Q THEN 
        light[module_number] := NOT light[module_number];
    END_IF
ELSE
    light[module_number] := FALSE;
END_IF
```

まだ問題は残ります。こんなシンプルなロジックではバグは起こらないかもしれません。しかし、ロジックにバグが見つかると、コピーした全てのロジックの修正を強制されます。

## 繰り返し構文を使う

せっかく配列化したのですから、同じロジック部を繰り返し構文の中で多重化できるように書き直しましょう。

`FOR ～ DO ～ END_FOR` 構文を使い、`module_number` 変数を順番に繰り上げるので、ロジックは共通化できます。仮にバグ修正を行うとしても、一度修正すれば全ての並行モジュールに反映が及びます。

また、ボタンランプを増やす場合も、`NUM_OF_BUTTONS` 定数の値を増やすだけで済みます。

```{code-block} iecst
PROGRAM MAIN
VAR CONSTANT
    NUM_OF_BUTTONS : UDINT := 2;
END_VAR
VAR
    buttons  AT%I*   : ARRAY [1..NUM_OF_BUTTONS] OF BOOL;
    lights   AT%Q*   : ARRAY [1..NUM_OF_BUTTONS] OF BOOL;
    interval_timers  : ARRAY [1..NUM_OF_BUTTONS] OF TON := [(PT := T#0.5S), (PT := T#0.5S)];
    module_number : UDINT;
END_VAR

// Button & light
FOR module_number := 1 TO NUM_OF_BUTTONS DO
    IF button[module_number] THEN
        interval_timer[module_number](IN := NOT interval_timer[module_number].Q);

        IF interval_timer[module_number].Q THEN 
            light[module_number] := NOT light[module_number];
        END_IF
    ELSE
        light[module_number] := FALSE;
    END_IF
END_FOR
```

ただ、問題が残ります。

* ロジック上で変数状態を観察するモニタができなくなる。
* 全てが　`FOR～END_FOR` の中にロジックを記述するため可読性が悪くなる。

そこで登場するのがファンクションブロックです。

