# 変更とコミット

リポジトリとして登録された状態になると、「コミット」という単位で変更履歴が管理されます。コミットはTwinCATで変更を加えるたびに行うのではなく、意味のある変更単位でまとめると、後々のトレーサビリティ上便利です。サンプルプログラムとして、0.5秒間隔でON/OFFを繰り返すBlinkerファンクションブロックを、ST、FBD、LD、CFCで作成したものをベースとします。

```iecst
FUNCTION_BLOCK ST_blinker
VAR_INPUT
	execute:BOOL;
END_VAR
VAR_OUTPUT
	output:BOOL;
END_VAR
VAR
	delay: TON;
END_VAR

delay(IN := NOT delay.Q, PT := T#0.5S);
output := (NOT output AND delay.Q) OR (output AND NOT delay.Q) AND execute;
```

上記ファンクションブロックを次の通りMAINプログラムで使います。

```
PROGRAM MAIN
VAR
	button1:BOOL;
	button2:BOOL;
	button3:BOOL;
	button4:BOOL;
	light1:BOOL;
	light2:BOOL;
	light3:BOOL;
	light4:BOOL;
	blinker1 :FBD_blinker;
	blinker2 :LD_blinker;
	blinker3 :ST_blinker;
	blinker4 :CFC_blinker;
END_VAR

blinker1(execute := button1,output => light1);
blinker2(execute := button2,output => light2);
blinker3(execute := button3,output => light3);
blinker4(execute := button4,output => light4);
```

この節の例では、このサンプルプログラムに対して次の順に変更とコミットを行う手順について説明します。

1. 点滅間隔を任意の時間で設定可能にする変更を加える
2. さらにON/OFFのデューティを設定できるようにする

これらの変更を加えて、個別にコミットする方法について説明します。

## TwinCATプロジェクトの変更

***_blinker 全てのファンクションブロックに、「点滅間隔を任意の時間で設定可能にする」の変更を加えてみます。すると、次図の通り前回のコミット（現時点では初期登録時点）から変更を加えたリソースのアイコンの左側に赤色チェックマークがオーバレイされ、変更が加えられたことが分かる様になっています。

![](assets/2024-02-14-22-18-11.png){align=center}

変更マークがついたリソースに対しては、コンテキストメニューによりGitの各操作が可能となっています。

![](assets/2024-02-15-09-16-44.png){align=center}

```{csv-table}
:header: メニュー, 説明
:widths: 3, 7

Undo..., 前回のコミット状態まで戻す。
Commit..., 加えた変更をリポジトリへ反映する。
View History..., コミット履歴を一覧する。
Compare and Unmodified..., ファイル内の比較を表示し、部分的にロールバック編集する。
Blame(annotate), ファイルの行単位で最新の変更が加えられたコミットを一覧する。ただし、TcPOUなど生のファイルの状態で表示される。
```

例えば、変更を加えたFBD_blinkerの変更箇所を見る場合は、コンテキストメニューから`compare with Unmodified...`を選択します。

![](assets/2024-02-14-22-21-53.png){align=center}

すると、{ref}`section_register_compare_viewer` で設定した`TcProjectCompare`が起動し、前回コミットした時点からの変更点がハイライトされるウィンドウが起動します。左側が変更前、右側が変更後のペインとなります。

![](assets/2024-02-14-22-24-10.png){align=center}

他にもST言語の差分は次の通り表示されます。

![](assets/2024-02-15-09-13-57.png){align=center}

差分ツールを使った、部分的な変更箇所のロールバックなどの修正方法については、{ref}`section_tcprojectcompare_usage` にて説明します。

## 変更をコミットする

リポジトリへ変更を反映することをコミットといいます。コミットを行うには、TwinCATトップレベルのコンテキストメニューから`Commit...`を選んでください。

![](assets/2024-02-15-10-15-40.png){align=center}

コミットウィンドウが現れます。コミットには二つの方法があります。

全ての変更をコミットする場合
	: {numref}`figure_all_commit` の通り、Changesのファイルを全て確認の上、コミットコメントを記述し、そのまま`Commit All`ボタンを押すと、全ての変更がコミットされます。

ステージに上げられたファイルのみコミットする場合
	: {numref}`figure_staged_commit` の通り、コミットしたいファイルを選択し、`Staged Changes`に上げられたものだけをコミットできます。同様にコミットコメント記述後、`Commit Staged`ボタンを押す事でステージに上げられたファイルのみコミットされます。

ステージへ上げる方法は、ファイルをひとつづつ選択する方法と、全変更をステージに一度上げる方法があります。

```{figure} assets/2024-02-15-11-49-16.png
:align: center
:name: figure_all_commit

全てのファイルをコミットする手順
```

```{figure} assets/2024-02-15-13-12-39.png
:align: center
:name: figure_staged_commit

一部のファイルのみコミットする手順
```

