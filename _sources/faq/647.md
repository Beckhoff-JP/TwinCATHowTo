# TwinCATと外部機器と通信するにはどんな方法がありますか？


1. 各種Ethernetベースのフィールドバス

    TwinCATに各種フィールドバスの通信機能ライセンスを追加し、 さまざまなフィールドバスプロトコル経由でPLCの変数を送受信できます。たとえばModbusは仕様上、それぞれ256個のBool変数の入出力、それぞれ256個のWord変数の入出力です。

    * [TF6250 | TwinCAT 3 Modbus TCP](https://www.beckhoff.com/ja-jp/products/automation/twincat/tfxxxx-twincat-3-functions/tf6xxx-tc3-connectivity/tf6250.html) 

        IPCのイーサネットポートを使用してModbus TCPの通信が可能です。
        [技術情報](https://infosys.beckhoff.com/content/1033/tf6250_tc3_modbus_tcp/192708875.html)


    * [TF6270 | TwinCAT 3 PROFINET RT Device](https://www.beckhoff.com/ja-jp/products/automation/twincat/tfxxxx-twincat-3-functions/tf6xxx-tc3-connectivity/tf6270.html) 

        PROFINET RTのスレーブ化、最大入出力データサイズ=1kbyte [技術情報](https://infosys.beckhoff.com/content/1033/tf6270_tc3_profinet_rt_device/9253279883.html)  

    * [TF6280 | TwinCAT 3 EtherNet/IP Adapter](https://www.beckhoff.com/ja-jp/products/automation/twincat/tfxxxx-twincat-3-functions/tf6xxx-tc3-connectivity/tf6280.html)

        EtherNET/IPのスレーブ（アダプター）化、最大入出力データサイズ=1kbyte [技術情報](https://infosys.beckhoff.com/content/1033/tf6280_tc3_ethernetipslave/2554564235.html)

2. EtherCATブリッジ（各種Ethernetベースのフィールドバスカプラ）  

    EtherCATのスレーブ機器として、以下のフィールドバスの通信を実現するカプラを用意しています。  
    EL663x: Profinet rt  
    EL665x: Ethernet/IP

3. シリアル通信ベースのプロトコル  

    * [TF6255 | TwinCAT 3 Modbus RTU](https://www.beckhoff.com/ja-jp/products/automation/twincat/tfxxxx-twincat-3-functions/tf6xxx-tc3-connectivity/tf6255.html) 

        IPCにシリアルポートがある、またはEtherCATスレーブとしてEL60xxのシリアルポートデバイスを追加してModbus RTUの通信が可能です。Modbus通信は他のマスター・スレーブとは異なり、PLCプログラムで通信を行います。技術情報およびPLCでModbus通信に使用するFunction Blockは下記ページをご覧ください。
        [技術情報](https://infosys.beckhoff.com/content/1033/tf6255_tc3_modbus_rtu/186519307.html)

4. ADS通信  
    ソフトウェアコストを掛けずプログラミングでPLC内の変数にアクセスする方法として、.NETやVC++などの外部プログラムでベッコフ独自のADS通信があります。 
    TwinCATにADS通信のライブラリが付属し、ADS機能は無償です。 ADSはライセンス費用はかかりません。TC1000 TwinCAT 3 ADSはダウンロードエリアから入手して無償で使用できます。 

    [技術情報](https://infosys.beckhoff.com/content/1033/tc3_ads_intro/116158859.html) 

    特に最大データサイズはありませんが、1kbyte程度の構造体をPLCとADSクライアントアプリ上で定義してそれを送受信すれば1つのメッセージになって効率が上がります。 技術情報に.NETやVC++などのサンプルプログラムがあります。

5. OPC-UA  
    TwinCATにOPC-UAサーバー機能を追加し、PLCの変数のうち外部にOPC-UA経由で公開する変数を設定できます。全世界的にはこの方法が主流になっていきます。 こちらも製品と技術情報ページのみお知らせします。 [技術情報](https://infosys.beckhoff.com/content/1033/tf6100_tc3_opcua/78651275.html)

    * [TF6100 | TwinCAT 3 OPC UA](https://www.beckhoff.com/ja-jp/products/automation/twincat/tfxxxx-twincat-3-functions/tf6xxx-tc3-connectivity/tf6100.html) 

6. 生のソケット通信  
    Ethernetを使ってTCP/UDPソケット通信機能をお使い頂く事が可能です。5層（セッション層）以上においてオリジナルのプロトコルで通信する場合にご利用ください。よって内部変数やメモリアドレスを指定して通信するのではなく、相互に通信路確立（オープン）や、データ送信、受信などのプログラムを実装する必要があります。
    ソケット通信を行うためのTwinCAT側の実装には、TF6310とTF6311の二つの製品があります。その違いは、TF6310がADSを通じてWindows側でWinSockを用いて通信しているのに対して、TF6311 がTcCOMリアルタイムタスクでソケット通信している点が異なります。TF6311はWindowsのファイヤウォール機能を使う事ができませんから、隔離されていないネットワークでお使いの場合は、TF6310をご利用いただくことをお勧めします。
    * [TF6310 技術情報](https://infosys.beckhoff.com/content/1033/tf6310_tc3_tcpip/index.html?id=9025637582166106076)
    * [TF6311 技術情報](https://infosys.beckhoff.com/content/1033/tf6311_tc3_tcpudp/index.html?id=9004581143610845071)
    * [TF6310とTF6311の違い](https://infosys.beckhoff.com/content/1033/tf6310_tc3_tcpip/1110279947.html?id=6495056259335778619)
