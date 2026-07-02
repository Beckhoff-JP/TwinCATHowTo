# 開発編 （CNC）

```{important}
### 目的

工作機械・CNCを扱う技術者が、TwinCAT 3 CNCを使って工作機械制御を実装するために、そのアーキテクチャと実装上の基本構造を理解する

### 対象

- 工作機械・CNCを扱う技術者
- BeckhoffのPLC基礎トレーニングを受講済
- BeckhoffのCNCのライセンスを購入し、「TC3_CNCPLCBase.tpzip(標準PLCプロジェクト)」と「Beckhoff.App.Shell.Core.exe(標準HMIアプリケーション)」が配布されていること

```

***

**一般的なCNCとTwinCAT 3 CNCの違い**  

現在広く普及しているCNCは、補間演算や軸指令の生成だけにとどまらず、画面の表示、PLC機能、サーボ制御など、さまざまな機能をまとめて専用のCNC装置として提供されています。({numref}`figure_cnc_system`)

```{figure} cnc/assets/develop_cnc_001.png
:align: center
:name: figure_cnc_system
一般的なCNCの構成
```

一方でBeckhoffが提供するCNCは、産業用PC上で動作するTwinCAT 3のMotion機能の一部として提供されるソフトウェアCNCです。({numref}`figure_twincat_cnc`)  
TwinCAT 3という統合プラットフォームには、PLC、Motion、HMI、通信などの機能モジュールも含まれています。一般的なCNCとの違いは、CNC機能を専用CNC装置としてではなく、TwinCAT 3の拡張機能としてPCベース制御システムに組み込める点です。PLCやHMIなどと同じTwinCAT 3上で構成できるため、より柔軟で拡張性のある制御システムを構築することが可能です。

```{figure} cnc/assets/develop_cnc_002.png
:align: center
:name: figure_twincat_cnc
TwinCAT 3 CNCの構成
```

以下は、それぞれのCNCの主要な機能の違いをまとめた表です。({numref}`cnc_comparison_table`)

```{csv-table} CNC項目別対比表
:header: 項目, 一般的なCNC, TwinCAT 3 CNC
:name: cnc_comparison_table
:widths: 25, 30, 52

制御機器, CNC装置, IPC + TwinCAT 3
画面, 標準のCNC画面, 専用アプリケーション・TwinCAT 3 HMI
PLC機能, CNCの補助機能・PMC, TwinCAT 3 PLC
軸・ドライブ制御, CNC装置 + サーボアンプ, TwinCAT 3 CNC + EtherCAT対応ドライブアンプ
```

***

**Beckhoffの工作機械制御**  

前述の通り、Beckhoffが提供するCNCは、TwinCAT 3の機能モジュールの一部であり、ハードウェアとして専用のCNC装置を必要としません。代わりに、産業用PC（IPC）上で動作するTwinCAT 3 Runtimeを使用して、CNC機能を実現します。({numref}`figure_beckhoff_cnc_control`)  
CNCは、NCプログラムに従って補間演算や軸指令の生成を行い、EtherCATで接続されたサーボドライブなどを介して工作機械の各軸を動作させます。また、PLCはEtherCATで接続された入出力デバイスを制御することで周辺機器の制御を、HMIは操作画面の表示と操作の入力処理を担います。さらに、IPC上ではTwinCATのリアルタイム制御とOS側のアプリケーションを組み合わせられるため、OPC UAなどの通信機能を介してIoTやクラウドサービスなどの外部システムと連携することもできます。

```{figure} cnc/assets/develop_cnc_003.png
:align: center
:name: figure_beckhoff_cnc_control
Beckhoffの工作機械制御の概要
```

上記のCNCによる各軸制御の仕組みを少し掘り下げて解説します。({numref}`figure_cnc_motor_control`)  
CNCは、通常NCプログラムを実行することで、各軸の動作を制御します。NCプログラムは、DIN 66025に基づくGコードやMコードなどの命令で構成されており、これらの命令に従ってCNCは各軸の目標位置・速度・加速度を決定し、周期的な指令値としてサーボドライブへ送信します。  
指令値を受信したサーボドライブは、内蔵されたサーボ制御機能により、サーボモータへ出力する電流やトルクを制御し、各軸の動作を実現します。サーボモータには、CNCからの指令位置に対して所定の精度と応答性で追従することが求められます。サーボモータの精度と応答性は、機械特性に応じたサーボ制御の制御器パラメータ（ゲイン）で決定されるため、適切なサーボパラメータ調整(ゲイン調整)を行うことが重要になります。  
軸の動作に問題が発生した際、上記のCNCとサーボ制御の役割の境界を理解していると、問題の原因を特定しやすくなります。また、それぞれの機能を拡張させることにより、より高度な制御を実現することも可能です。

