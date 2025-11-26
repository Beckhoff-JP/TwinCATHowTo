(chapter_modbus)=
# TF6250 MODBUS TCP

[Infosys サイトリンク](https://infosys.beckhoff.com/content/1033/tf6250_tc3_modbus_tcp/192708875.html?id=8902985709589009113)

MODBUS は Modicon社（現在のシュナイダーエレクトリックの前身）が1979年に開発した産業用通信プロトコルであり、PLC（プログラマブルロジックコントローラ）などの機器間でデータをやり取りするために広く利用されています。

TwinCATではOSのTCP/IPスタックを用いて通信を行います。EtherCAT Application Protocol や EtherNet/IP のようにIPレイヤを用いた通信との違いは、**TwinCAT ネットワークインターフェースカードのリアルタイムドライバ** を用いず、TF6310 (TCP/IP)と同様にOSのネットワークスタックを経由する点にあります。

本製品は、サーバとクライアント機能の両方を包含しています。

① サーバ機能
    : OSのサービスとして機能し、指定したTCPポートをリッスンします。クライアントが接続する際、ModbusのプロトコルヘッダにあるUnit No. （局番）指定に応じたPLCモジュールに対応するADSメモリへアクセスする機能を提供します。接続先が操作パネルやそれ自体コイルやレジスタを持たない端末に対しては、IPC側がサーバとなる必要があります。

② クライアント機能
    : 外部のサーバのIPアドレス、UnitNo.（局番）、コイルまたはレジスタアドレスを指定したファンクションブロックを通じて、サーバ上のデータの読み書きを行います。接続先が異なるPLCやコントローラなど、制御主体となるコイルやレジスタを持つ端末への接続にはこの機能を用います。

![](https://infosys.beckhoff.com/content/1033/tf6250_tc3_modbus_tcp/Images/jpg/192796427__en-US__Web.jpg){align=center}

## インストールとライセンス

サーバ、クライアントどちらの機能を用いる場合も、別途TF6250をインストールしてください。

Engineering - TF6250 | TwinCAT3 Modbus TCP
    : XAEのインストールされた開発環境側にインストールします。

Runtime - TF6250 | TwinCAT3 Modbus TCP
    : IPC等のランタイム側にインストールします。

![](assets/2025-11-26-14-02-44.png){align=center}


```{toctree}
:maxdepth: 2
:caption: 目次

server
client
```
