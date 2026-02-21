# 設定

まずは次の通りの

## プロジェクト構成

### Safety専用タスクの作成

![](assets/create_safety_task.png){align=center}

![](assets/realtime_setting.png){align=center}

![](assets/task_cycle_setting.png){align=center}

### EtherCATの構成

次の順でカスケードに接続されたEtherCATネットワークコンフィギュレーションを行います。

EK1100
    : EL6910（Safetyロジックターミナル）を配置します。

EK1101
    : ユニット1でオプショナルです。EL1904とEL2904を配置し、Hot connect group = 1を設定します。

EK1101
    : ユニット1でオプショナルです。EL1904とEL2904を配置し、Hot connect group = 2を設定します。

### Safetyプロジェクトの作成

## Sync unit, Sync taskの設定
