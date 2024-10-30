(section_recipe_in_plc)=
# PLCプログラムによるレシピ制御

`RecipeManCommands` ファンクションブロックを使うことで、PLCプログラムによってレシピファイルの読み込み、値の展開、新しいレシピの作成、ファイル書き出しを行うことができます。

各メソッドの使い方詳細は、以下のサイトをご参照ください。

[https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2525821323.html?id=5426534269789408632](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2525821323.html?id=5426534269789408632)

ここに記載されているレシピのファイルがLoad、Saveされる対象のファイルは、XAR（ターゲットIPC上）のレシピファイルを指します。XAEのプロジェクトのレシピマネージャ上のデータではありませんのでご注意ください。

たとえば、ターゲットIPC内の設定されたパスのレシピファイルを直接編集し、そのあとload_commandを実行すると、編集後のレシピファイルの値を実際の変数に展開させることができます。

```{warning}
* レシピファイル全てが変数の値として展開されます。外部からの変更値変更は予期しない動作不良につながる可能性がありますので全ての変数値が与える影響についてよく理解した上でこの操作を実施してください。

* ターゲットIPCのレシピファイルを直接編集すると、その内容は次回XAEからActive configurationされた場合に上書きされてしまい、IPC上で編集した内容が失われる可能性があります。XAE上のRecipe Managerの編集値とIPC上で編集した内容との整合はお客様ご自身で管理いただきますよう、ご注意ください。
```

```{code-block} iecst
:caption: RecipeManCommandsファンクションブロックのメソッドの使い方
:name: recipe_manager_library_code_sample
:linenos:

PROGRAM RecipeManager
VAR
    recipe_manager    :RecipeManCommands; // Function block instance
    load_command    :BOOL;
    create_command    :BOOL;
    save_command    :BOOL;
END_VAR

// load_command が Trueになると、Model2レシピのファイルに定義されたデータを変数へ展開する。
IF load_command THEN
    recipe_manager.LoadAndWriteRecipe(
        'MachineConfiguration',
        'Model2'
    );
        
    load_command := FALSE;
END_IF

// create_command が Trueになると、Incident1という名前のレシピのファイルが生成され、現在値が保存されます。
IF create_command THEN
    recipe_manager.CreateRecipe(
        'MachineConfiguration',
        'Incident1'
    );
    create_command := FALSE;
END_IF

// save_command が Trueになると、Incident1レシピ、およびそのファイルへ現在値が上書き保存されます。
IF save_command THEN
    recipe_manager.ReadAndSaveRecipe(
        'MachineConfiguration',
        'Incident1'
    );
    save_command := FALSE;
END_IF
```