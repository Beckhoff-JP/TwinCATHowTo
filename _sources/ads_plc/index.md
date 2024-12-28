# PLC間のADS通信

PLC間では様々な通信が可能ですが、リアルタイム性が必要なければソケット通信を用いたADS通信が汎用的に使用可能です。EAPをはじめとしたリアルタイムネットワークドライバを用いた通信方法は、CX7000などの廉価なIPCでは用いることができませんので、この通信方法を用いると便利でしょう。

.NETやPython, Javaといった言語向けには、ADS通信用のライブラリとAPIが用意されています。これらを用いるとPLCのシンボル名を指定したデータ交換が可能です。しかし、PLCにはこういったAPIは用意されていません。ADSの基本的レベルのプロトコルを用いて、データを交換する方法が取られます。

この目的で主に使われるプロトコルが以下のコマンドになります。

* [ADS Read](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115876875.html?id=4960931295000833536)
* [ADS Write](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115877899.html?id=8845698684103663373)
* [ADS Read Write](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115884043.html?id=2085949217954035635)

このコマンドでは、変数名を指定するのではなく、Index GroupやIndex Offsetという単位でTwinCAT内のリソースとそのアドレスを指定し、データの送受信を行います。

また、アプリケーション内のどの呼び出し元のサービスに対するシーケンスであるのかを判別するため、コマンド毎にAMSヘッダ部分にはInvoke IDという名前のコマンドシーケンス番号が付与されています。これにより、どのコマンドに対する要求、応答であるかを整合することができます。

```{tip}
[AMS ヘッダの構造](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/115847307.html?id=7738940192708835096)
```

このように透過的に変数データを交換するのではなく、サーバ、クライアントモデルによる、コマンドとそのレスポンスをハンドシェークする通信方法でデータを交換します。

## ファンクションブロックの使い方

これらのADSコマンドを実現するファンクションブロックは次のInfoSysで紹介されています。

