# ADSを介して変数読み書きするPowerShellスクリプト実装

[こちらのInfoSys](https://infosys.beckhoff.com/content/1033/tc3_ads_ps_tcxaemgmt/15510665739.html?id=6452251772138829586)にて、様々な方法でデータを書き込む事例が紹介されています。ここでは構造体などの複雑なデータモデルも、メモリイメージのまま一括して送る方法や、単体の変数ノードを指定して送る方法などが紹介されています。

ここでは、最もPowerShellの高次レベルでデータモデルに読み出し、PowerShell内で一旦CSVファイルに出力し、CSVで編集した値をTwinCATの変数の値へ書き戻す実装例（{numref}`function_write_value`）をご紹介します。

```{literalinclude} assets/ads_read_write.ps1
:caption: PowerShellスクリプトによるCSVを通じた変数操作サンプルコード
:language: powershell
:name: function_write_value
:linenos:
```

## このサンプルコードの使い方

1. まず{numref}`function_write_value`のスクリプトを拡張子 .ps1 としたテキストファイルとして保存し、IPC内に配置します。このとき、58行目の`-path`に続く個所を、読み書き対象の構造体変数名に書き換えます。

    ```{code} powershell
    $symbol = $session | Get-TcSymbol -path 'GVL.test_data'
    ```

2. スクリプトを実行します。`original.csv`というファイルが出来上がります。このファイルには、スクリプトを実行した時点での指定した変数ツリーの全変数パスとその値が一覧されます。
3. `original.csv`を基にして、`import.csv`という名前のCSVファイルを作成してください。このCSVを編集し、任意の変数パスの値を書き換える値に変更します。書き換えが不要な行は削除してください。
4. もう一度実行すると、`after_merge.csv`というファイルができあがります。このファイルは`import.csv`の定義内容が反映された全ての変数パスの値が一覧されます。

## サンプルコードの解説

### write-value関数

Get-TcSymbolおよびRead-TcValueにて得たシンボル、およびデータオブジェクトを通じて、データを読み書きする関数を定義します。パラメータは以下の通りです。

$ads_value
    : 書き込みたいデータオブジェクト

$symbol
    : TwinCATのシンボルオブジェクト

[ref]$dict
    : 連想配列オブジェクトの参照をセットする。空の連想配列が渡された場合、本関数を実行することで、ADSを通じて読み込まれた変数のシンボルパスと値の辞書が生成される。
    
    : また、あらかじめ変数シンボルパスと値をセットした連想配列オブジェクトの参照を渡した上でMergeDictオプションが$trueにすると、連想配列の定義内容に従いTwinCAT上の該当変数パスの値を書き換える。

[bool]$ReadOnly
    : デフォルト値 : $false
    : TwinCAT変数へは書込みを行わないオプションを有効にする
    
[bool]$MergeDict
    : デフォルト値 : $false
    : $dictの定義内容でTwinCAT変数を書き換える動作を有効にする



### ADS接続とシンボルおよびデータオブジェクトの作成

最初にADS接続セッションオブジェクトを作成します。本例ではIPC上のWindows上で実行することを前提としていますので、ローカルターゲットである`127.0.0.1.1.1`で、1台目のPLCのTcCOMであるADSポート`851`を指定します。

```{code} powershell
# ローカルPCのPLCへ接続
$session = New-TcSession -NetId '127.0.0.1.1.1' -Port 851
```

つづいてシンボルおよびデータオブジェクトを作成します。

まず、`Get-TcSymbol` にてシンボルオブジェクトを取得します。ここで読み書き対象の変数を `-path` 指定します。この例では{ref}`GVL_test_data`で実装したグローバル変数を指定します。

また、シンボルオブジェクトをパイプを通して`Read-TcValue`を実行することで、PLC変数を読みだしたデータオブジェクトを生成します。

```{code} powershell
# 読み出し
$symbol = $session | Get-TcSymbol -path 'GVL.test_data'
$data = $symbol | Read-TcValue
```

読みだしたデータオブジェクトは、下記に示すエントリポイント以下からは、TwinCAT上で構築したデータモデルそのままのモデルとしてPowerShell上で直接編集可能です。

### CSV用の連想配列オブジェクト生成

`write-value`の引数`$dict`は、参照渡しで連想配列オブジェクトを渡します。次の通り`new()`により空の連想配列オブジェクトへの参照`([ref]$result)`として引数に渡しています。

なお、ここでは変数の内容を読み取って連想配列オブジェクトを生成することが目的なので、TwinCAT変数への書き込みは行いません。したがって、`-ReadOnly $true`オプション指定とします。

```{code} powershell
# エクスポート用の連想配列
$result = [System.Collections.Generic.Dictionary[String, PSObject]]::new()
   :
write-value $data $symbol ([ref]$result) -ReadOnly $true
```

`write-value` 関数により処理された`$result`連想配列オブジェクトには、指定した構造体変数の中身のシンボルパスと値のリストが格納されています。次の行で、CSVファイルに出力します。なお、`$current_data_file_name`にあらかじめ出力したいCSVのファイル名を記述します。ディレクトリを省略していますので、スクリプト実行時のカレントディレクトリ上に指定した名前のCSVファイル `original.csv` が生成されます。

```{code} powershell
# 現在値を保存するCSVファイル名の指定
$current_data_file_name = "original.csv"
 :
$result.GetEnumerator() | Select @{N="Variable"; E={$_.Key}}, @{N="Value"; E={$_.Value}} | Export-Csv $current_data_file_name -Encoding Default -NoTypeInformation
```

### import.csvを読み込んで変数の値を上書きする

まず、`Test-Path`にて、`import.csv`があるかどうか確かめます。存在すれば、`import.csv`の定義による値の上書き処理が実行されます。

```{code} powershell
$import_file_name = "import.csv"
$after_merge_data_file_name = "after_merge.csv"

if(Test-Path $import_file_name){
    :
}
```

まず、以下の処理ブロックにて、CSVファイルを読み取り、1行づつ`Variable`という先頭行のヘッダの列をキー、`Value` という先頭行のヘッダの列を値として順次読み取り、`$import`という連想配列オブジェクトにセットします。

```{code} powershell
    # CSVファイルを読みだしてオブジェクト作成
    $import_data = Import-Csv -Path $import_file_name -Encoding Default


    # インポート用の連想配列新規作成
    $import = [System.Collections.Generic.Dictionary[String, PSObject]]::new()

    # CSVファイルから読みだしたオブジェクトを、$import連想配列に変換
    foreach($row in $import_data){
        if($import.ContainsKey($row.Variable)){
            $import[$row.Variable] = $row.Value
        }else{
            $import.add($row.Variable, $row.Value)
        }
    }
```

このあと、作成した連想配列オブジェクトを参照渡しし `write-value` を呼び出します。こんどは`-ReadOnly $true`は指定せず、代わりに`-MergeDict $true`を指定します。`-ReadOnly`はデフォルト値`$false`が指定されているので、指定しないことにより書き込みモードとしてふるまい、`$data`の内容に加えて、`$import`の連想配列オブジェクトの内容を上書きした値がTwinCAT上の変数に反映されます。

```{code} powershell
    # 連想配列のデータをマージモードでTwinCATへ書き出し
    # -ReadOnly $true を指定しないとデフォルト設定が有効となり、TwinCATへの変数書込みが実施される
    # -MergeDict $true で$importの連想配列の値を反映させる。
    write-value $data $symbol ([ref]$import) -MergeDict $true
```

その後、`$import`には、元々`$import_file_name`で定義されたリスト以外の全ての変数パスも加えられた状態で、反映後の変数パスとその値がセットされます。次の行で`after_merge.csv`という名前でそのデータが出力されます。

```{code} powershell
    # マージ後の全データをafter_merge.csvにCSVファイルとして出力
    $import.GetEnumerator() | Select @{N="Variable"; E={$_.Key}}, @{N="Value"; E={$_.Value}} | Export-Csv $after_merge_data_file_name -Encoding Default -NoTypeInformation
```
### 実行結果

* {download}`original.csv<assets/original.csv>`
* {download}`import.csv<assets/import.csv>`
* {download}`after_merge.csv<assets/after_merge.csv>`