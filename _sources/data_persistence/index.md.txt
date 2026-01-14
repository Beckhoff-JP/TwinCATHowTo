(chapter_data_persistance)=
# データ永続化

TwinCATには、データを永続化する方法にPERSISTENT変数と、RETAIN変数の二つが用意されています。それぞれ次のとおり機能します。

PERSISTENT変数
    : システムのシャットダウン時、または、明示的なファンクションブロックの指令によってファイルに永続化される変数。システムを再起動しても次回RUN時に値が保持される。
    突然の電源断ではシャットダウンシーケンスが行われないため、ファンクションブロックによる永続化操作が必要となる。よってUPSの設置と、UPSからの一次電源ダウンの通知を受けてファンクションブロックによる永続化指令が必要となる。

REATIN変数
    : NovRAMと呼ばれる不揮発性メモリ内にリアルタイムに保持される変数。常に不揮発メモリに書込みが行われるため、突然の電源断が発生した場合でも保存される。ただし、NovRAMを搭載可能な機種、および、NovRAMを別途オプション設置する必要がある。

という永続化の為の仕組みが用意されています。一般的にはNovRAMが搭載できるIPCは、CX70xx, CX9020, CX20x0, CX20x2, CX20x3に限られることからも、NovRAMが搭載できるIPCに限定された機能です。これ以外は、{ref}`figure_persistent_value_with_ups` 節に示す方法でPersistent属性の変数により永続化させる必要があります。

また、変数の値のリセット方法には次の2とおりの方式があり、{numref}`reset_button`の通りそれぞれのボタンにより操作できます。

```{figure-md} reset_button
![](assets/2023-06-21-22-15-20.png)

TwinCATのリセットボタン
```

RESET COLD
    : 保持変数以外をリセットする。
    ただし、PERSISTENT変数においても、[`{attribute 'TcInitOnReset'}`](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/6884430859.html?id=8285217895000565468) という属性を付けた変数は、部分的に値を初期化することができる。

RESET ORIGIN
    : 保持変数も含めてリセットする。

[このサイト](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2528803467.html?id=8585993057536408461)に記載されている通り、プログラムに与える各アクションに対する、変数が受ける影響については以下の通りとなります。

```{csv-table}
:header: アクション, VAR, VAR REATIN, VAR PERSISTENT

RESET COLD操作, 初期化される, 保持される, 保持される
RESET ORIGIN操作, 初期化される, 初期化される, 初期化される
ダウンロード(Build/Active configulation), 初期化される, 保持される, 保持される
オンライン変更(プログラム変更付きLogin),  保持される, 保持される, 保持される
```


```{toctree}
:caption: 目次

ups
sups_cx51x0
```

```{youtube} aJ8DqD4CRug
:align: center

Persistentデータの使い方（YouTube）
```