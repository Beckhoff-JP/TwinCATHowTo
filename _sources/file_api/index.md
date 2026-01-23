(section_file)=
# TwinCAT PLC からファイルアクセス

ファイルアクセスは非常に低速です。しかし大量のデータを読み取り、書き込みすることができます。このため、次の点に注意する必要があります。

* ディスクアクセスの遅延により全てのデータを読み込むにはサイクル遅延が生じます。
* ADSルータメモリを超えるファイルデータを一度に読む事はできません。
* ADSルータメモリを増やした場合においても、1時的に大量のデータを受け渡す事により、非常に大きなレイテンシにつながる恐れがあります。


よって、ファイルアクセスを行う際は、その読み書き速度に期待しないことを前提としてください。[InfoSysの各APIの先頭にも注意書きとして記載されて](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_system/30977547.html?id=4702287923023522286)いるとおり、高速に大量のデータを記録する場合、TF3500のご利用を強く推奨いたします。

ここでは、低速でも問題ない場合を前提として、ADSルータメモリに負担をかけない程度に、分割してファイルから読み取りを行う事例についてご紹介します。

## 基本的なファイルアクセス手順

ファイルからデータを横んで変数にデータを格納するには、

1. [`FB＿FileOpen`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_system/30977547.html?id=4702287923023522286)でファイルを開き
2. [`FB_FileRead`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_system/30980619.html?id=5534719005648537303)でそのデータを読み取って変数に展開し
3. 最後に [`FB_FileClose`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_system/30972939.html?id=1997985466515001449)でファイルを閉じる

という手順を行います。

書込みの場合は`FB_FileRead`が [`FB_FileWrite`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_system/30986763.html?id=8084078722597421664) に代わるだけですが、追加して書き込むのか、ファイルの先頭から上書きするのか、など`FB_FileOpen`でオープンする際のモード指定により振る舞いを切り替えられます。

ただ、その後も現在読み込んだり、書き込んだりしているファイル上の位置を「ファイルポインタ」と呼びますが、このファイルポインタは、[`FB_FileSeek`](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_system/30983691.html?id=8233380726918996109)により任意の位置へ移動することが可能です。

これによりファイルオープンしてからクローズするまで次のような一連のファイル操作が完結できます。

1. `FB_FileRead`でファイルの全てをPLC変数に読み出す。この時点でファイルポインタは末端に達している。
2. 読み出したPLC上の変数で修正したいデータ個所を検索し、先頭からのバイトアドレスを特定する。
3. `FB_FileSeek`で特定した修正したいバイトアドレスを示してファイルポインタを移動し、
4. `FB_FileWrite`で書き換えたいデータを書き込む

といったことが可能になります。

## 大きなサイズのデータの読み書き

冒頭で示すとおり、ファイルと変数との間のデータやりとりにはADSが使われます。ADSのルータメモリサイズによっては、サイズの大きなファイルは一度で開くことはできません。ADSルータメモリを増やす方法もありますが、読み込むファイルの大きさにより常駐するメモリ容量を都度見直す運用はスマートとは言えません。

解決方法として、全てのデータを一度で読むのではなく、サイズを指定してすこしつづ（ **セグメントを分けて** ）呼び出す方法を行います。

先ほど示した例のとおり、`FB_FileRead`でデータを読み込むと、それだけファイルポインタが移動し、どこまで読んだのかを保持できるようになっています。

`FB_FileRead`の入力変数には`cbReadLen`という読み込むデータサイズを指定することが可能となっていますので、ここに適切なサイズを指定することで、ADS通信に負荷をかけずデータを読み込むことが可能となります。

サイクルを跨ぐごとに、読み込み先の変数のポインタも、すでに読み終わったデータバイト数をオフセットした上で継ぎ足しで書き込む事で、トータルでファイル全体のデータを変数上にロードすることが可能となっています。そのサンプルプログラムをご紹介します。

