# リポジトリの作成（外部のリポジトリのクローン）

既に外部に存在するリモートリポジトリから自分のローカルPCへリポジトリを新規に展開する方法について説明します。

この方法の場合、リモートリポジトリはクローン元のものに設定された状態となりますので、{ref}`section_sync_git_remote` で説明する同期先の設定は不要です。

本節では、例として [MachineAlarmManagement](https://github.com/Beckhoff-JP/MachineAlarmManagement) のGithubリポジトリを例に、自分のプロジェクトへ展開する手順について説明します。

1. GithubのサイトからリポジトリのURLを取得します。

    ![](assets/2024-02-16-08-53-50.png){align=center}

2. 新規にTwinCAT XAEを起動し、`File > Open > Open from source control` を選択する。

    ![](assets/2024-02-16-08-44-00.png){align=center}

3. `Local Git Repositories`の階層の中の、`Clone`をクリックし、上部のフィールドにGithubのリポジトリURLを入力し、下部のフィールドには自分のPCのリポジトリ格納先パスを設定し、Cloneボタンを押します。

    ![](assets/2024-02-16-08-55-52.png){align=center}

4. ソリューションエクスプローラには、次の通りファイル一覧として現れます。`*.sln`ファイルをダブルクリックすると、該当するソリューションプロジェクトを開く事ができます。

    ![](assets/2024-02-16-09-08-52.png){align=center}

クローン元のリポジトリが、次の2つが未対応の場合は併せて対応してリポジトリへ反映してください。

* {ref}`section_gitignore_for_twincat` 
* {ref}`section_register_compare_viewer`