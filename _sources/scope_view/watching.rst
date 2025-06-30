監視
========

これまでの設定を行うことで、監視できる状態になりました。実際に監視を行うためには、次の操作を行います。

CSV収集の開始と終了
---------------------

CSVの収集を開始するには、次の手順を実施してください。

1. PLCへのログイン

   TwinCAT Measurement プロジェクトと同じソリューションにあるPLCプロジェクトにおいてリモートPLCへログインします。

2. TwinCAT Measurement Projectの選択

   Visual studioの Solution explorer 上で TwinCAT Measurement Project のどの階層でもよいので選択します。

3. Scope viewのモニタ開始操作

   TwinCAT Measurement Projectの選択を選択すると、ツールバーにScope viewの操作アイコンが現れます。「モニタ開始ボタン」操作を行うと監視を開始します。 ``StartRecord`` トリガにより自動的に記録を開始し、以後、 ``CSVExport`` トリガ毎にCSVファイルを出力します。

   .. figure:: image/scope_monitor_start.png
     :width: 100px
     :align: center

4. Scope viewのモニタ停止操作

   Scope viewに記録中においても、次の操作を行う事で操作を停止できます。

   .. figure:: image/scope_monitor_stop.png
     :align: center
     :width: 100px

   .. warning::

    * 停止後、次回モニタを再開するとCSVのファイル名の連番は ``1`` からはじまります。前回のCSVファイルが残っている場合は順次上書きされます。
    * 再開前にCSVファイルのバックアップを取ることをおすすめします。

サンプルプログラムを用いたCSV自動出力
--------------------------------------------

サンプルプログラムでは、次のフローで動作しています。

.. blockdiag::
   :desctable:

    blockdiag {
        A [label="100mm前進"];
        B [label="1秒待機"];
        C [label="100mm後進"];
        D [label="1秒待機"];

        A -> B -> C -> D -> A;

    }

:ref:`section_plc_trigger` に示したPLCプログラムでは、100mm後進動作が完了後の inposition 信号を export_trigger[0] として出力しました。

これを DataPool に登録したものとします。ここでは、つぎの条件でCSVファイルを出力する様に設定してみます。

* 上記のシーケンスを開始したところからScope viewのモニタを開始する。
* export_trigger[0] の立下り条件（つまり、100mm前進動作を開始したタイミング）でCSVを保存する。

このために必要な Channel trigger setは以下の通りです。

:``StartRecord`` に追加したchannel trigger:

   :Release:

     Raising Edge

   :Threshold:

     1

   :User Data:

     論理軸の ``AxisState``

   :説明:

     AxisStateは、軸の動作状態を整数で表現している。1以上で動作開始していることがわかる。

:``CSVExport`` に追加したchannel trigger:

   :Release:

     Falling Edge

   :Threshold:

     1

   :User Data:

     export_trigger[0]

   :説明:

     export_trigger[0] は原点位置における inPosition 信号。動作を開始するとFailとなるため、Falling Edgeにてトリガが発行される。

上記設定にて記録したものは、 :numref:`sampling_view` の通りScope viewで一覧できる。この中に示された、 ``CSVExport_*`` というラベルの部分にてCSVに保存されている事がわかる。

.. figure:: image/sampling_view.png
    :scale: 80%
    :align: center
    :name: sampling_view

    CSVへ出力中のScope view

CSVファイルは指定のフォルダへ対応する番号をファイル名に含んだ、 ``Export *.csv`` という名前で順次保存されている。