# MC_StepBlock
### FBについて
![](assets/1.png)
このファンクションブロックは、物理的なオブジェクトに対して原点復帰手順 を実行し、移動を機械的にブロックする。このモードでは、リミットスイッチや基準パルスがない。原点復帰プロセス中に機械的な損傷を与えないためには、適切なトルク制限が必要。
- MC_StepBlock完了の条件は２つあり：
  - トルクリミットに達すこと
  - 実際の速度が、少なくとも'DetectionVelocityTime'の間'DetectionVelocityLimit' 入力の値を下回ったこと
- MC_StepBlockを実行すると
  - Axis.Status.Homingと.HomingBusyがTRUEになる
  - 論理軸のPosition Monitor,Software Limits,Torque limit機能が無効される
- MC_StepBlockを実行完了すると
  - Axis.Status.HomingがFALSEになり、 FBの出力信号DoneがTRUEになる
#### FBの入力
![](assets/2.png)
![](assets/3.png)
#### FBの出力
![](assets/4.png)
### 環境準備
#### PDOマッピング
トルクを監視するため実際トルク値のPDOをマッピングする必要がある。基本的には「Torque Actual Value」というオブジェクト
- AX8xxxの場合
![](assets/5.png)
- EL72xxの場合
![](assets/6.png)
- 追加したPDOのマッピング状態を確認する
論理軸にリンクがない場合、手動で論理軸とドライブのリンク外してから、再度リンクする
![](assets/7.png)
### 一例
![](assets/8.png)