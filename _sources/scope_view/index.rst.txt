.. BAJP education diary documentation master file, created by
   sphinx-quickstart on Tue Aug  2 09:22:17 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Scope view
================================================

TwinCAT上で制御するモーションデバイスの稼働状態を監視するには、Scope viewというソフトウェアが必要です。
このソフトウェアでは、モーションに対する様々なデータの時系列データを可視化し、様々な分析を行うことができます。

.. figure:: image/TE1300_OPCUA_scope_view.jpg
    :align: center
    :scale: 70%

    TE1300 Scope viewの画面

このソフトウェアで可視化するために収集したデータは、CSVなどの汎用的なファイル形式にエクスポートすることができます。また、PLC、NC、CNCなどのモーションデバイスのメモリ条件 [#f1]_ によって自動的にCSVファイルへ出力することもできます。
本書ではその方法について示します。

.. [#f1] トリガ条件といいます。

.. toctree::
   :caption: 目次

   introduction
   scope_view
   trigger_export
   watching
   control_by_functionblock.md
