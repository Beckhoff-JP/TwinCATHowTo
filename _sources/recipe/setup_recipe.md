# レシピの初期設定

まず、次の手順でプロジェクトのレシピ機能を有効にします。

(section_setup_recipe)=
## Recipe Managerの初期化とRecipe defineとRecipeの作成

1. PLCプロジェクトにRecipe Managerを新規作成します

    PLCプロジェクトのコンテキストメニューを開き、`Add` から `Recipe Manager` を選択します。
    ![](assets/2023-08-08-13-04-52.png){align=center}

2. Recipe managerに名前を付けます

    ![](assets/2023-08-08-13-09-09.png){align=center}

3. Recipe manager（Storage タブ）の設定を行います

    ![](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/Images/png/2641809675__en-US__Web.png){align=center}

    ```{csv-table}
    :header: 設定内容, 説明
    :widths: 4,6

    Storage Type, 保存するファイル形式をテキストかバイナリか選びます。バイナリを選択すると値の編集はできません。
    File Path, レシピファイルの保存場所ファイルパスのディレクトリを指定します。指定した場所にレシピファイルは作成され、TwinCATのランタイム起動に毎回読み込まれます。
    File Extension, レシピファイルの拡張子を指定します。
    Separator, テキスト形式の場合、値と属性の区切り文字を指定します。
    "Available columns, Selected columns", レシピファイルに含める値を設定します。
    Save as default, これらの設定をデフォルト値に設定します。
    ```

    ```{note}
    File Pathは、リモートIPC側で保存されるレシピの保存場所ファイルパスです。リモートで接続されている場合はご注意ください。
    ```

4. Recipe manager（General タブ）の設定を行います

    ![](assets/2023-08-09-15-24-45.png){align=center}

    ```{csv-table}
    :header: 設定内容, 説明
    :widths: 4,6

    Recipe management in the PLC, {ref}`section_recipe_in_plc` に示すとおりPLCのファンクションンブロックからレシピ操作を行う場合はチェックする必要があります。
    Automatically save recipe changes to recipe files, レシピマネージャが管理するレシピの値が変更された場合、保存先のファイルの内容も自動的に反映する場合このチェックを入れます。チェックがない場合、レシピの内容を永続化するためにはファンクションブロックにより保存操作を行う必要があります。
    Load recipe, IPC上に保存されているレシピファイルをロードする際のデータチェックの度合を設定します。詳細は後述します。 
    Write recipe, レシピファイルを変数へ反映させる前に、レシピに最小値、最大値のレンジ定義が有ればその範囲から外れていないかチェックし、値が外れていた場合、最大値、最小値へ値を縮小する場合は`Limit the valiable...`を選択し、反映自体を禁止する場合は`Do not write...`を選択します。
    ```

    ```{admonition} Load recipe設定項目について
    :class: note

    Load only exact match of variable list（推奨）
    : レシピマネージャにより登録された変数リストが順序も含めて完全に一致したファイルでなければ読み込みできません。ただし、完全なリスト定義があり、その次の行以後に未登録変数などがある場合は読み込みされます。この場合の未登録変数の値は無視されます。
    レシピ読み込みに失敗した場合、[`RecipeManCommands`ファンクションブロック](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2525821323.html?id=5426534269789408632)の`GetLastError`メソッドにてエラー`ERR_RECIPE_MISMATCH`が取得できます。

    Load matching variables by variablename
    : レシピマネージャに登録された変数が見つかれば順序に関係なく部分的に読み込まれます。レシピマネージャに未登録の変数の定義行は無視されます。（実際に存在する変数であっても読み込まれません）
    また、無効な定義行がファイルに見つかっても、このモードでは一切のエラーが発生しません。
    ```


5. ここまでの操作でPLCプロジェクトツリーに2.で付けた名前でRecipeManagerが作成されています。これを選択してコンテキストメニューを出して、`Add` > `Recipe Definition...` を選択します。

    ![](assets/2023-08-08-15-07-14.png){align=center}

6. Recipe Definitionに名前を付けます。Recipe Definitionとは任意の変数の集合の単位で、管理する変数の集合の目的ごとに個別に作成することができます。ここでは例として設備構成設定であることをを示す`MachineConfiguration`というRecipe Definitionを作成します。ファイル名に使用されますので、特殊文字や空白文字は作成できません。

    ![](assets/2023-08-08-15-09-25.png){align=center}

7. RecipeManager以下に、作成した Recipe Definitionの名前のツリーが出来上がります。これを選択すると、メインウィンドウにレシピ編集画面が現れます。`Variable` 列の最上位の行の右端にカーソルを動かすとボタンが現われます。これを押すと、`Input Assistant` ウィンドウが開き、PLCプロジェクト内の設定対象の変数をツリーから選ぶことができます。

    ![](assets/2023-08-08-15-33-15.png){align=center}

    同様の手順で変数を追加します。

8. 次にRecipeを作成します。レシピ編集画面のどこでも構わないので右クリックしてコンテキストメニューを出現させます。そこから`Add a new recipe`メニューを選択します。New Recipeの設定ウインドウが現われますので名前を入力してOKボタンを押してください。

    ![](assets/2023-08-08-15-48-52.png){align=center}

    ![](assets/2023-08-08-15-50-18.png){align=center}

9. 同様に他のレシピを追加したい場合は下記の通り別名を付けて新しくレシピを作ってください。すでに値が設定されたレシピがある場合、そのレシピからコピー（同じ値が設定された状態）で作成されます。

    ![](assets/2023-08-08-15-52-53.png){align=center}

10. 作成されたレシピは次のとおり編集列が追加されます。

    ![](assets/2023-08-08-15-54-24.png){align=center}