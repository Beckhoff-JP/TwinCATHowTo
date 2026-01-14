# 開発編（モーション）

Beckhoffのモーション機能は主要な特徴の一つです。一般的にPLCの制御レベルと、モーションを指令する制御サイクルに求められる同期性、高速性は大きく異なります。

{numref}`figure_motion_system_role`は一般的なモーションシステムの機能ブロックです。モーション制御部は、アクチュエータの諸元やキネマティクスに従って、各軸の時系列での動作プロファイルを生成し、目的とする搬送動作を計画します。制御実行時には、このプロファイルに基づいて時間分割し、非常に高い周期で目標とする位置または速度をサーボドライブに指示します。サーボドライブはこれに基づいてアクチュエータを動作させ、エンコーダ等のセンサにより指示されたとおりの動作になるようフィードバック制御を行っています。

このように、モーション制御部とサーボドライブ間は高速周期、且つ、各軸を同期して制御させる必要があるため、一般的なモーションシステムでは、モーション以外のI/O制御とは異なる、高い同期性能を持った専用のフィールドバスが使われることが多いです。

```{figure-md} figure_motion_system_role
![](assets/2023-06-23-09-02-15.png){width=500px align=center}

モーションシステム例
```

しかし、弊社のコントローラの場合はIO制御もモーション制御も同じEtherCAT内で完結します。それだけでなく、PLC機能とモーション制御部の両方をTwinCAT上のソフトウェアで実現するため、専用のPLCのCPU、モーションコントロールユニットを必要としません。

つまり、多軸の同期モーション制御・安全回路・一般I/O制御をPCと一本のEthernetケーブルだけで実現できる極めてシンプルな構成を実現できるのです。

```{figure-md} figure_legacy_motion_system
![](assets/2023-06-23-09-00-04.png){align=center width=700px}

従来のモーション制御システム例
```

```{figure-md} figure_twincat_motion_system
![](assets/2023-06-23-09-01-09.png){align=center width=700px}

TwinCATによるPCベースモーション制御システム
```

この章では、これらのシステムを実現するTwinCATのモーション機能に関するさまざまな手法をご紹介します。


```{toctree}
:caption: 目次

Make_Cam/index.md
AdHo/index.md
xplanar/index.md
m_ext_setpoint/index.md
```


```{admonition} C++ / MATLABライセンスをご検討中の方はご注意ください
:class: warning

TwinCATには、C++による制御やMatlab / Simlink連携をご利用される場合以下のコアライセンスが用意されています。このライセンスはPLC機能を必要とせずC++ やMatlab/Simlinkのみで制御ロジックを構築されたいお客様向けのライセンスとなっています。

* TC 1300 TwinCAT 3 C++
* TC 1320 TwinCAT 3 C++/Matlab

このコアパッケージを用いて、本章で説明するモーションコントロールロジックを構築頂く事はもちろん可能ですが、PLCOpenのMotion Control FBの機能を提供する、NC PTP, NC I, CNCなどのパッケージはご利用いただけません。これらは必ずPLC機能を必要としますので、以下のライセンスをご指定頂く必要があります。

* TC 1200 TwinCAT 3 PLC
* TC 1210 TwinCAT 3 PLC/C++
* TC 1220 TwinCAT 3 PLC/C++/Matlab

![](assets/2023-07-08-11-12-51.png){align=center}

```

```{admonition} YoutubeによるNC PTP トレーニングビデオのご紹介

PLCとNC PTPを用いた単軸モーション制御の構築例を[シリーズ化したYouTubeトレーニングビデオ](https://youtube.com/playlist?list=PL7gRjakiitMw_uBCA4oYiApkCIVI797kY)をご案内しています。

```{youtube} 9ZpAuE6JpWc
:align: center
```
