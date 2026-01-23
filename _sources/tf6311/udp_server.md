# ダミーサーバの実装

今回、TwinCATのUDP通信のクライアントソフトを評価するため、ダミーのUDPサーバを実装します。どの言語でも構いませんが、Python上でasyncioフレームワークを使った方法が最も簡単です。このスクリプトを動作させるWindowsコンピュータ上では、ポート9998のUDPの受信を許可するようにファイヤウォール設定を行う必要があります。

* UDPサーバは、ポート9998番にメッセージを受信したら、{numref}`receive_data_format` に従いそれぞれの値を変数にマップします。
* 受信後は、送り主のIPアドレスとポートに対して{numref}`reply_data_format`のメッセージを応答します。

   ```{csv-table} Pythonのダミーサーバへの送信データ
   :header: 先頭バイト数, Python側型指定, TwinCAT型指定, サイズ, 送信データ
   :name: receive_data_format

   0, 5Byteの文字列, STRING(4), 5Byte, 'SCOM' に続き、NULL文字を1byte合計5Byteを送る。
   4, unsigned short, UINT, 2Byte, PLC側のカウンタ値。
   6, long long int, ULINT, 8Byte, 16#FFFFFFFFFFFFFFFF 固定値
   ```

   ```{csv-table} Pythonのダミーサーバからの応答データ
   :header: 先頭バイト数, Python側型指定, TwinCAT型指定, サイズ, 送信データ
   :name: reply_data_format

   0, 5Byteの文字列, STRING(4), 5Byte, 'RCOM' に続き、NULL文字を1byte合計5Byteを送る。
   4, unsigned short, UINT, 2Byte, サーバ側のカウンタ値。
   6, float, REAL, 4Byte, PLC側のカウンタ値
   ```

```{literalinclude} assets/udp_serve.py
:caption: UDPサーバの実装
:language: python
:linenos:
```
