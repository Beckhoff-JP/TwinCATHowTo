(section_setup_docker)=
# Docker composeによるインストール

IPCとは別のLinuxベースのサーバへインストールする場合、個々のアプリケーションを個別にインストールするのではなく、スクリプトだけで配置が可能なDocker composeを用いて導入すると便利です。

この章では、GrafanaとInfluxDBをdocker composeを用いてインストールする方法を説明します。

## Docker Desktopのインストール

1. WSL2を有効にします。Windowsの再起動が必要です。

    Power shellを管理者権限で起動し、次のコマンドを入力します。
    ```{code-block} powershell
    PS> wsl --install
    ```
    次の通りインストールが進みます。完了したらPCを再起動してください。
    ```{code-block} powershell
    PS> wsl --install
    インストール中: 仮想マシン プラットフォーム
    仮想マシン プラットフォーム はインストールされました。
    インストール中: Linux 用 Windows サブシステム
    Linux 用 Windows サブシステム  はインストールされました。
    インストール中: Linux 用 Windows サブシステム
    Linux 用 Windows サブシステム  はインストールされました。
    インストール中: Ubuntu
    Ubuntu はインストールされました。
    要求された操作は正常に終了しました。変更を有効にするには、システムを再起動する必要があります。

2. PC再起動後、Docker Desktopを下記からダウンロードして、インストールを行います。

    [https://docs.docker.com/desktop/install/windows-install/](https://docs.docker.com/desktop/install/windows-install/)

    インストールを開始すると次の画面が現われます。`Use WSL 2 Instead of Hyper-V` には必ずチェックを居sれ手OKボタンを押してください。インストールが開始します。

    ![](assets/InstallingDockerDesktopOptions.png){width=500px align=center}

    ![](assets/InstallingDockerDesktopProgress.png){width=500px align=center}

    ![](assets/InstallingDockerDesktopFinish.png){width=500px align=center}

3. インストールあと、デスクトップに作成されたアイコンからDocker Desktopを実行します。

    初回、下記の通り非商用用途に限り無償である旨メッセージが現われます。同意される場合は、Acceptボタンを押します。
    ![](assets/runFirstAgreement.png){width=600px align=center}

    ```{warning}
    本サーバを製品に搭載されるなど商用利用の場合はDocker社と有償契約を結び、ライセンス条項にしたがって正しくご使用ください。
    ```
    続いて、アンケート画面になります。回答いただくかSKIPボタンを押してください。
    ![](assets/runFirstJustSkip.png){width=600px align=center}



## InfluxDBとGrafanaのインストール

まず空のフォルダを作成し、次の2つのテキストファイルを作成します。メモ帳などで下記をコピーペーストし、それぞれ冒頭に記載している名前のファイル名で保存してください。

なお、 `.env` ファイルの内容は、初期設定に関する設定項目です。それぞれコメントに従い適切な値に書き換えてください。


```{literalinclude} assets/.env
:caption: .env ファイル
:language: yaml
:linenos:
```

```{literalinclude} assets/docker-compose.yml
:caption: docker-compose.yml ファイル
:language: yaml
:linenos:
```

上記2ファイルが存在するディレクトリでユーザ権限でPower shellを開き、以下のコマンドを実行します。

```{code-block} powershell
PS> docker compose up -d
```
インターネットから自動的にさまざまなコンポーネントをダウンロードし、インストール、および初期設定が自動的に実行されます。

```{code-block} powershell
PS> docker compose up -d
[+] Running 0/2
 - grafana Pulling
 - influxdb Pulling
    :
    :
```

途中でWindows Firewallのポート開放許可を確認するダイアログが出現したら、許可を行ってください。

実行が完了したら、次図の通りDocker desktop上の管理画面において、二つのコンポーネントが稼働していることがわかります。

![](assets/2023-06-19-11-25-26.png)

外部のPCからブラウザより `http://<InfluxDBをインストールしたサーバIPアドレス>:8086/` にアクセスして、InfluxDBの管理画面へログインします。`.env` ファイルで設定したユーザ名、パスワードでログインできることを確かめてください。

