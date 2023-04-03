## ユーザーライブラリの作成と使用方法

開発時に作成したソフトウェア部品をライブラリとして登録する方法について示します。ライブラリ化したソフトウェアは、部品として再利用できる状態になります。

この章では、このライブラリ機能の基本的な使い方について説明します。最初にライブラリの作成と、その使い方について大まかな手順を説明し、後半ではライブラリ作成時の詳細な設定方法について説明します。

(library_making_basic)=
### ライブラリの作成手順

1. PLC $>$ Project で右クリックして、 `Properties` を選択する。

    ```{image} assets/Solution_ProjectProperties.png
    :width: 300px
    :align: center
    :name: Solution_ProjectProperties
    ```

2. Project Infomation に Library の情報を入力します。 設定必要な項目について以下に示します。

    ```{csv-table}
    :header: 項目, 説明
    :widths: 20,80

    Company, ライブラリを開発する組織名を入力します。
    Title, ライブラリ名称を記述します。`Placeholder`を未定義にすると、この名称がPlaceholderとしても設定されます。バージョンの連続性を担保するためにも、途中からこの名称を変更しないようにご注意ください。
    Version, ライブラリバージョンを定義します。必ず4桁のピリオド区切りで定義してください。
    Released, {ref}`section_about_released_flag` をご覧ください。
    Library Categories, {ref}`section_library_category` をご覧ください。
    Default namespace, 読み出す側とライブラリ内の変数名やファンクションブロック名が被らないように、該当ライブラリ内のリソースの頭に付ける接頭語を定義します。
    Placeholder, 作成したライブラリを読み込むと、デフォルトでは`Title`に示したPlaceholderが自動作成されて、これにライブラリが紐づきます。任意のPlaceholderを指定したい場合はこの欄で指定します。派生版のライブラリを作成される場合のブランチ名として利用されると良いでしょう。
    Author, 開発者名を記入します。
    Description, 説明を記入します。
    Global version structure, "ボタンを押すと読み込んだライブラリに関するバージョン情報をプログラムから参照する事ができるようにグローバル変数を自動生成します。`Version` 欄に指定したピリオドで区切られた4つのバージョンの値を順に、`iMajor`, `iMinor`, `iBuild`, `iRevision` で取り出す事ができ、`Released`フラグの有無を `nFlags` で取り出す事ができます。"
    POUs for property access, "ライブラリのメタ情報を取り出すファンクションを自動生成します。読みだしたライブラリ側では、本画面で設定する、`Compay`, `Title`, `Version` がそれぞれ取り出せます。"
    Document format, 開発ドキュメントの記述方式を選択します。{ref}`chapter_documentation`章のドキュメント記述方式を有効にするため、必ず`reStructuredText`を選択してください。
    ```

    設定内容については、 {ref}`prject_detail_setting` で詳しく説明します。

    ```{image} assets/Properties_Common.png
    :width: 300px
    :align: center
    :name: Properties_Common
    ```

3. PLC $>$ Project で右クリックして、 `Save as library and install ...` を選択する。  

   ```{image} assets/Solution_SaveLibrary.png
   :width: 350px
   :align: center
   :name: Solution_SaveLibrary
   ```

   ```{note}
   `Save as library` だけを行った場合、お使いの環境のXAEへのライブラリのインストールは行われません。{ref}`install_library` 節で説明するインストール手順を別途実施する必要があります。
   ```

4. ライブラリを保存する。 

   保存形式には次の二つがあります。

   * library 形式

      ソースファイルのプログラムイメージ。ライブラリを使用する開発者がライブラリを読み込んだ後もソースコードを閲覧し、オンラインモニタする事が可能です。ただしプログラムの変更はできません。

   * compiled-library 形式

      コンパイル済みのプログラムイメージ。ライブラリのソースコードを閲覧する事はできません。

   ```{image} 2023-02-28-08-55-34.png
   :width: 400px
   :align: center
   :name: Dialog_SaveLibrary
   ```


### ライブラリの使用方法

(install_library)=
#### ユーザライブラリのインストール

ユーザライブラリは、XAE単位でインストールが必要となり、プロジェクト毎にインポートする必要があります。ここではユーザライブラリをXAEにインストールを行う手順について説明します。

ライブラリを作成したXAEにおいて、ライブラリ保存時に`Save as library and install ...`を選択された場合はこの節の手順を実施する必要はありません。

ただし、ライブラリを更新インストールされた場合は必ずライブラリ読み出し側のプロジェクトのVisualStudioもしくはXAEシェルを再起動してください。

