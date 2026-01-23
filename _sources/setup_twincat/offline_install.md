(section_package_manager_offline_install)=
# パッケージマネージャでオフラインインストールする方法

パッケージマネージャに登録したパッケージのFeedsサーバは初期状態でBeckhoff社のサーバが設定されています。通常はインターネットを経由してここからパッケージを取得してインストールを行います。

しかし、エンドポイントのコントローラは必ずしもインターネットアクセスができる環境にあるとは限りません。よって、いちどパッケージをダウンロードしておき、オフライン状態でもパッケージマネージャを通じてインストールできる必要があります。

また、複数のIPCや開発環境において、同じバージョンに統一したい場合、Beckhoff社サーバから供給を受けていると古いパッケージが供給されなくなることが起こります。このため、お手元のローカルにパッケージを保持しておき、{ref}`section_tcpkg_export_import` の運用と併用してExportされたパッケージカタログの該当バージョンと共に配布する運用を行うことが求められます。

ここでは、ローカルに保存したパッケージを通じてパッケージマネージャからインストールを行う方法をご説明します。

## オンラインPCでのパッケージのダウンロード

PowerShellなどのコマンドラインインターフェースにて、次のコマンドを発行してください。

1.  インストール可能な代表パッケージ名一覧を出力。

    ```{code} powershell
    PS> tcpkg list -t workload
    ```

2.  この中から必要なパッケージを選択して、次のコマンドによりダウンロードする。

    たとえば、XAEとXARの両方を” C:\home\Administrator\pakages” にダウンロードする場合は以下のコマンド発行します。最初表示が無いまま時間を要しますが根気強く待ってください。
    ```{code} powershell
    PS> tcpkg download TwinCAT.Standard.XAE TwinCAT.Standard.XAR -o "C:\home\Administrator\pakages"
    ```

3.  このpackagesフォルダをUSBメモリ等に入れます。

### 自動化スクリプト

全てのパッケージ一覧を取得してダウンロードするPowerShellスクリプトをご紹介します。下記のとおりPowershellスクリプトを `fetch_packages.ps1` という名前で保存してください。

```{code-block} powershell
:caption: fetch_packages.ps1

# parameter
param (
    [String]$distination = "."
)

# Get package list
$packages = tcpkg list -t workload | ForEach-Object {
    if ($_ -match "\[(.+)\]\s+(.+)\s+(.+)") {
        New-Object -TypeName PSObject -Property @{
            "feed" = $matches[1]
            "name" = $matches[2]
            "version" = $matches[3]
        }
    }
}

$command = 'tcpkg download'

foreach ($item in $packages){
    $command += " " + $item.name
}


$command += " -o " + $distination 

invoke-expression $command
```

次のコマンドを実行することで、 `<保存先パス>` にFeedに登録したサーバからの全てのパッケージを保存します。

```{code} powershell
PS> fetch_packages.ps1 <保存先パス>
```


````{tip} 

スクリプト中、`$packages` 変数にはすべてのパッケージリストのPowerShellのオブジェクトに変換されます。次の通り `name` 列にパッケージ名が一覧されます。

```{code-block}
feed                   name                                      version
----                   ----                                      -------
Beckhoff Stable Feed   Beckhoff.DeviceManager.XAR                2.4.5
Beckhoff Stable Feed   TC1000.ADS.XAR                            1.0.0
     :
Beckhoff Outdated Feed TwinCAT.StandardRM.XAE                    4024.67.1
Beckhoff Stable Feed   TwinCAT.SupportInformationReport.XAE      20.17.3
```

この一覧から必要なものだけにフィルタしていただいたものを `$packages` に設定していただければ、必要なパッケージリストだけをダウンロードする事も可能です。

````

## オフライン環境のIPCでの作業

次にオフライン環境のIPCにてUSBメモリを挿し、IPC内に展開します。パッケージマネージャの設定にてオフラインパス設定を変更し、そのフォルダからインストールできるようにします。

4. IPCにUSBメモリを挿し、任意のフォルダへコピーします。

    本手順の例では `C:\Users\Administrator\Documents\packages` にコピーしたものとします。

5. パッケージマネージャを起動し、設定画面を開き、`Feeds` タブを選び、左下の `+` アイコンを押します。

    ![](assets/2025-08-15-18-38-10.png){align=center}

6. 追加するFeedの `Name` に適当な名前を付けて、`Feed url..` に `C:\Users\Administrator\Documents\packages` を設定して `Save` ボタンを押します。

    ![](assets/2025-08-15-18-38-53.png){align=center}

7. 追加したFeed以外のEnableのチェックを外し、右下のフロッピーアイコンを押します。

    ![](assets/2025-08-15-18-39-18.png){align=center}

以上です。通常通りのパッケージインストールを実施してください。

```{note}
Feed URLで指定したフォルダを定期的に更新してください。Feed URLで指定したフォルダ内にあるパッケージのみインストール可能です。
```