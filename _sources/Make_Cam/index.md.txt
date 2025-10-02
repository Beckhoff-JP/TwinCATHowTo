---
aliases: 
created: 2023-06-12
updated: 2023-06-20
---
# 電子カム

TwinCAT XAEのCam Design Toolを使用してCamを作成することができます。

```{note}
本節では、PLCOpenに準拠したモーション機能（PLC NC）が提供するカム機能（TF5050）を設定するためのツール：Cam Design Tool TE1510の使い方をご説明します。
```

```{warning}
TE1510のライセンスがない場合、新規作成は可能ですが、編集することができませんのでご注意ください。
```

## 前準備

### NC Task を追加する

![Image](assets/Make_Cam_01.png){align=center width=500px}

`MOTION` > `Add New Item...`を選択する。

![Image](assets/Make_Cam_02.png){align=center width=500px}

目的の NCTask を作成する。

### Axis を追加する

![Image](assets/Make_Cam_03.png){align=center width=500px}

`Axes` > `Add New Item...`を選択する。

![Image](assets/Make_Cam_04.png){align=center width=500px}

Master と Slave 用に 2 軸 Continuous Axis を追加する。

### Master の追加

![Image](assets/Make_Cam_05.png){align=center width=500px}

`Tables` > `Add New Item...`を選択する。

![Image](assets/Make_Cam_06.png){align=center width=500px}

Motion Diagram で Master を追加する。

### Slave の追加

![Image](assets/Make_Cam_07.png){align=center width=500px}

`Master` > `Add New Item...`を選択する。

![Image](assets/Make_Cam_08.png){align=center width=500px}

Slave を追加する。

## Cam の作成

### Motion の作成

Slave を選択します。

![Image](assets/Make_Cam_09.png){align=center width=700px}

上がポイントの情報画面(上部)
下がプロファイル画面(下部)

![Image](assets/Make_Cam_10.png){align=center width=600px}

![Image](assets/Make_Cam_11.png){align=center width=150px}

Insert Point を選択します。

![Image](assets/Make_Cam_12.png){align=center width=200px}

下部にポイントを作る。

![Image](assets/Make_Cam_13.png){align=center width=700px}

ポイントができると上部にポイントのデータが自動生成されます。

![Image](assets/Make_Cam_14.png){align=center width=500px}

ポイントを 2 つ追加する。

![Image](assets/Make_Cam_15.png){align=center width=700px}

上部のデータも自動追加されます。

### グラフの形状を変える

![Image](assets/Make_Cam_16.png){align=center width=200px}

上部の Fuction でグラフの形状を変更できます。

![Image](assets/Make_Cam_17.png){align=center width=500px}

Function に合わせてグラフが変化します。
