% TwinCAT開発におけるプログラム標準化マニュアル documentation master file, created by
%  sphinx-quickstart on Tue Feb 21 11:50:42 2023.
%   You can adapt this file completely to your liking, but it should at least
%   contain the root `toctree` directive.

# Safetyと一般IOを分離する

TwinSafeにおいてロジックターミナル EL6910 と IOターミナル EL1904, EL2904 は {numref}`figure_safety_ethercat_connection` のように一般ELターミナルと混在してEtherCATネットワーク内に配置されています。EtherCATの周期データ交換はSafetyロジックターミナルが自発的に行うのではなく、EtherCATメインデバイスによる周期通信を介して行います。したがって、SafetyロジックとSafety IO 間の通信には、少なくとも2回の周期通信が必要です。

```{figure} ./assets/ethercat_connection.svg
:align: center
:name: figure_safety_ethercat_connection

安全ロジックとIOのEtherCAT接続例
```

また、TwinCATのデフォルトの設定では次の事象が発生し得ます。

* 万が一他のELターミナルが故障した場合、EtherCATフレームは破棄されます。これによりFSoEのデータも破棄されます。
* PLCのタスクの同期フレームの場合、ブレークポイントによるPLCのサイクル一次停止により安全データの交換が停止します。

FSoEではSafetyロジックとIO間をIEC 61784-3 に定められたブラックチャンネルで通信します。ブラックチャンネルを経ても安全を担保するため、Safety ロジックからの周期フレームが規定時間以内に届くことのWDT（ウォッチドッグタイマ）監視を行い、これを超過した場合にSafety IOは強制的に安全状態になる仕様となっています。よって、上記の問題に示すような安全関連部の制御とは関係なく通信が途絶えることにより安全インターロックが働くこととなります。

これを防ぐため、次の設定を行います。

* Safetyデータ交換用の専用タスクを作成し、PLCなどの一般制御の状態とは独立した周期でFSoEのデータ交換を行う。
* SafetyロジックとEtherCATメインデバイス、SafetyIOとEtherCATメインデバイス間の周期通信の Sync unitを、それぞれそれ以外の Sync unit から独立する。

上記を対応することで、より安全関連部の制御通信系統が独立させることが可能となります。

## Sync unitとは

EtherCATのPDOのフレームは、最大1498バイトのEtherCATデータエリアに収まるように最大15個のデータグラムが構成されます。効率的なプロセスデータ交換には、個々のサブデバイス毎に個別のデータグラムによるコマンドを発行するのではなく、マスタが定めた仮想のメモリ空間上のアドレス情報（論理アドレス情報）をサブデバイスと共有することで、1つのデータグラムに対して複数のサブデバイスが読み書きできる「論理読み書きコマンド」を用います。

このデータグラム内のアドレス情報に応じて、単一のデータグラムに対して対象の論理アドレスが割り当てられたサブデバイスがオンザフライ方式での読み書きを行います。この論理コマンドを発行するサブデバイスのグループ単位が sync unit となります。

サブデバイスは、正常に読み書きを実行するとワーキングカウンタ（WC）部の値をコマンド内容に応じて加算します。

![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/gif/2469218443__Web.gif){align=center}

メインデバイスは周回したEtherCATフレームを受け取った後、ワーキングカウンタの値をチェックし、期待通りでなければ無効データグラムとして破棄します。つまり、複数のサブデバイスで読み書きを行ったデータが、一つのサブデバイスのデータ読み書き失敗（故障）により全て無効化される事になります。

論理読み書きコマンドのデータグラムは sync unit単位で作成されますので、異なる sync unit を設定すれば故障による影響を受けません。反面、個別のデータグラムを設定することでコマンド処理の負荷が高まったり、データグラム毎のヘッダ、ワーキングカウンタの領域が割り当てられることにより、データ転送効率は低下します。

初期状態では、[Infosysのこの説明](https://infosys.beckhoff.com/content/1033/ethercatsystem/2474149131.html?id=3867848852236495949)にあるように、全てのサブデバイスが `<default>` という同一の sync unit となっています。したがって一つでも故障が発生した場合、全てのターミナルの周期通信ができなくなります。

## Sync unit taskとは

TwinCATにおけるEtherCATの周期通信におけるフレームはタスクに同期して送出されます。

![](https://infosys.beckhoff.com/content/1033/ethercatsystem/Images/gif/2469687819__Web.gif){align=center}

初期設定のTwinCATにおいて安全データであるFSoEは、全体のデータサイズから自動的に最適なフレームに組み込まれます。よって、仮にそのタスクが停止してしまうとFSoEの伝送も停止し、ウォッチドッグタイムを守れず安全回路による停止につながります。

## Safetyの原則

安全関連部（SRP/CS：Safety-Related Parts of Control Systems）は、危険な故障時に機械を安全な状態（例：緊急停止）にする機能を持つ部分です。一般制御部（非安全）と、安全関連部を分離して安全制御の独立性を図ることが重要です。

```{note}

[ISO 13849-1の概要](https://www.jqa.jp/service_list/fs/robo_trend/10/index.html)参照
```

ブラックチャンネルポリシーにより通信異常によってSafety IOが自発的に安全側に停止することは最低限の安全を担保する方策として認められています。しかし、より望ましい形としては通信異常による安全関連部の動作停止を最小限に抑え、安全制御をなるべく継続できるように設定することが望ましいでしょう。

次節より具体的な設定手順について説明します。

```{toctree}
:caption: 目次
:hidden:

settings.md
```