まずは、格納先の変数について準備します。10KByteのバイト配列の変数を作りますが、STRING型を含みますので最後のNULL文字を格納することを考慮し、10239 Byte 格納できるSTRING型とBYTE配列型のUNIONを定義します。UNIONにする理由は実験的に格納されたデータが様々な形式でモニタする際に役立つからであって、必ずしもUNIONにする必要はありません。ファイル内容によって直接BYTE型やSTRING型に書き出してください。

```{code-block} iecst
TYPE file_buffer :
UNION
   b_data : ARRAY [0..10238] OF BYTE;
   s_data : STRING(10239);
END_UNION
END_TYPE
```

プログラムは以下のとおりです。ステップ1でファイルオープンし、ステップ2で読み込み、ステップ3でファイルクローズです。ステップ2では、`seg_size`ごとに小分けでデータを読み出し、先ほどUNIONで定義した`_data`上に並べていきます。

`_data` のサイズは10kByteですが、ファイルの大きさがそれよりも十分に小さい場合、ファイルの末端まで読み進めると、`bEOF` がTRUEとなりますので、これを基にファイルを閉じるステップへ進めています。

また、`_data` のサイズよりもおおきなサイズのファイルを読み込んだ（`cb_data`）場合、強制的に読み込みを終了してファイルを閉じるステップへ進めています。

何分割して読み込んだかは、`num_of_packet` 変数に記録しています。

```{code-block} iecst
PROGRAM MAIN
VAR
   f_open : FB_FileOpen;
   f_read : FB_FileRead;
   f_close : FB_FileClose;
   _start : BOOL;
   _data  : file_buffer;      // 読み出したデータを格納する変数。BYTE配列とSTRINGのUNION
   p_data : PVOID;            // _dataへ記録する際の先頭ポインタ
   seg_size : UDINT := 512;   // ファイルから何バイト毎に分割して読み取るか（セグメントサイズ）
   cb_data : UDINT;           // トータルで読み込んだデータサイズ
   _open	: BOOL;
   _state : UDINT;
   _num_of_packet : UDINT;
   num_of_packet : UDINT;     // 何分割して読み出したかの回数記録
END_VAR


CASE _state OF
   0:
      f_open(bExecute := FALSE);
      f_read(bExecute := FALSE);
      f_close(bExecute := FALSE);
      _num_of_packet := 1;
      IF _start THEN
         _state := 1;
      END_IF
   1:
      f_open(
         sPathName := 'C:\temp\scope.csv',
         nMode := FOPEN_MODETEXT OR FOPEN_MODEREAD,
         ePath := E_OpenPath.PATH_GENERIC,
         bExecute := TRUE
      );
      IF NOT f_open.bBusy AND NOT f_open.bError THEN
         f_open(bExecute := FALSE);
         p_data := ADR(_data); // p_dataの初期値を設定
         IF SIZEOF(_data) < seg_size THEN
            // セグメントサイズが保存先の変数のサイズより大きい場合は変数サイズに強制
            seg_size := SIZEOF(_data);
         END_IF
         _state := 2;
      END_IF
   2:
      f_read(
         hFile := f_open.hFile,
         pReadBuff := p_data,
         cbReadLen := seg_size,
         bExecute := TRUE			
      );
      
      IF NOT f_read.bBusy AND NOT f_read.bError THEN
         f_read(bExecute := FALSE);
         p_data := p_data + f_read.cbReadLen;
         cb_data := TO_UDINT(p_data - ADR(_data));
         IF f_read.bEOF OR SIZEOF(_data) <= cb_data THEN
            // ファイルの終端に達するか、格納先変数のサイズを越えると強制終了
            MEMSET(p_data - 1, 0, 1); // 文字列なので最終バイトにnullをセット
            num_of_packet := _num_of_packet;
            _state := 3;
         ELSE
            _num_of_packet := _num_of_packet + 1;
         END_IF
      END_IF
   3:
      f_close(bExecute := TRUE,
         hFile := f_open.hFile);
      IF NOT f_close.bBusy  AND NOT f_close.bError THEN
         f_close(bExecute := FALSE);
         _state := 0;
      END_IF
END_CASE
```