1. PLCのプロジェクトツリーから `References` 以下のメニューをダブルクリックします。

    これによりメインウィンドウにライブラリマネージャが現れます。

    ```{image} 2023-02-21-13-37-07.png
    :width: 500px
    :align: center
    :name: 2023-02-21-13-37-07
    ```

2. `Library repository`ボタンを押してください。

    ```{image} assets/LibraryManager_Main.png
    :width: 500px
    :align: center
    :name: LibraryManager_Main
    ```

3. `Library Repository`ウィンドウからインストールする  

    `Install...` ボタンを押すとエクスプローラが現れます。インストールしたい library ファイルを選択します。

    ```{image} assets/LibraryRepository_Main.png
    :width: 300px
    :align: center
    :name: LibraryRepository_Main
    ```

4. ここで一度プロジェクトを上書き保存してXAEを終了します。

    ```{admonition} 警告
    :class: warning

    インストールしたライブラリを正しくお使いいただくには一度ライブラリ呼び出し側のプロジェクトのVisualStudioもしくはXAEシェルを再起動する必要があります。再起動なしにライブラリマネージャを閲覧した場合、特に{ref}`chapter_documentation` 章で説明する、ライブラリのドキュメントの表示が行われない問題が生じます。
    ```

5. 再度プロジェクトを開いてライブラリマネージャの`Library repository`を開くと、インストールしたライブラリが一覧されていることが確認できます。

    ```{figure} assets/LibraryRepository_InstalledLibrary.png
    :width: 500px
    :align: center
    :name: LibraryRepository_InstalledLibrary

    追加したライブラリ
    ```

(import_library)=
#### プロジェクトへのライブラリの追加

XAEにインストールしたライブラリをプロジェクトへ追加する手順を説明します。

1. 以下いずれかの方法でライブラリの追加を行います。

   * Library Manager から `Add library` ボタンを押す
    
        ```{image} assets/LibraryManager_AddLibrary.png
        :width: 500px
        :align: center
        :name: LibraryManager_AddLibrary
        ```
   * PLCプロジェクトツリーの`References`を右クリックして`Add library...`を選択する


3. 登録したライブラリを追加します。

    ```{image} assets/AddLibrary_UseLibrary.png
    :width: 500px
    :align: center
    :name: AddLibrary_UseLibrary
    ```
    
4. 登録したライブラリが References に追加されることを確認します。

    ```{image} assets/Solution_References.png
    :width: 150px
    :align: center
    :name: Solution_References
    ```

(update_library)=
#### ライブラリの更新

新しいライブラリが発行されましたら{ref}`install_library` を行うことで最新版が使える状態となります。

デフォルトでは常に最新版を使う設定になっていますので、新しいライブラリをインストールすれば即プログラムは更新された状態となります。しかし、Placeholderを使わずにライブラリをインストールしていたり、特定バージョンにPlaceholderが固定されている場合は、新しいライブラリをインストール後、そのバージョンを使うように設定しなおす必要があります。

この場合、{ref}`placeholder_change_resolution`の図の通り`References`以下の目的のライブラリを選択し、右クリックして現れたサブメニューから`Properties`を選ぶと、`Properties`ウィンドウが現れます。この中の`Misc`カテゴリに`Resolution`という項目から選択することができます。

常に最新バージョンを使う設定にする場合は、ライブラリ名の後がバージョン番号ではなくアスタリスク `*` のものを選択してください。

```{figure} 2023-03-02-16-13-13.png
:width: 700px
:align: center
:name: placeholder_change_resolution

Placeholderに紐づいたライブラリのバージョン切替方法
```

(prject_detail_setting)=
### 詳しい使い方

#### Placeholdersの活用

Placeholderとは、ひとことでいうとライブラリに対するショートカットです。それぞれのプログラムやライブラリが直接ライブラリと関連付けられるのではなく、仮想化されたショートカットと紐づく事で、設定によって参照するライブラリの実体を柔軟に切り替える事が可能になります。

{ref}`import_library`節で説明するライブラリ追加手順では、暗黙的にライブラリ名と同名のPlaceholderが作成され、このPlaceholderを経由してライブラリ読み込みされます。{ref}`placeholder_overview` の図に示される赤下線で引かれた部分にある`=`の左辺にある文字がPlaceholderです。この`=`の右辺にあるものが実際のライブラリを示していて、`ライブラリ名, バージョン番号（組織名）`という書式になっています。デフォルトでは、バージョン番号部分は`*`となっていて、常に最新のライブラリバージョンと紐づく仕様となっています。

```{figure} 2023-03-02-16-05-14.png
:width: 400px
:align: center
:name: placeholder_overview

通常の手順でライブラリ追加されたライブラリマネージャ画面
```

