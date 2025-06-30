# リンク設定

## MC_PlanarMover のリンク

```{list-table}
:widths: 1, 30, 60
:stub-colmuns: 1

* - 1
  - `MOTION` > `XPlanar MC Project` > `Axes` > `Mover` を選択する。  
  - ![Mover_SolutionBar](assets/Mover_SolutionBar.png){align=left}
* - 2
  - `Setting Tab` > `Link To PLC...` を選択する。  
  - ![Mover_LinkToPlc-Setting](assets/Mover_LinkToPlc-Setting.png){align=left}
* - 3
  - PLC Project で Build された MC_PlanarMover を選択してリンクする
  - ![Mover_Link-MC_PlanarMover](assets/Mover_Link-MC_PlanarMover.png){align=left}
```

## MC_PlanarGroup のリンク

```{list-table}
:widths: 1, 30, 60

* - 1
  - `Planar Group` > `McToPlc` > `STD` を選択する。  
  - ![Group_SolutionBar](assets/Group_SolutionBar.png){align=left}
* - 2
  - `Variable Tab` > `LInked to ...` を選択する。
  - ![Group_LinkToPlc-Setting](assets/Group_LinkToPlc-Setting.png){align=left}
* - 3
  - PLC Project で Build された MC_PlanarGroup を選択してリンクする
  - ![Group_Link-MC_PlanarGroup](assets/Group_Link-MC_PlanarGroup.png){align=left}
```

## MC_PlanarEnvironment のリンク

```{list-table}
:widths: 1, 30, 60

* - 1
  - `Planar Environment` > `McToPlc` > `STD` を選択します
  - ![Environment_SolutionBar](assets/Environment_SolutionBar.png){align=left}
* - 2
  - `Variable Tab` > `LInked to ...` を選択します
  - ![Environment_LinkToPlc-Setting](assets/Environment_LinkToPlc-Setting.png){align=left}
* - 3
  - PLC Project で Build された MC_PlanarGroup を選択してリンクします
  - ![Environment_Link-MC_PlanarEnvironment](assets/Environment_Link-MC_PlanarEnvironment.png){align=left}
```

## MC_PlanarTrack のリンク

```{tip}
Multi Track など複数の Track を使用する場合は 各 MC_PlanarTrack 毎に作成してリンクする必要があります。
```


```{list-table}
:widths: 1, 30, 60

* - 1
  - `MOTION` > `XPlanar MC Project` > `Group` で Add New Items を開きます
  - ![GroupAddNewItem](assets/GroupAddNewItem.png){align=left}
* - 2
  - `Planar Track` を選択して追加します
  - ![InsertTcComObject](assets/InsertTcComObject.png){align=left}
* - 3
  - `Planar Track` > `McToPlc` > `STD` を選択します
  - ![Track_SolutionBar](assets/Track_SolutionBar.png){align=left}
* - 4
  - `Variable Tab` > `LInked to ...` を選択します
  - ![Track_LinkToPlc-Setting](assets/Track_LinkToPlc-Setting.png){align=left}
* - 5
  - PLC Project で Build された MC_PlanarGroup を選択してリンクします
  - ![Track_Link-MC_PlanarGroup](assets/Track_Link-MC_PlanarGroup.png){align=left}
```
