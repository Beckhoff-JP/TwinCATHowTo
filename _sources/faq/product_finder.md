# このIPCはどのOSが使えますか？またどのTF****が使えますか？

TwinCATの追加機能ミドルウェアは、TF**** という名前でライセンス販売されています。ただし、どのIPCでも利用できる訳ではありません。使われるオペレーティングシステム、アーキテクチャ、および、Product Platform Level（プラットフォームレベル）によって決まります。これらの互換性の確認手順を以下の通りご説明します。

## 購入前の場合

### プラットフォームレベルの調べ方

購入しようとされる製品ページの Product Information の Technical data タブの "TwinCAT 3 platform level" 欄ご確認ください。

また、一つのIPCでも、複数種類のプラットフォームレベルを用意している型番があります。この場合は、Product Informationの Option タブを開くと、選択可能なプロセッサ毎に命名された型番と、そのプラットフォームレベルが一覧されます。

```{tip}

例：[C6025の場合](https://www.beckhoff.com/ja-jp/products/ipc/pcs/c60xx-ultra-compact-industrial-pcs/c6025-0000.html)、プラットフォームレベルは選択されたCPUに応じて50または60で変化します。

![](assets/2024-08-05-15-02-30.png){align=center}
```

### 対応OSの調べ方

購入しようとされる製品ページのProduct Informationの Option タブを開きます。最下部までスクロールした表の枠外に、Operating systems欄が現れます。こちらに掲載されているリンク先に選択可能なOSの型番が一覧されています。前節のプラットフォームレベルを調べていただいた際に選択したCPUにより異なる型番が設定されていますので、最適なものを選定してください。

```{tip}

例：[C6025の場合](https://www.beckhoff.com/ja-jp/products/ipc/pcs/c60xx-ultra-compact-industrial-pcs/c6025-0000.html)の場合、以下の通り記載されています。詳細は各OSのリンクをクリックしてください。

Operating systems [Windows 10 IoT Enterprise 2019 LTSC](https://www.beckhoff.com/windows10-2019) and [2021 LTSC](https://www.beckhoff.com/windows10), and [TwinCAT/BSD](https://www.beckhoff.com/twincat-bsd)

```

## 購入後のIPCのプラットフォームレベルの調べ方

`System` - `License` - `Order information(Runtime)` - `Platform` を確認します。例えば、CX7000シリーズのプラットフォームレベルは10であることが分かります。

![](assets/2024-08-05-14-30-22.png){align=center}

## 対応するTF製品の調べ方

TF製品検索ページ [Product finder](https://www.beckhoff.com/ja-jp/products/automation/product-finder-twincat/) の表の先頭行のフィルタ設定アイコンをクリックし、対応するアーキテクチャ、OS、プラットフォームレベルを選択し、フィルタして適応可能なTF製品をご確認ください。

[https://www.beckhoff.com/ja-jp/products/automation/product-finder-twincat/](https://www.beckhoff.com/ja-jp/products/automation/product-finder-twincat/)

![](assets/2024-08-05-14-39-36.png){align=center}
