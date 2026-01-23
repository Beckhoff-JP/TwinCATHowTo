障害発生後の対応方法
============================

BSoDに関わらず、次のログをベッコフオートメーション株式会社のアプリケーションエンジニアへ送付願います。

Windows event ログファイル置き場のフォルダごと圧縮してください

.. code-block:: powershell

    C:\Windows\System32\winevt\Logs

メモリダンプファイル。本手順書の場合は以下の場所に保存されています。

.. code-block:: powershell

    C:\MEMORY.DMP

Performance monitor のログファイル。本手順書の場合は以下のフォルダ以下に保存されています。フォルダの名称の日時からインシデント発生前後のフォルダを選択してお送りください。

.. code-block:: powershell

        D:\PerfLogs\Admin\New Data Collector Set

窓口となるアプリケーションエンジニアが不明の場合は、 support@beckhoff.co.jp までご連絡ください。

.. warning::
    本手順書で記載しているログファイルは非常にファイルサイズが大きいものとなります。メールでの添付ファイルとして送付いただく事はできません。
    WEBストレージなどご活用ください。ご不明点は上記メールアドレスへご確認ください。
