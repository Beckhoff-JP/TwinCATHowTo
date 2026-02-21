% TwinCAT開発におけるプログラム標準化マニュアル documentation master file, created by
%  sphinx-quickstart on Tue Feb 21 11:50:42 2023.
%   You can adapt this file completely to your liking, but it should at least
%   contain the root `toctree` directive.

# Safetyと一般IOを分離する

SafetyロジックとIOは {numref}`figure_safety_ethercat_connection` のようにロジックとIOがEtherCATネットワーク内に配置されています。EtherCATの周期データ交換は、ロジックターミナルが行うのではなく、EtherCATメインデバイスの周期通信の中にFSoEを含ませて伝送します。したがって、SafetyロジックとSafetyIO間でデータを交換するには、少なくとも2回のEtherCATフレームの周回が必要で、この間、EtherCATメインデバイスがFSoEのデータを中継します。

```{figure} ./assets/ethercat_connection.svg
:align: center
:name: figure_safety_ethercat_connection

安全ロジックとIOのEtherCAT接続例
```

このため、デフォルトの状態では次の問題が懸念されます。

* 他のELターミナルが故障した場合でも引きずられて安全データの交換ができなくなる。
* PLCのタスクに同期したEtherCATフレームが送出される場合、PLCのタスクを停止する事により安全データの交換ができなくなる。

これを防ぐため、次の設定を行います。

* Safetyデータ交換用の専用タスクを作成し、この周期でFSoEのデータ交換を行う。
* Safetyロジック - EtherCATメインデバイス、SafetyIO - EtherCATメインデバイス間のEtherCAT周期通信のSync unitを分ける。

上記二つを対応することで、より安全関連部の制御通信系統が独立させることが可能となります。

## Sync unitとは

EtherCATのPDOのフレームは、最大1498バイトのEtherCATデータエリアに収まるように最大15個のデータグラムが構成されます。効率的なプロセスデータ交換には、個々のサブデバイス毎に個別のデータグラムによるコマンドを発行するのではなく、マスタが定めた仮想のメモリ空間上のアドレス情報（論理アドレス情報）をサブデバイスと共有することで、1つのデータグラムに対して複数のサブデバイスが読み書きできる「論理読み書きコマンド」を用います。

このデータグラム内のアドレス情報に応じて、単一のデータグラムに対して対象の論理アドレスが割り当てられたサブデバイスがオンザフライ方式での読み書きを行います。この論理コマンドを発行するサブデバイスのグループ単位が sync unit となります。

サブデバイスは、正常に読み書きを実行するとワーキングカウンタ（WC）部の値をコマンド内容に応じて加算します。

![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/gif/2469218443__Web.gif){align=center}

メインデバイスは周回したEtherCATフレームを受け取った後、ワーキングカウンタの値をチェックし、期待通りでなければ無効データグラムとして破棄します。つまり、複数のサブデバイスで読み書きを行ったデータが、一つのサブデバイスのデータ読み書き失敗（故障）により全て無効化される事になります。

論理読み書きコマンドのデータグラムは sync unit単位で作成されますので、異なる sync unit を設定すれば故障による影響を受けません。反面、個別のデータグラムを設定することでコマンド処理の負荷が高まったり、データグラム毎のヘッダ、ワーキングカウンタの領域が割り当てられることにより、データ転送効率は低下します。

初期状態では、[Infosysのこの説明](https://infosys.beckhoff.com/content/1033/ethercatsystem/2474149131.html?id=3867848852236495949)にあるように、全てのサブデバイスが `<default>` という同一の sync unit となっています。したがって一つでも故障が発生した場合、全てのターミナルの周期通信ができなくなります。

## Sync taskとは

TwinCATにおけるEtherCATの周期通信におけるフレームはタスクに同期して送出されます。

![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/gif/2469687819__Web.gif){align=center}

初期設定のTwinCATにおいて安全データであるFSoEは、全体のデータサイズから自動的に最適なフレームに組み込まれます。よって、仮にそのタスクが停止してしまうとFSoEの伝送も停止し、ウォッチドッグタイムを守れず安全回路による停止につながります。

## Safetyの原則

安全関連部（SRP/CS：Safety-Related Parts of Control Systems）は、危険な故障時に機械を安全な状態（例：緊急停止）にする機能を持つ部分です。一般制御部（非安全）と、安全関連部を分離して安全制御の独立性を図ることが重要です。

```{note}

[ISO 13849-1の概要](https://www.jqa.jp/service_list/fs/robo_trend/10/index.html)参照
```

この独立性は安全関連部の故障に影響を受けて安全関連部が機能しなくなる状況を防ぐために重要です。TwinSafeで使用されているFSoEの場合、 IEC 61784-3 に定められたブラックチャンネルアプローチにより同一 sync unit の一般ターミナルが故障したことにより通信が停止した場合でもSafetyターミナルは安全状態で停止することが保証されています。これよってこの目的を果たしています。

しかし、独立原則が成立していれば必ずしも非安全部の故障により連動して安全関連部が停止する必要は有りません。むしろ安全関連部は独立して稼働し続た方が、復帰までにかかる機械ダウンタイムの軽減につながります。

そこで、次節より次の対策を行う設定手順について説明したいと思います。

* 安全関連部専用に独立したタスクを設定して sync taskとする。
* SafetyロジックからEtherCATマスタまでのデータグラム、Safety IOからEtherCATマスタまでのデータグラム、それぞれ個別のSync unitを割り当てる。