# TwinCATプロジェクトの設定準備

TwinCATプロジェクトの設定ファイルである `tsproj` ファイルには開発環境の設定データも含む多くのプロジェクトデータが格納されています。概ね次の種類のデータが格納されます。

開発環境の設定データとシステム関連データ
    : システム設定（タスク、Real time）、接続先のターゲットなどの開発環境設定データ。

設計データ
    : プログラム構成、モーション設定ファイル、IO設定ファイル、リンク情報など

このデータは開発者の開発環境の運用に変化します。このため、Git等を用いてチームで開発する場合、このファイルのマージにおいて競合エラーにつながることがあります。

このため、上記の種類ごとに個別に分離しておくことをお勧めします。これによってマージの際に厳格に差分を管理するのは設計データに集中しておき、開発環境の設定データはオリジナルを優先する、といった管理が可能になります。

```{tip}
{bdg-link-info}`参考Infosys <https://infosys.beckhoff.com/content/1033/tc3_sourcecontrol/767894795.html?id=9000520481371853523>`

```

## tsprojファイルの定義から設計データを独立させる

### 準備

次の設定により `tsproj` データから「設計データ」を除外して独立した定義ファイル化することが可能です。

1. TwinCAT の開発環境のメニューから `Tools` > `Options..` を開きます。
2. Optionsのツリーメニューから `TwinCAT` > `XAE Environment` > `File settings` を選択

この箇所に設定があります。

この設定項目のトップには、まず、`Enable Multipe Project Files` があり、これをTrueに設定してください。続いて、独立させたい各項目について選択的に`True`を設定すると独立させることが可能になります。対応するプロジェクトツリーの関係を示した図を {numref}`figure_enable_separate_files` に示します。

```{figure} assets/separate_files.png
:aign: center
:name: figure_enable_separate_files

定義ファイルの独立の有効設定と対応する項目
```

```{note}
この設定変更を有効にするには、いちどXAEを終了し、再度プロジェクトを読み直す必要があります。
```

```{warning}
この設定により次の効果が現れます。

* {numref}`figure_enable_separate_files` に示すプロジェクトツリーの各項目についてこれまでに作成したものについてtsprojファイルから自動的に分離する訳ではありません。次節の手順を行ってください。
* 新規に作成したリソースに対しては独立した設定ファイルとなります。
```

### 各設定ファイルの独立

{numref}`figure_enable_separate_files` に示すソリューションツリー上の該当項目を右クリックして現れるコンテキストメニューには、下部に `Independent Project File` という項目があります。これを選択することで {numref}`figure_separate_files_operation` に示す赤枠のようにメニュー表示が切り替わり、 `tsproj` ファイルの該当項目が `_Config` ディレクトリ以下の `xti` ファイルとして分離独立します。

また、ソリューションエクスプローラ上の該当項目がフロッピーディスクのイラストでオーバレイされたアイコンとなります。分離設定となっているか否かは、このオーバレイアイコンとなっている点と、 {numref}`figure_separate_files_operation` に示す赤枠のメニューになっているかどうかで見分けてください。

```{figure} assets/separate_files_operation.png
:align: center
:name: figure_separate_files_operation

設定項目の分離操作
```

このあと再度このメニューを選択すると `tsproj` ファイルへ再度統合化を行います。つまりこのメニューを選択するたびに、`xti`ファイルへ分離、再統合をトグルで繰り返します。

これらを設定する前と後で比較したものが　{numref}`figure_separate_files_diff` です。tsprojファイルの内容は、実際はXML形式のテキストファイルですが、TwinCATの差分ビューワを通すとプロジェクトツリー形式で表示されます。このツリーが2ペインで変更前後で比較表示されています。変更後の`tsproj`ファイルからは、独立設定した定義項目が消滅し、代わりに`xti`ファイルが定義されていることが分かるでしょう。また、プロジェクトツリーには、独立して新規に生成された `xti` 定義ファイルが追加マーク（A）で一覧され、TwinCATプロジェクトフォルダ内の `_Config` フォルダ以下に各々のサブプロジェクト名ごとに保存されていることがわかります。

```{figure} assets/separate_files_diff.png
:align: center
:name: figure_separate_files_diff

設定ファイル独立前後の比較
```

