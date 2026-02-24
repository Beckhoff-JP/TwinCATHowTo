# 設定

(section_dedicated_safety_task)=
## Safety専用タスクの作成

![](assets/create_safety_task.png){align=center}

![](assets/realtime_setting.png){align=center}

![](assets/task_cycle_setting.png){align=center}

## EtherCATの構成

例として次のEtherCATネットワークコンフィギュレーションを行います。

````{grid} 2

```{grid-item}
以下の構成で、図の赤枠と青枠、および、それ以外で区別した sync unit の設定を目指します。Safetyロジックは Term 1 以下にぶら下がっているEL6910に書き込みます。Term 14以下のEL6910は使いません。

Term 1  EK1101
    : EL6910（Safetyロジックターミナル）と EL1904 x  2 と EL2904を配置します。

Term 14 EK1101
    : 同じ構成ですが、Hot connect group = 1 を設定します。

```
```{grid-item}
![](./assets/sample_eni.drawio.png){align=center}
```
````

Hot connectを設定すると、次の通り自動的にグループ専用の sync unit が設定されます。

![](assets/2026-02-24-09-38-46.png){align=center}

ここからさらに、青枠で示した sync unit の設定を後ほど行います。

## Sync unitの設定

```{admonition} ポイント
:class: note

Hot connect グループ内の Safetyターミナルに特別なsync unitを設定するには、いちど Hot Connectを解除する必要があります。先にSafetyターミナルの sync unit を設定してから、再度 Hot Connectグループ設定を行います。
```

``````{grid} 1
`````{grid-item-card} カプラ内にあるSafetyターミナルを別の sync unit に設定するため、最初にホットコネクトグループから抜けます。
![](assets/delete_hotconnect_group.drawio.png){align=center}
`````
`````{grid-item-card} Safety ロジック、Safey IO 個別の sync unit を作成します。
![](assets/create_syncunit.drawio.png){align=center}
`````
`````{grid-item-card} Safety ロジック、Safey IO 個別の sync unit を作成します。
![](assets/dedicated_syncunit_for_safetylogic.png){align=center}
![](assets/dedicated_syncunit_for_safetyio.png){align=center}
`````
`````{grid-item-card} 再度ホットコネクトグループを設定します
````{grid} 2
```{grid-item}
![](assets/add_hotconnect_group.drawio.png){align=center}
```
```{grid-item}
![](assets/add_hotconnect_group2.drawio.png){align=center}
```
````
`````
`````{grid-item-card} 設定を確認すると、SafetyPlc, SafetyIO, Hot connect グループ内にあるSafetyIO, Hot connectグループ内にあるそれ以外のIO という四象限の sync unit ができ、に属する
![](assets/syncunit_safetyplc.drawio.png){align=center}
![](assets/syncunit_safetyio.drawio.png){align=center}
![](assets/syncunit_safetyio_hotconnect.drawio.png){align=center}
![](assets/syncunit_generalio_hotconnect.drawio.png){align=center}
`````
``````

## Sync unit task の設定

以下の設定により、PlcTaskにより巡回していたFSoEフレームが専用タスク `SafetyTask` のものに切り替わります。先に {ref}`section_dedicated_safety_task` を実施してください。

``````{grid} 1
`````{grid-item-card} EtherCAT メインデバイスの EtherCAT タブから、 Sync Unit Assignment... ボタンをクリック
![](assets/sync_unit_assignment_entry.png){align=center}
`````
`````{grid-item-card} 現れたウィンドウのターミナル一覧から、Shiftボタンを押しながらSafety関連のIOターミナルを全て選択します。次に右下の Forced Sync Unit Tasks の中から、最初に作成した専用タスク SafetyTask をクリックします。
![](assets/sync_task_setting.png){align=center}
`````
``````