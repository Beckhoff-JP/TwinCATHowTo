# TwinCATビルドバージョンをフリーズする

![](assets/2023-05-11-11-17-42.png){w=300px align=center}

1. TwinCAT shellだけ（プロジェクトを読み込まず）に立ち上げてください。
2. 左上のバージョン選択フィールド（リモートマネージャと呼びます）を指定のバージョンへ変更します。

    現在のXAEと同じバージョンにフリーズする
    : 初期状態ではインストールされたXAEバージョンである `Build 4024.**(Default)` となっています。このままのバージョンでよければ、そのまま次へ進みます。

    接続しているリモートのIPC上のXARと同じバージョンにフリーズする
    : `Chose from Target System ...` を選択します。

    過去にインストールした任意のバージョンにフリーズする
    : リストに一覧されているバージョンを選択します。

    しばらくすると、リモートマネージャの表示が指定したバージョンで（Loaded）になると思います。

3. TwinCATプロジェクトを読み込みます。
4. 読み込みが終わったら一度ビルドしてください。これでリモートマネージャで指定したバージョンでのビルドイメージが作成されます。
5. そのあと、SYSTEMツリーを選択し、Generalタブの中のPin Versionのチェックを入れてください。これにより、どのバージョンのTwinCATでプロジェクトを開いても、この指定バージョンでビルドされる事になります。

    ```{note}
    * ほとんどのプロジェクトのリモートマネージャの設定はDefaultバージョンのままだと思います。指定したバージョンのものと交互にプロジェクトをひらくと、都度環境変更が行われますのでプロジェクトを開く時間がかかるストレスが生じます。この点ご承知おきください。
    * リモートマネージャで指定できるバージョンは、現在インストールされているXAEのバージョンよりも古いものに限ります。`Chose from Target System ...` を選択する際、XAR側が現在お使いのXAEのTwinCATバージョンより新しいバージョンである場合はビルドする事ができません。事前にターゲットのXARのバージョンより新しいTwinCAT XAEをインストールしてください。
    ```
