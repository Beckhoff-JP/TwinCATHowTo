# PLCプロジェクトの作成と変数とIOのリンク

## PLCプロジェクトの作成

````{grid} 2
```{grid-item} 
:columns: 4
PLCプロジェクトを追加します。
```
```{grid-item}
:columns: 8
![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2602432011__en-US__Web.png)
```
```{grid-item} 
:columns: 4
PLCプロジェクトの名称設定を行います。
```
```{grid-item}
:columns: 8
![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2605574539__en-US__Web.png)
```
````

## 変数宣言とIOとのリンク

PLCプロジェクトがソリューションツリーのTwinCATプロジェクト以下の `PLC` に作成されます。デフォルトで、`POUs` 以下には `MAIN` プログラムが生成されています。

![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2605578507__en-US__Web.png)

このプログラムの、変数宣言部 `VAR ～ ENV_VAR` ブロック内に、様々な変数を宣言します。以下の書式となります。

```{code} iecst
変数名  : 型名 := 初期値; // 変数コメント
```

初期値を定義するか否かは任意です。不要であれば下記のとおりシンプルに変数名と型名だけ定義してください。

```{code} iecst
変数名  : 型名; // 変数コメント
```

```{tip}
どのようなデータ型があるかは、下記のInfoSysをご参照ください。

[InfoSys : Data types](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2529388939.html?id=3451082169760117126)
```

また、入力変数は`AT%I*` 、出力変数は `AT%Q*` タグを追加しておきます。

```{code} iecst
入力変数名  AT%I* : 型名 := 初期値; // 変数コメント
出力変数名　AT%Q* : 型名 := 初期値; // 変数コメント
```

![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2605583627__en-US__Web.png){align=center}

例にはプログラム部にもロジックを記述していますが、IOとLinkするだけであれば変数宣言だけでも構いません。このプログラムを書いたら、ビルドを行います。すると、PLCプロジェクトの下部に入出力変数のインスタンスが現れます。

````{grid} 2
```{grid-item}
![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2605869195__en-US__Web.png){align=center}
```
```{grid-item}
![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2605879819__en-US__Web.png){align=center}
```
````

この変数インスタンスを右クリックして現れるコンテキストメニューの先頭にある、`Change Link...` を選択すると、EtherCATのツリー以下にある同じデータ型のIOアドレスが一覧されます。任意のIOを選択してOKボタンを押すとリンクが完成です。

````{grid} 2
```{grid-item}
![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2606528139__en-US__Web.png)
```
```{grid-item}
![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2606532107__en-US__Web.png){align=center}
```
````

EL2008などは、8bitの連続したアドレスとなっています。例にあげた `nEL2008_value` は `BYTE` 型の変数ですので、`All Types` にチェックを入れることで `BYTE` 型以外のIOも一覧され、EL2008の先頭BITを選択後、SHIFTを押しながら最終BITをクリックすると全BIT選択できますので、`Continuous` にチェックを入れてリンクを行うと、全 bit 順次連続的にリンクを行います。1bitづつリンク操作を行うより省力可能です。

![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2606817675__en-US__Web.png)

## IPCへの反映と試運転

全てのリンクが完了したらこれまでの設定内容をIPCへ反映し、RUNモードへ移行します。 `Active Configuration` アイコン ![Active Configuration](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2604884747__Web.png) を押してください。

しばらくすると次の操作を求められます。

1. ライセンスが発行されていない場合、7日間のトライアルライセンスを発行を促されます。YESボタンを押して、表示されたランダムな文字列を入力するとトライアルライセンスが発行されます。
2. RUNモードに移行しますか？というダイアログウィンドウが現れますので、YESを押してください。

しばらくすると反映が終了し、![Run mode](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2604625547__Web.png) のアイコンがアクティブとなり、RUNモードへ移行します。

PLCのスタートとモニタ

    : RUNモードで ![PLC Login](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2607543051__Web.png) ボタンを押すとPLCのモニタモードへ移行します。 ![PLC Start](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2607578251__Web.png) ボタンを押すと、PLCがスタートします。PLCスタート中は、![PLC Stop](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2607575051__Web.png) アイコンが現れているので、これを押すとPLCがSTOPします。PLCのプログラムを修正するには、![PLC Logout](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/png/2607571851__Web.png) アイコンを押してログアウトするとモニタモードを抜けてプログラム編集可能な状態になります。

    : モニタ中に変数を強制的に値変更する操作する様子を以下の動画でご紹介します。

    : ```{figure} ../plc_object_oriented_programming/assets/twincat_ope.webm
      :class: controls
      :width: 100%

      ログイン、モニタ、変数の値書き込み操作
      ```