Scope viewプロジェクト新規設定
==============================================

最初に、同一ソリューション上にScope viewプロジェクトを新規作成します。

Scope viewプロジェクトの新規作成
--------------------------------

まず、次の手順で既存のPLCプロジェクトにおいて、Scope viewプロジェクトを新規に追加します。

1. Solution explorerの最上位階層で右クリックし、ポップアップメニューから、 ``Add > New Project...`` を選択します。

   .. image:: image/add_project.png
    :width: 600px
    :align: center

2. YT Scope view プロジェクトを選択します。下部の ``Name`` 欄には、監視したいスコーププロジェクト名称を設定します。

   .. image:: image/add_YT_Scope_project.png
    :width: 500px
    :align: center

3. Solution explorerに、初期状態のツリーが現れます。

   .. image:: image/initial_scope_view_tree.png
    :width: 200px
    :align: center


.. _section_measurement_project_property:

プロジェクトルートフォルダの確認
---------------------------------

プロジェクトのルートフォルダがどこにあるのかを確認しておきます。デフォルト設定のままでCSVファイルが保存される先は、ここで確認するプロジェクトフォルダ以下となります。

1. ``Measurement project`` のツリーを右クリックして ``Property`` を選択します。（ :numref:`measurement_project_property` ）
2. Propertyウィンドウに現れる ``Project folder`` CSVを保存する先にデフォルトで使用される保存先はこのプロジェクトフォルダです。（ :numref:`project_folder_setting` ）

.. figure:: image/measurement_project_property.png
    :width: 550px
    :align: center
    :name: measurement_project_property

    Measurement projectのプロパティ

.. figure:: image/project_folder_setting.png
    :width: 550px
    :align: center
    :name: project_folder_setting

    Projectフォルダの場所の設定個所


YT Scopeプロジェクトの設定
---------------------------------

CSVファイルへ吐き出す前に、記録したデータはYT Scopeのバッファメモリ内に保存されます。このメモリの取り扱いに関する設定を変更します。

.. figure:: image/ytscope_project_property.png
    :width: 550px
    :align: center
    :name: ytscope_project_property

    YT scope projectのプロパティ

.. figure:: image/buffer_setting.png
    :width: 400px
    :align: center
    :name: buffer_setting

    バッファ設定の変更個所

.. csv-table::
    :header: 項目, 変更前, 変更後, 説明
    :widths: 3,1,2,4

    ``Record`` / ``Ringbuffer``, False, True, False設定のままだと後述の ``Record Time`` 設定時間が経過すると自動的に記録が停止します。Trueにすることで、 ``Record Time`` を過ぎても古いデータから順次消去する動作となります。
    ``Record Mode`` / ``Record Time``, ``00:00:10:00`` （10分）, 軸の動作を監視する制御サイクルの間隔の1.5倍以上の時間, バッファする記録時間を設定します。リングバッファにより古いものから順次消去されるため、CSVファイルへ記録するまでに十分なデータが残っているための時間設定が必要です。


変数登録とビュー作成
==========================

.. _section_plc_trigger:

CSV保存条件プログラム作成
------------------------------------------

PLCにより、CSVへ出力するトリガとなるフラグ ``export_trigger`` を制御するプログラムを紹介します。

.. code-block:: iecst

    VAR
        axes            :ARRAY [0..2] OF AXIS_REF;
        export_trigger  :ARRAY [0..2] OF BOOL;
        i               :UINT;
    END_VAR

    // Trigger for csv saving
    FOR i := 0 TO 2 DO
        IF axes[i].Status.InTargetPosition AND axes[i].NcToPlc.SetPos = 0 THEN;
            export_trigger[i] := TRUE;
        ELSE;
            export_trigger[i] := FALSE;
        END_IF
    END_FOR;


軸の状態は、モーション論理軸にマッピングした構造体変数 ``axes[]`` （ ``AXIS_REF`` 型）にて監視できます。この中のPLCに公開しているデータセットに、
位置決め目標アドレス ``SetPos`` があります。

ここでは、位置決め目標アドレスが ``0`` （原点）で、その位置決めが完了状態（ ``InTargetPosition`` ）の時に
Trueとなるフラグ ``export_triger[]`` を作成しています。後ほどこのフラグを使ってScope viewのトリガ条件に使います。

このプログラム例では、 ``axes`` , および ``export_trigger`` はそれぞれ3軸分の配列でオブジェクトを保持できる様にしていますが、
以後の説明ではこのうち1軸目のみ（ export_triger[0] ）のみを用います。