```{figure} assets/2024-02-15-14-10-48.png
:align: center
:name: figure_staged_all

全ファイルをステージに上げる
```
次の手順でコミットを行うと良いでしょう。

1. 変更対象ファイルを確認する。

	**Changes** ツリーには、変更されたファイルのみが一覧されます。全てを差分エディタで変更点をチェックし、今回の目的に有ったファイルのみ選択する必要が有る場合、ステージコミットを、全てのファイルが同一の目的の変更であることが分かったら、全コミットを行ってください。

	```{admonition} コミットの単位にご注意
	コミットの単位で変更が管理されます。このため、不具合修正、単なるリファクタリング、機能追加など、意味のある単位でコミットを行うことで、後から目的の変更がいつ、誰が、どのブランチで行われたのか、追跡する事が容易になります。
	```

2. コミットコメントを記述する。

	次のとおり、プレフィックスに続いて何等かのコメントを記述すると良いでしょう。後から検索しやすくするためです。

	```{code} text
	feat: Make blinker FB blinking interval configurable.
	```

	プレフィックスは独自に定義いただくのが良いのですが、迷う場合は以下のような一覧をご参考ください。

	```{csv-table}
	:header: プレフィックス, 説明

	feat, 新しい機能
	fix, バグの修正
	docs, ドキュメントのみの変更
	style, 空白、フォーマット、セミコロン追加など
	refactor, 仕様に影響がないコード改善(リファクタ)
	perf, パフォーマンス向上関連
	test, テスト関連
	chore, ビルド、補助ツール、ライブラリ関連
	```

3. 最後に、`Commit All` または `Commit Staged` ボタンを押すと、コミットが行われます。

```{admonition} TwinCAT 3.1 Build 4024では行単位のステージはできません
:class: warning

Gitコマンドでは行単位でのステージングが可能な`git add -p`コマンドがあります。しかし、行単位のステージコミットは、Visual Studio 2022のバージョン17.3以降でなければ対応しません。
TwinCAT3.1 Build 4024はVisual Studio 2019をベースにしているため、この機能はありません。よって、VSCodeなどの他のGitクライアントをお使いください。ただし、この場合TcPOUのXML形式のファイルを直接編集する事になります。他のGitクライアントでも部分コミットを可能にするためには、プログラムをST言語に限定してお使いいただく事をお勧めします。

例えば、Gitリポジトリで管理されたTwinCATプロジェクトフォルダをVSCodeでプロジェクトを開くと、変更のあるTcPOUファイルがSource controlツリーに一覧されます。一旦全てをStagedに上げてから、任意の行を選択して`Unsatage Selected Ranges`を選択します。

![](assets/2024-02-15-16-44-29.png){align=center}

すると、Staged Changesには選択した余分な範囲の変更は加えられず、目的の変更だけがコミットできます。また、Unsatagedにした変更は、未コミットの変更としてChangesツリーの中に残留し続けますので、後々別のコミットで反映することが可能になります。

![](assets/2024-02-15-16-48-01.png){align=center}

TwinCAT3.1 Build 4026 は、Visial Studio 2022ベースとなりますので、この機能がネイティブ対応するのはもうしばらくお待ちください。
```

## 変更履歴を見る

過去のコミットの履歴を見るには、TwinCATプロジェクトのコンテキストメニューから`View History...`を選びます。

![](assets/2024-02-15-18-12-05.png){align=center}

誰がいつ、どんな変更を行ったのかが一覧されます。

![](assets/2024-02-15-18-13-31.png){align=center}

任意のコミットの変更詳細を見たい場合は、コンテキストメニューから`View Commit Details`を選びます。

![](assets/2024-02-15-18-17-13.png){align=center}

コミットで変更を加えたファイルが一覧されます。任意のファイルをダブルクリックすると、TcProjectCompareにてその変更箇所が表示されます。

この例では、下記の変更が行われた変更箇所が左右で分かる様に表示されます。

2. ON/OFFのデューティを設定できるようにする

![](assets/2024-02-15-18-36-00.png)

また、複数のコミットをまたいだ変更詳細を見たい場合は、CTRLキーを押しながら2行を選択し、コンテキストメニューを出現させて`Compare Commits...`を選びます。

![](assets/2024-02-15-18-19-54.png){align=center}

このコミット間で変更を加えたファイルが一覧されます。任意のファイルをダブルクリックすると、TcProjectCompareにてその変更箇所が表示されます。

この例では、初回のコミットから下記2つの変更全てが行われた変更箇所が左右で分かる様に表示されます。

1. 点滅間隔を任意の時間で設定可能にする変更を加える
2. さらにON/OFFのデューティを設定できるようにする

![](assets/2024-02-15-18-22-08.png){align=center}