```{note}
Placeholderを経ずに直接ライブラリを読み込む事は可能ですが、ここでは説明しません。
```

Placeholderにリンクするライブラリバージョンを切り替える方法は、{ref}`update_library`節で示す手順同様、Propertiesの`Resolution`項目で選択します。（{ref}`placeholder_change_resolution` 図参照）

次からPlaceholderを活用する方法に代表的な2例に基づいて操作手順を示します。

##### 共有ライブラリのバージョンを一斉に切り替える

複数のライブラリやライブラリを読み込むプログラムで使われているライブラリが共有されるケースがあります。例えば、{ref}`placeholder_tc3_module_recent_version` に示す通り、どのライブラリやプログラムもTc3_Moduleという名前のPlaceholderを使用しており、デフォルトで最新版を使う設定となっています。

```{figure} 2023-03-02-17-03-24.png
:width: 700px
:align: center
:name: placeholder_tc3_module_recent_version

Tc3_Module 最新版を使う設定
```

このPlaceholderを{ref}`placeholder_tc3_module_fixed_version`のように、PropertyのResolutionで特定バージョンを使う様に設定を変えると、関連するライブラリやプログラム全てが指定したバージョンのものに固定されます。

```{figure} 2023-03-02-17-16-54.png
:width: 700px
:align: center
:name: placeholder_tc3_module_fixed_version

Tc3_Module 特定バージョンに固定した設定
```

##### 別名のPlaceholderを設定する

Placeholder名は、デフォルトでライブラリ名と同一のものが自動作成されます。これにより、複数のライブラリが同一のライブラリを共用しても、自動的に同一のPlaceholderが参照される仕組みとなっています。

今度は、敢えて自動生成せずに任意のPlaceholder名を名付けてライブラリを追加してみます。例として、オリジナルのユーザライブラリである、"IPC Performance to influxDB via TF6420" という名前のライブラリを作成しますが、このライブラリが使う`Tc-Module`ライブラリを、別名のPlaceholderに関連付けてみます。

次に、このユーザライブラリを使う別のPLCプロジェクトにおいて、ライブラリが使う`Tc-Module`ライブラリとその他が使う`Tc-Module`ライブラリが個別のPlaceholderとなることを確認してみます。

まずは、「IPC Performance to influxDB via TF6420」ライブラリで別名のPlaceholderで`Tc-Module`ライブラリを追加する手順を示します。

1. {ref}`import_library`に示す手順の`Add library`ウィンドウにて左下の`Advanced...` ボタンを押します。

    ```{image} 2023-03-02-18-04-27.png
    :width: 300px
    :align: center
    ```
2. `Placeholders`タブを開き、`Placeholder name` のフィールドに新たに命名したい名前を入力します。

    この例として`Tc3-Module`に対する別名であることがわかるように`Tc3-Module-fixed-version`と入力しています。

    ```{image} 2023-03-02-18-11-37.png
    :width: 300px
    :align: center
    ```

3. 何等かの文字を入力した時点でXAEにインストールされたライブラリが一覧されます。ここから`Placeholder`に関連付けるライブラリを選択します。

    ```{image} 2023-03-02-18-05-38.png
    :width: 300px
    :align: center
    ```
4. 追加されたライブラリが、`Tc3-Module`ではなく、指定した名前`Tc3-Module-fixed-version`で追加された事がわかります。

    ```{image} 2023-03-02-18-25-31.png
    :width: 500px
    :align: center
    ```

上記の手順で作成されたユーザライブラリを追加したPLCプロジェクトのライブラリ構成は、{ref}`another_placeholder_for_user_library`の通りとなります。`Tc3_Module`ライブラリが複数使われていますが、"IPC Performance to influxDB via TF6420" のユーザライブラリで使われている`Tc3_Mdoules`ライブラリだけは、バージョンが固定された状態となっています。

```{figure} 2023-03-02-18-37-55.png
:width: 500px
:align: center
:name: another_placeholder_for_user_library

別名のPlaceholderで同一ライブラリを読み込ませた例
```

このように、一部だけ特定のバージョンを使用したい場合などにPlaceholderで区別する方法があります。

```{admonition} 読み込み側のPLCプロジェクトでライブラリが使用するライブラリのバージョンを変更できるか？

できません。同一のPlaceholderとなっていれば読み込み元の親PLCプロジェクトでリンクを一括変更できました。しかし、固有のPlaceholderとされた場合は、そのPlaceholderを保有するPLCプロジェクトでのみライブラリのバージョンを設定できますので、今回の場合、固有のPlaceholderを持つ読み込み元のライブラリ側で任意のバージョンへリンク設定を変更する必要があります。
```


