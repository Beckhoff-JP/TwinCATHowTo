# リポジトリの作成（新規作成）

ここでは、Gitで管理されていないTwinCATプロジェクトを新規にGitリポジトリとして管理するための手順を説明します。

(section_gitignore_for_twincat)=
## TwinCATプロジェクトへの`.gitignore`登録

`.gitignore`とは、そのフォルダ以下にある該当するファイルやディレクトリをバージョン管理対象から無視するための設定です。様々な一時ファイルや、キャッシュなどを除外する設定をあらかじめ行っておきます。以下のサイトに、.gitignoreの定義があります。ソリューションファイル(***.sln)が有る場所と同じディレクトリにテキスト形式で`.gitignore`ファイルを作成し、この定義内容を書き込んで保存してください。

TwinCAT3の .gitignore 定義
    : [https://infosys.beckhoff.com/content/1033/tc3_sourcecontrol/14604066827.html?id=2009874071818176821](https://infosys.beckhoff.com/content/1033/tc3_sourcecontrol/14604066827.html?id=2009874071818176821)

置き場所
    : ```
        Solution_Project
        │  .gitattributes
        │  .gitignore  <------------------- ここに置く
        │  Project1.sln

        ```


## リポジトリを作成

TwinCATのソリューションを開きます。ソリューションツリーのトップレベルでコンテキストメニューを出し、`Add Solution to Source Control...`を選びます。もし保存していないファイルがあれば保存を求められますので上書き保存を行ってください。

![](assets/2024-02-14-10-48-54.png){align=center}

(section_register_compare_viewer)=
## TwinCAT用の差分ビューワの登録

以下の手順で、Gitのリポジトリにおける差分ビューワとして`TcProjectCompare`を登録します。

1. 下図の手順で`TcProjectCompare`を出現し、`Configure User tool...`ボタンを押します。

    ``` TwinCAT > TcProjectCompare ```

    ![](assets/2024-02-14-18-53-46.png){align=center}

2. `Export Configuration`ボタンを押します。

    ![](https://infosys.beckhoff.com/content/1033/tc3_sourcecontrol/Images/png/9007199664206347__Web.png){align=center}

3. `Plugin` のセレクトタブから、`Git`を選びます。

    ![](https://infosys.beckhoff.com/content/1033/tc3_sourcecontrol/Images/png/14604021899__Web.png){align=center}

4. `Configure for`において`Spcific Project`を選びます。

    ![](https://infosys.beckhoff.com/content/1033/tc3_sourcecontrol/Images/png/14604018059__Web.png){align=center}

5. フォルダ選択のエクスプローラが現れます。該当するソリューションプロジェクトのフォルダを指定してください。

6. 次図の通り`Config file found!`と表示されれば成功です。

    ![](assets/2024-02-14-20-07-31.png){align=center}

```{note}
この手順により、ソリューションプロジェクトフォルダの直下にある`.git`フォルダ内の`config`ファイルに、TwinCATの差分エディタに関する設定が出力されます。
```