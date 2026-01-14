# TwinCATプロジェクトの作成とIPCへの接続

![](assets/2025-09-30-17-02-43.png){align=center}

ソリューションプロジェクト名と保存先を設定するウィンドウが現れますので、適切な名前で保存してください。

![](assets/2025-09-30-17-06-42.png){align=center}

```{list-table}
:widths: 4,6

- * ![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2602490379__en-US__Web.png){align=center}
  * TwinCATプロジェクトが生成され、ソリューションツリーにTwinCATプロジェクトのデフォルトツリーが現れます。

    SYSTEM
        : TwinCAT全般に関する設定（タスク、ライセンス、ADSルータ等）

    MOTION, PLC, SAFETY, C++
        : 各リアルタイムコンポーネントのプロジェクトを格納します

    IO
        : EtherCAT, EtherNet/IP, ProfiNet...など様々なリアルタイムIOリソースが一覧されます。
```

## IPCへの接続

TwinCATプロジェクトの初期状態では、ランタイム（XAR）への接続先が自分のPCである `<Local>` となっています。この節ではEthernetケーブルで接続した先のIPCに切り替える方法をご説明します。

```{attention}
IPCのWindows領域に開発環境をインストールされていてこのXAEをお使いの方はこの節は読み飛ばしてください。
```

```{admonition} 事前条件
:class: tip

* 開発用PCのIPCに接続しているEthernetポート、およびそのIPC側のEthernetポートは、どちらもIPアドレス自動取得設定になっているものとします。
* XAEと接続するIPC側のEthernetポートにリアルタイムドライバを適用必要はありません。
```

まず、`Choose Target System` タブ選択から、`Choose Target System...`を選択します。

```{list-table}
- * ![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2602494347__en-US__Web.png){align=center}
  * ![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2602832523__en-US__Web.png){align=center}
```

`Search (Ethernet)...` ボタンを押します。

![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2604322315__en-US__Web.png){align=center}

相手先のIPアドレスが分かっている場合
    : 赤枠欄にIPアドレスを設定して `Enter Host Name / IP:` ボタンを押してください。

    : ![](assets/2025-09-30-16-37-39.png){align=center}

相手先のIPアドレスが分からない場合
    : `Broadcast Search` ボタンを押してください。ネットワークカードが一覧されるウィンドウが現れます。OKボタンを押すとチェックを入れたカードからブロードキャストでIPCを検索します。

    : ![](assets/2025-09-30-16-43-26.png){align=center}



````{list-table}
:widths: 3,7

- * ターゲットIPCのホスト名、IPアドレスなどの情報が一覧されます。目的のIPCを選択し、`Addres Info:` 欄のラジオボタンを `IP Address` を選択してから `AddRoute` ボタンを押します。
    ```{attention}
     `IP Address` を選択しておかないとこの後Routeに接続に失敗します。
    ```
  * ![](assets/2025-09-30-17-21-11.png){align=center}
- * 1. `Secure ADS` および、`Self Signed Certificate` が選択します。
    2. `Check Fingerprint: `の文字列をダブルクリックして`CTRL + C`キーでクリップボードにコピーします。
    3. `Compare with:` 欄にカーソル移動して `CTRL+V` にてクリップボードの内容をペーストします。
  * ![](assets/2025-09-30-16-53-01.png){align=center}
    4. Remote User Credetials の `Password:` にIPCの `Administrator` ユーザのパスワードを入力して、最後に `OK` ボタンを押します。 
- * 接続に成功すると、Connected欄に鍵アイコンが表示されます。確認できたら `Close` ボタンを押してください。
  * ![](assets/2025-09-30-17-30-28.png){align=center}
- * Target System一覧に、追加したターゲットのIPCが一覧されています。選択された状態で`OK`ボタンを押します。
  * ![](assets/2025-09-30-17-32-59.png){align=center}
- * ターゲット先のIO情報やアーキテクチャ設定に更新するウィンドウが現れますので、いずれも`OK`ボタンをおしてください。
  * ![](assets/2025-09-30-17-35-12.png){align=center}
    
    ![](assets/2025-09-30-17-35-49.png){align=center}
````

以上の手順で、次の通りターゲットが `<Local>` IPCに切り替わっていることがわかります。

![](assets/2025-09-30-17-38-05.png){align=center}

* 基本的にXAE上での設定変更、操作は、接続先のIPCに対して行っているものとして認識してください。
* 設定変更した内容をIPCへ反映するには、![Active Configuration](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2604884747__Web.png)  のアイコンを押して  `Active Configuration` を行います。