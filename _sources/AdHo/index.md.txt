# 原点復帰
 
### 機能紹介
 通常に使用されているMC_Homeの動作はあらかじめ駆動の仕様が定義されて、その仕様を編集することはできない。このため、Advanced HomingライブラリのFBが用意されて、アプリケーションやユーザーの要望により、異な駆動を組見合わせて原点復帰を実行できる。
### システム条件
- Advanced Homingライブラリを使用のためTC3.1 4024.1以降が必要
- 基本的には下記のBAドライブをサポートする
  - EL72xx
  - AX5xxx
  - AX8xxx

### 定義されたファンクションブロックの概要
- 以下の表では、原点復帰**駆動系**と**完了系**に分類している

|   　駆動系　|  　完了系　 |
|------------|------------|
|MC_StepAbsoluteSwitch/ MC_StepAbsoluteSwitchDetection|　MC_HomeDirect |
| MC_StepLimitSwitch/ MC_StepLimitSwitchDetection| MC_FinishHoming |
|  MC_StepBlock/ MC_StepBlockDetection/ MC_StepBlockLagBased /MC_StepBlockLagBasedDetection|MC_AbortHoming|
|MC_StepReferencePulse/ MC_StepReferencePulseDetection|  　|

#### 駆動系
- 参照の信号を検出するため、原点復帰シーケンスを開始する。参照信号の種類により下記のFBが用意される：
  - MC_StepAbsoluteSwitch:アブソリュートスイッチやリミットスイッチを検出する原点復帰
  - MC_StepLimitSwitch:リミットスイッチを検出する
  - MC_StepBlock:物理のブロックを検出する
  - MC_StepReferencePulse: エンコーダーのZ相信号を検出する
 - "Detection"が付いてあるFB（例はMC_StepBlockDetection）は追加で検出された位置データを保存するための出力がある
 - 駆動系のFBを実行すると軸を”Standstill"ステータスから"Homing"に変更する。この駆動系のFBが正常に完了しても軸はこのまま”Homing"状態が残っている。

 ##### 構成例
 上記の駆動系のFBを組み合わせ、原点復帰手順を作成する
 ![](assets/1.png)
①：アブソリュートスイッチ→Z相信号検出
②：物理のブロックだけ検出
③：物理のブロック→Z相信号検出
④：リミットスイッチ→ブロック→C相信号の順番で検出する

#### 完了系
- 完了系のFBを実行すると原点復帰が完了される。軸は元のステータスに戻る。完了する前にオプションとして駆動の追加ができる
  - MC_HomeDirect:現在位置を強制に設定する
  - MC_FinishHoming:追加でRelative移動できる
  - MC_AbortHoming

### 環境準備
#### ライブラリの追加
TwinCATの場合、AdvancedHomingのライブラリの名称はTc3_MC2_AdvancedHoming
![](assets/2.png)
①Project-Referencesタブを右クリック→Add library...を選択
②簡単にAdvancedHomingのキーワードで探し、出た結果を選択→OK


```{toctree}
:caption: 目次

../McStepBlock/index.md

```