[https://infosys.beckhoff.com/content/1033/tcplclib_tc2_system/30944267.html?id=3355709266095738767](https://infosys.beckhoff.com/content/1033/tcplclib_tc2_system/30944267.html?id=3355709266095738767)

ここにはサンプルコードも掲載されており、このサンプルコードでは次のシーケンス図の通りの通信を行っています。

![](assets/sequence.png){align=center}

このシーケンス図に示されている通り、大きく分けて3種類のファンクションブロックが容易されています。アスタリスクの部分は、変数読み出しコマンドである`READ`、変数書き込みコマンドである`WRITE`、読み書きコマンドである`RDWR`に置き換えたバリエーションがありますが、いずれも同じシーケンスで処理を行います。

ADS*EX
    : クライアント側のファンクションブロックです。Index Group, Index Offsetを指定して ADSREADEX 読み出し、ADSWRITEEX 書き込み、ADSRDWREX 読み書きのいずれかのコマンドを発行します。

ADS*INDEX
    : サーバ側のコマンド待ち受けファンクションブロックです。クライアントからのコマンドキューを受け取ると、`VALID`フラグがTRUEとなるので、これによりコマンド処理を受け付けます。変数への反映処理が終わったら`CLEAR`フラグをTRUEにすることで本ファンクションブロックを初期化し、新たなコマンドを受け付けられる状態にします。

ADS*RES
    : サーバ側のファンクションブロックです。`ADS*INDEX` にて正常にコマンドを受け取ったあと、クライアント側に応答を返します。このとき、Invoke IDを付与する事で、クライアント側はどのコマンドに対する応答かを判別する事ができます。



```{admonition} 10個のFIFOキュー
:class: tip

ADS*INDEXにより待ち受けするサーバには、READ / WRITE / RDWR ごとに10個のコマンドを受け付けられるFIFOキューがあります。
このバッファ容量を越えて ADSREADEX / ADSWRITEEX / ADSRDWREX がクライアントから同時に発行された場合、11個目からは1814 (0x716)のADSエラーメッセージと共にリクエストが拒否されます。
```

## Index Group, Index Offset

ADSのデバイスにはIndex Groupとその空間アドレスがマッピングされており、Index GroupとIndex offsetを指定してそのデータへの読み書きを行います。

TwinCATでは、様々なモジュールがADSでアクセスできるようになっており、それぞれにIndexGroupが割り当てられています。たとえば[PLCやNCなどのADSデバイス](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/117241867.html?id=1944752650545554679)はこのリンク先にて参照できます。また、TcCOMオブジェクトについても直接アクセスすることができます。たとえばXTSデバイスについては、下記の通り `Object Id`部分がIndex Groupに該当し、そのパラメータにアクセスするには[ここのリンクのPTCIDに記載されているアドレス](https://infosys.beckhoff.com/content/1033/xts_software/10949504139.html?id=8711231443942939909)を Index Offset とすることでそれぞれのパラメータへアクセスできます。

![](assets/2024-08-09-09-59-15.png){align=center}

こういったIndex GroupとIndex Offsetを用いてさまざまなデータへアクセスする仕組みを使うと、PLC同士の通信も可能になります。このための、ユーザが作成したPLC上のリソースへアクセスするため自由に使えるIndex Groupの領域として下記の通り16個割り当てられており、いずれかを使用することができます。

```
0x80000000 - 0x80FFFFFF
0x81000000 - 0x81FFFFFF
…
0x8E000000 – 0x8EFFFFFF
0x8F000000 – 0x8FFFFFFF
```

サーバ側は`ADS*INDEX`ファンクションブロックの`MINIDXGRP`入力変数に先頭のアドレスを指定することで、待ち受ける Index Group のセグメントを指定することができます。

````{admonition} 例
:class: tip

以下のADSREADINDEXファンクションブロックを実装した場合、0x8E000000 – 0x8EFFFFFFの Index Groupを指定したクライアントの`ADSREADEX`ファンクションブロック実行した際にデータがキューインされてVALIDフラグがTRUEとなります。

```{code-block} iecst
PROGRAM ADS_Read
VAR
    fbReadInd    : ADSREADINDEX := (MINIDXGRP := 16#8E000000);
    fbReadRes    : ADSREADRES;
    :
    nIdxGrp      : UDINT;
    nIdxOffs     : UDINT;
    :
END_VAR

fbReadRes( RESPOND := FALSE );
fbReadInd( CLEAR := FALSE );

IF fbReadInd.VALID THEN
    :
    nIdxGrp := fbReadInd.IDXGRP; 
    nIdxOffs := fbReadInd.IDXOFFS; 
    :
    CASE nIdxGrp OF 
        16#8E000001: 
            CASE nIdxOffs OF 
                :
                // 受信処理
                :
            :
            END_CASE
    END_CASE
    fbReadRes(....);
    fbReadInd( CLEAR := TRUE );
END_IF
```
````

## サンプルコード

Githubにサンプルコードを紹介しています。サーバ側をCX7000、クライアント側をC6015としたTwinCATプロジェクトをそれぞれ格納しています。

IPC同士やADSライブラリを用いた汎用プログラムとの通信が可能なADS_Read, ADS_Writeのプログラム、また、ADS通信ができない機器とのデータ交換手段として、EL6652を経由したEtherNet/IPによる通信サンプルを記述したEIPプログラムをそれぞれ格納しています。

```{admonition} Github サイト
[https://github.com/Beckhoff-JP/CX7000_M2M_Communication_Sample.git](https://github.com/Beckhoff-JP/CX7000_M2M_Communication_Sample.git)
```

```{admonition} クライアントのIPCからサーバIPCへのADSの事前接続が必要です

PLC同士でADS通信を行う場合、クライアントIPCにおいてサーバIPCに対するADS接続の設定を事前に行ってください。

![](assets/2024-08-09-11-24-20.png){align=center}
```