#### Namespace機能の活用

Default namespaceには、ライブラリで使用されるさまざまなリソースに対してユニークとするための名前空間です。

例えば、Default namespaceに `bajp` と設定します。このライブラリのPOUsでは、MAINというプログラムが使われていました。

このライブラリを読み込んだPLCプロジェクトにも、MAINという名前のプログラムがある場合、名前が被っています。

そこで、ライブラリ側のMAINプログラムは、 `bajp.MAIN();`と記述することで、ライブラリ内のMAINプログラムを呼び出している事を特定でき、無事実行する事ができます。

(section_about_released_flag)=
#### Versionの`Released`チェックについて

このチェックを入れることにより、そのあとプログラム変更を行おうとした際に{ref}`released_flag_warning`のような警告メッセージが出現します。`Released`チェックが付けられていてもプログラム変更を禁止するのではなく、単なる警告のみです。ここで`Yes`ボタンを押すと`Released`チェックが自動的に外れます。


```{figure} 2023-03-02-17-31-59.png
:width: 300px
:align: center
:name: released_flag_warning

Released チェックのPLCプロジェクトに変更を与えようとした際の警告ダイアログ
```
(section_library_category)=
#### カテゴリの登録

ライブラリ作成元となるPLCプロジェクトのpropertyの設定の中で、`Library Categories` という設定項目があります。この項目を未設定のままにしておくと、{ref}`LibraryRepository_InstalledLibrary`の例に示すように、全て `Miscellaneous` （その他）という項目に所属します。 

ここでは任意のカテゴリーツリーを生成し、ライブラリ化した際にどのカテゴリに所属させるかの設定までの手順について説明します。