.. _section_reg_target_variable:

モニタ対象変数の登録
--------------------------------

次の手順で監視対象デバイスを登録します。

1. RUNモードへ遷移し、XARにログインします。

   PLCのデバイスを収集するには、Target systemを接続先IPCに設定した上で、ログインする必要があります。

2. Target browserを出現

   ``DataPool`` メニューを右クリックし、メニューから ``Target Browser`` を選択する。

   .. figure:: image/chose_target_browser.png
        :align: center
        :name: chose_target_browser

        ターゲットブラウザを出現

3. 収集したい変数をさがす

   現れたウィンドウの左のメニューに、接続中のXARが緑色のディスプレーアイコンが現れます。これを開くと接続可能な制御モジュールが一覧されます。

   モーションコントローラのデバイスを監視したい場合は、 :numref:`motion_device_collection` の通り、ADSポート501から始まる名称のモジュール名を選択してください。
   また、PLCデバイスを監視したい場合は、 :numref:`plc_device_collection` の通り、ADSポート851から始まる名称のモジュール名を選択

   .. figure:: image/target_browser_motion.png
        :scale: 60%
        :align: center
        :name: motion_device_collection

        モーションコントローラのデータを監視する場合

   .. figure:: image/target_browser_plc.png
        :scale: 60%
        :align: center
        :name: plc_device_collection

        PLCのデバイスを監視する場合

4. DataPoolへの追加

   右側のツリーから目的のデバイス変数が見つかりましたら、選択してダブルクリックしてください。これにより ``DataPool`` メニュー上に追加されます。（ :numref:`add_to_data_pool` ）

   .. figure:: image/add_to_data_pool.png
        :scale: 80%
        :align: center
        :name: add_to_data_pool

        データプールへの変数の追加

YT Chartビューの概要
---------------------------

YT Chart ビューには、次のデータの階層構造を持っています。これらの階層構造は、Solution Explorerに現れるツリーで構成し、これに応じてグラフ表示の画面を構成することができます。（ :numref:`stacked_axes_view` ）

:YT Chart:

    画面単位です。上部のタブで切り替えることができます。

:Axis Group:

    グラフ軸単位です。一つの座標面に全ての軸を重ねて表示するビュー（ :numref:`unstacked_axes_view` ）と、軸毎に座標を分けて表示する ``Stacked axes`` ビュー（ :numref:`stacked_axes_view` ）の二つの表示方法があります。


モーションの監視を行う場合は、YT Chart毎に軸を分け、同じ単位系か、座標を分けて見たい単位でビューを作成するのがよいでしょう。

.. figure:: image/stacked_axes_view.png
        :width: 900px
        :align: center
        :name: stacked_axes_view

        ツリーとグラフビューの関係（Stacked axes ビュー）

.. figure:: image/unstacked_axes_view.png
        :width: 700px
        :align: center
        :name: unstacked_axes_view

        Stacked axes がOFFのビュー

YT Chartの追加
--------------------------

YT Chart タブを追加したい場合は、 :numref:`add_ytproj` の通りYT Scope Projectの階層で右クリックしたメニューから、 ``New YT Chart`` を選んでください。

.. figure:: image/add_ytproj.png
        :width: 400px
        :align: center
        :name: add_ytproj

        YT Chartの追加

Axisの追加
------------------------

Axis を追加したい場合は、 :numref:`add_axis` の通りYT Chartの階層で右クリックしたメニューから、 ``New Axis`` を選んでください。

.. figure:: image/add_axis.png
    :width: 400px
    :align: center
    :name: add_axis

    Axisの追加

Axis上への表示データの登録
--------------------------

DataPoolに登録された変数のデータを任意のYT ChartのAxisに表示させるためには、 :ref:`reg_data_to_view` の様に該当の変数をAxisへドラッグアンドドロップします。

.. figure:: image/reg_data_to_view.png
    :width: 300px
    :align: center
    :name: reg_data_to_view

    DataPoolからViewへの登録

以上で、変数登録からYT Chartへのビューへの一連の流れについて説明しました。この方法で、 :ref:`section_plc_trigger` 節のプログラムの、 ``export_trigger`` をDataPoolに登録し、CSVへ出力したい各軸のデータを YT Chart上に表示するよう、設定してください。

DataPoolに登録した ``export_trigger`` フラグの使い方は、次章のトリガの設定で説明します。