```{figure} cnc/assets/develop_cnc_004.png
:align: center
:name: figure_cnc_motor_control
CNCによるモータ制御
```

***

**TwinCAT 3 CNCのアーキテクチャ**  

TwinCAT 3 CNCによる工作機械の制御実装において、そのアーキテクチャを理解することは非常に重要です。以降では、工作機械の制御におけるTwinCATの各機能の役割と、CNCとPLCをつなぐHLIの説明をします。  

工作機械では、機械を扱う作業者はHMI（画面）を通して機械を操作し段取りを行います。この画面の機能は、TwinCAT 3 HMIや、ライセンス購入時に配布されている「Beckhoff.App.Shell.Core.exe（標準HMIアプリケーション）」が担います。  
HMIの操作処理は、ADS通信などを介してPLCの変数を読み書きします。PLCはその変数変化の情報をもとに、HLIを通してCNCに制御命令を渡します。  
CNCは命令された制御を実行します。それが軸の制御に関わる命令であれば、前述の通りにEtherCATで接続されたサーボドライブへ位置指令などを送信し、指令を受信したサーボドライブは、必要な電流やトルクを出力してサーボモータを回転させます。  
ここで重要なのが、PLCとCNCの情報をやり取りしているHLIの存在です。以降では、HLIについて解説します。

```{figure} cnc/assets/develop_cnc_005.png
:align: center
:name: figure_twincat_cnc_architecture
TwinCAT 3 CNCのアーキテクチャ
```

PLCとCNCの間には共有メモリ領域としてHLI（High Level Interface）が用意されています。PLCがHLI上の変数を読み書きすることで、CNCの制御命令の受け渡しや状態情報の取得を行います。基本的に、HMIやユーザアプリケーションからTwinCAT 3 CNCへ機能コマンドを直接入力したり、CNC内部情報を直接参照したりすることはありません。それらは全てPLCからHLIを介してアクセスします。({numref}`figure_hli_interface`)  
例として、ジョグ動作フローと、座標表示フローにおけるHLIの関わりを以降で解説します。

```{figure} cnc/assets/develop_cnc_006.png
:align: center
:name: figure_hli_interface
PLCとCNCをつなぐHLI
```

ジョグ動作では、まず作業者がHMIを通して操作入力を行います。操作を受け付けたHMIは、ADSを介してPLCの所定の変数へ書き込みます。PLCはその変数の状態に応じてHLI上のコマンド領域を更新し、CNCへジョグ命令を渡します。命令を受けたCNCが、対象軸のジョグ動作を行います。
このフローにおいて、HLIはPLCからCNCへコマンドを渡すインタフェースの役割を担っています。({numref}`figure_jog_operation`)

```{figure} cnc/assets/develop_cnc_007.png
:align: center
:name: figure_jog_operation
ジョグ動作フロー
```

座標表示フローでは、まずCNCが軸の位置情報をEtherCATで接続されたサーボドライブから取得します。その情報をHLIを通してPLCに提供し、PLCはその情報を所定の変数に書き込みます。HMIはある周期でその変数の情報を読み取り、それを表示します。
このフローにおいて、HLIはCNCが持っている状態情報をPLCへ渡すインタフェースの役割を担っています。({numref}`figure_coordinate_display`)

```{figure} cnc/assets/develop_cnc_008.png
:align: center
:name: figure_coordinate_display
座標表示フロー
```

上記の通り、CNC制御における機能の実行と情報の取得において、PLCとCNCの情報を受け渡すHLIの重要性が理解できたと思います。配布されている「TC3_CNCPLCBase.tpzip（標準PLCプロジェクト）」では、CNCの基本的な機能に関して、HLIへ直接アクセスしなくても扱えるように標準PLC側の変数や処理が用意されています。標準PLC側に用意されていない機能については、TwinCAT CNCのPLCライブラリで用意されているファンクションブロックを使用する、もしくはHLIにアクセスして制御実装を行うことになります。

***

```{toctree}
:caption: 目次

cnc/00_introduction/index.md
```
