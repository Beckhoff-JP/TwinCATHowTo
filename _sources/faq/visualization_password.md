# Visualizationにて、パスワード入力した値を * で隠蔽する方法を教えてください

Visualizationからパスワードなど秘匿性のある文字列を画面上に表示しないようにするにはどうすれば良いですか？

## 回答

次の方法で対応します。

* PLCプログラムにて、編集した文字数に合わせた表示用の隠蔽文字列（`*`）を生成する。
* VisualizationでText fieldを配置する
* Text fieldの表示用の変数と、編集結果の変数を個別に保存する。

まず、次のPLCプログラムを定義します。`MAIN.test_str[1]`の文字数に応じた`*`文字列が生成され、`MAIN.test_str[0]`に格納されます。

```{code-block} iecst
PROGRAM MAIN
VAR
    test_str : ARRAY [0..1] OF STRING; // 表示用と編集用文字列
    i        : INT;
END_VAR

test_str[0] := '';
FOR i := 1 TO LEN(test_str[1]) DO
    test_str[0] := CONCAT(test_str[0], '*');
END_FOR
```

次にVisualizationでText fieldを追加し、Propertiesで次の通り設定します。

1. Text variableは、`MAIN.test_str[0]`を設定し、Textに `%s` を入力
2. Inputconfigurationの OnMouseDown イベントを有効にする
3. OnMouseDownイベントで、`Write a variable` を有効にして、以下を設定する。

    Use another variable
        : `MAIN.test_str[1]`を設定し、Initial display format に `%s` を設定
    
    Password field
        : チェックする

![](assets/2024-12-10-16-10-50.png){align=center}

追加したText fieldにカーソルを合わせてクリックすると、文字列入力キーボードが現れます。試しに`test`と入力すると、入力した文字は4文字分`****`で表示され、OKボタンを押すと、次の通り変数に格納されます。

![](assets/2024-12-10-16-10-23.png){align=center}

また、追加したText fieldの表示は`MAIN.test_str[0]`を表示しますので、入力した文字数分`****`と表示されます。

````{tip}
かならずしも入力した文字数と同一にする必要はありません。むしろ文字数が異なる方が予想されにくくセキュアでしょう。下記のように一文字ごとに2文字のアスタリスクが生成される方法でも構いません。

```{code}
test_str[0] := '';
FOR i := 1 TO LEN(test_str[1]) DO
    test_str[0] := CONCAT(test_str[0], '**');
END_FOR
```
````