1. 以下のサイトからカテゴリのオブジェクトIDであるUUIDを生成します。`Generate some GUIDs!` ボタンを押したらフォーム上にUUIDが生成されますので、そのあと`Copy to Clipboard`ボタンを押してください。サブカテゴリーが必要な場合は2つ生成してください。

    [https://guidgenerator.com/online-guid-generator.aspx](https://guidgenerator.com/online-guid-generator.aspx)

2. 以下のXMLのうち、`Id`タグ部分をクリップボードにコピーしたUUIDに置換し、`DefaultName`にカテゴリ名を定義します。

    次の例に示す通り、`ParentCategory` に親カテゴリの`Id`を関連付けて定義することで、ツリー構造を定義することができます。不要であれば二つ目以後の`LibraryCategory`タグ要素は全て削除してください。

    ```{code-block} xml
    <?xml version="1.0" encoding="UTF-8"?>
    <LibraryCategories xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="LibraryCategories.xsd">
        <LibraryCategory>
            <Id>f484dac6-21b6-4d52-a832-fa3cc2ceea83</Id>
            <Version>1.0.0.0</Version>
            <DefaultName>Beckhoff-JP</DefaultName>  
        </LibraryCategory>
        <LibraryCategory>
            <Id>e42e9899-3114-40a3-911f-5f44e2769932</Id>
            <Version>1.0.0.0</Version>
            <ParentCategory>
                <Id>f484dac6-21b6-4d52-a832-fa3cc2ceea83</Id>
            </ParentCategory>
            <DefaultName>SystemDiagnostics</DefaultName>
        <LibraryCategory>
            <Id>1547e2ea-7ffb-4c94-becc-56f97d1a03bd</Id>
            <Version>1.0.0.0</Version>
            <ParentCategory>
                <Id>e42e9899-3114-40a3-911f-5f44e2769932</Id>
            </ParentCategory>
        <DefaultName>IPCPerformance</DefaultName>
        </LibraryCategory>
                <LibraryCategory>
            <Id>ebb42e0a-ab3e-4c49-880e-9e854060901d</Id>
            <Version>1.0.0.0</Version>
            <ParentCategory>
                <Id>f484dac6-21b6-4d52-a832-fa3cc2ceea83</Id>
            </ParentCategory>
            <DefaultName>Utility</DefaultName>
        </LibraryCategory>
    </LibraryCategories>
    ```

    ```{admonition} 警告
    :class: warning

    登録に使った*.libcat.xmlファイルは大切に保管しておいてください。運用中にカテゴリを追加・削除したい場合に一部の要素のみ更新する機能がありません。カテゴリ定義全体を都度読み込ませる必要があります。

    万が一紛失してしまった場合、TwinCATのPLCプロジェクト内のファイルから、既存のカテゴリのUUIDが何かを調べる方法があります。以下のフォルダ構成の中にある*.plcprojファイルを探します。

        <<TwinCATプロジェクト名>>/<<PLCプロジェクト名>>/<<PLCプロジェクト名>>.plcproj
        
    このファイルをUTF-8で編集可能なXMLテキストエディタで開いてください。下記の`LibraryCategoriy`の中の`Id`タグを探して、登録済みのカテゴリのメタデータを調べ、本手順書のフォーマットに従って再作成してください。

    ```{code-block} xml
    <Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <PropertyGroup>
    :
    :
    <LibraryCategories>
        <LibraryCategory xmlns="">
            <Id>{f484dac6-21b6-4d52-a832-fa3cc2ceea83}</Id>
            <Version>1.0.0.0</Version>
            <DefaultName>Beckhoff-JP</DefaultName>
        </LibraryCategory>
        </LibraryCategories>
    ```


3. `*.libcat.xml` というファイル名で、UTF-8エンコードしたテキストファイルで保存します。（`*`部分は任意の名前）

4. 保存したファイルを読み込むには{ref}`add_category_procedure`の図の通り次の手順を実施します。
    1. {ref}`library_making_basic`で示したProperty設定にて、`Library Categories` 設定項目右端にあるボタンを押します。
    2. `Library Category` ウィンドウが現れます。右側の `Add >` ボタンを押して現れるメニューから`From Decription File...`ボタンを押します。エクスプローラが現れますので、先ほど保存した*.libcat.xmlファイルを選択して読み込みます。
    3. {ref}`add_category_procedure`の図の下部ウィンドウに示す通り、XMLに定義されたカテゴリーツリーが一覧されます。初期状態では全てにチェックが入っていますので、一度`None`を押して全てチェックを外します。
    4. 現在のPLCプロジェクトの提供する機能が含まれる末端のカテゴリだけにチェックを入れます。
    5. OKボタンを押します。 

    ```{figure} 2023-02-28-11-41-44.png
    :width: 600px
    :align: center
    :name: add_category_procedure

    カテゴリの登録操作
    ```

5. 選択されたカテゴリが一覧されたのを確認し、OKボタンを押してください。

    ```{image} 2023-02-28-11-43-30.png
    :width: 400px
    :align: center
    ```

6. {ref}`install_library`節に示す手順を実施する際にライブラリをインストールすると、{ref}`install_library_with_category`図の通りのカテゴリに一覧された状態で配置されます。複数個所に一覧されますが実態は同じです。

    ```{figure} 2023-02-28-11-47-23.png
    :width: 450px
    :align: center
    :name: install_library_with_category

    カテゴリツリーに登録されたライブラリ
    ```

```{admonition} 複数カテゴリへ登録するケース
:class: note

開発者がプログラム機能を流用する場合には、分類された機能の種類から関連プログラム部品を探します。対して、すでに稼働しているPLCプロジェクトには、通常さまざまな種類の機能が組み合わされた状態になっています。

すでに稼働しているPLCプロジェクトを基にライブラリ化する場合、このプロジェクトに含まれる機能全ての分類カテゴリに含まれるように登録します。これにより開発者は目的とする機能が使われているプログラムオブジェクトをすぐに見つけることが容易になります。

この節で示す例では、タスク実行時間やCPUの占有率など、IPCのパフォーマンスメトリクスを収集するファンクションブロックと、そのデータをTF6420 Database serverを使ってInfluxDBへ記録するPLCプロジェクトをそのままライブラリ化しました。このため、`IPCPerformance`というカテゴリと、`InfluxDB` というカテゴリ両方に所属させる事で、どちらの用途からも機能を再利用する事が可能になっています。

ただし、手間を惜しまないのであれば、出来る限り単一の機能にライブラリを分割するのが望ましいです。プログラムの同士の機能の独立性が低いことで、一部の機能の修正により関係ない機能まで影響を受ける事となり、品質面への影響やテスト工数などの管理面での副次的なコストが大きくなるためです。

とはいえ、動作実績のあるプログラムをそのままライブラリ化する事にも価値があります。なにより既存のPLCプロジェクトをそのままライブラリ化すれば良いだけなので手間がほどんど要りません。また、{ref}`chapter_documentation`章に示すreStructuredTextによるライブラリドキュメント機能を活用することでプログラム実装例の参考にも大いに役立ち、早期に開発者間での技術情報共有が可能になります。

長期的にはライブラリを単一機能まで分割する「リファクタリング」は欠かせません。しかしこの過渡状態でも流用したいモジュールは多分にあります。そういった場面においてカテゴリやPlaceholderで区別するなどの工夫により、より柔軟な運用が可能になるでしょう。

```
