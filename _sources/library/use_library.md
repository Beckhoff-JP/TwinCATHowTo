(section_use_library)=
# ライブラリを読み込んで使う

(install_library)=
## ライブラリを読み込む方法

ユーザライブラリは、XAE単位でインストールが必要となり、プロジェクト毎にインポートする必要があります。ここではユーザライブラリをXAEにインストールを行う手順について説明します。

ライブラリを作成したXAEにおいて、ライブラリ保存時に`Save as library and install ...`を選択された場合はこの節の手順を実施する必要はありません。

ただし、ライブラリを更新インストールされた場合は必ずライブラリ読み出し側のプロジェクトのVisualStudioもしくはXAEシェルを再起動してください。

1. PLCのプロジェクトツリーから `References` 以下のメニューをダブルクリックします。

    これによりメインウィンドウにライブラリマネージャが現れます。

    ```{image} assets/2023-02-21-13-37-07.png
    :width: 800px
    :align: center
    :name: 2023-02-21-13-37-07
    ```

2. `Library repository`ボタンを押してください。

    ```{image} assets/LibraryManager_Main.png
    :width: 800px
    :align: center
    :name: LibraryManager_Main
    ```

3. `Library Repository`ウィンドウからインストールする  

    `Install...` ボタンを押すとエクスプローラが現れます。インストールしたい library ファイルを選択します。

    ```{image} assets/LibraryRepository_Main.png
    :width: 500px
    :align: center
    :name: LibraryRepository_Main
    ```

4. ここで一度プロジェクトを上書き保存してXAEを終了します。

    ```{admonition} 警告
    :class: warning

    インストールしたライブラリを正しくお使いいただくには一度ライブラリ呼び出し側のプロジェクトのVisualStudioもしくはXAEシェルを再起動する必要があります。再起動なしにライブラリマネージャを閲覧した場合、特に{ref}`chapter_documentation` で説明する、ライブラリのドキュメントの表示が行われない問題が生じます。
    ```

5. 再度プロジェクトを開いてライブラリマネージャの Library repositoryを開くと、インストールしたライブラリが一覧されていることが確認できます。

    ```{figure} assets/LibraryRepository_InstalledLibrary.png
    :width: 700px
    :align: center
    :name: LibraryRepository_InstalledLibrary

    追加したライブラリ
    ```

(import_library)=
## プロジェクトへのライブラリの追加

XAEにインストールしたライブラリをプロジェクトへ追加する手順を説明します。

1. 以下いずれかの方法でライブラリの追加を行います。

   * Library Manager から `Add library` ボタンを押す
    
        ```{image} assets/LibraryManager_Addlibrary.png
        :width: 800px
        :align: center
        :name: LibraryManager_AddLibrary
        ```
   * PLCプロジェクトツリーの`References`を右クリックして`Add library...`を選択する


2. 登録したライブラリを追加します。

    ```{image} assets/AddLibrary_UseLibrary.png
    :width: 700px
    :align: center
    :name: AddLibrary_UseLibrary
    ```

3. ライブラリパラメータがあれば設定します。

    {ref}`section_library_parameter` に示す通りライブラリ内で使用されるリソースがスケールする場合は、パラメータ化されている可能性があります。この場合、ライブラリを追加した後に`Library Parameters`タブからリソース量を変更することができます。

    ![](assets/2024-02-21-18-08-34.png){align=center}
    
4. 登録したライブラリが References に追加されることを確認します。

    ```{image} assets/Solution_References.png
    :width: 250px
    :align: center
    :class: with-shadow
    :name: Solution_References
    ```

(update_library)=
## ライブラリの更新

新しいライブラリが発行されましたら{ref}`install_library` を行うことで最新版が使える状態となります。

デフォルトでは常に最新版を使う設定になっていますので、新しいライブラリをインストールすれば即プログラムは更新された状態となります。しかし、Placeholderを使わずにライブラリをインストールしていたり、特定バージョンにPlaceholderが固定されている場合は、新しいライブラリをインストール後、そのバージョンを使うように設定しなおす必要があります。

この場合、{numref}`placeholder_change_resolution`の図の通り`References`以下の目的のライブラリを選択し、右クリックして現れたサブメニューから`Properties`を選ぶと、`Properties`ウィンドウが現れます。この中の`Misc`カテゴリに`Resolution`という項目から選択することができます。

常に最新バージョンを使う設定にする場合は、ライブラリ名の後がバージョン番号ではなくアスタリスク `*` のものを選択してください。

```{figure} assets/2023-03-02-16-13-13.png
:width: 1000px
:align: center
:name: placeholder_change_resolution

Placeholderに紐づいたライブラリのバージョン切替方法
```
