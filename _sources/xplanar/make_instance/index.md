# PLCインスタンス作成

ここでは、軸オブジェクトであるXPlanar MC Projectとリンクを形成する ための準備を行います。

## ライブラリのインポート

XPlanarが使用するライブラリを、PLCプロジェクトの`Reference`から追加します。

```{warning}
XPlanarは非常に開発速度の速い製品です。開発時点におけるライブラリッバージョンを固定されることをお勧めします。詳しくは、{ref}`freeze_library_version`をご覧ください。
```


必須ライブラリは以下の通りです。
Tc3_PlanarMotion
  : XPlanar を動かすための機能が集約されたライブラリです。

Tc3_Physics
  : XPlanar の制御に必要な値の参照列挙体が入ったライブラリです。

Tc3_XPlanarUtility
  : TcCOM から XPlanar の情報を得たり、Visualization に反映させる機能を持つライブラリです。

Tc2_Module
  : 初期化ライブラリです。

また、次のライブラリは必要に応じて追加してください。

Tc2_MC2
  : ExternalSetPoint 機能を使用する場合に主軸として追加する場合に必要です。

## インスタンスの定義

PLCプロジェクトを作成し、必要なスコープに下記の通り必要なファンクションブロックのインスタンスを定義します。

次の例では、グローバル変数として宣言しています。

Mover,Trackが複数ある場合は`CONSTANT`で定義した上で配列で定義してください。

定義が完了したらビルドを行い、次節のリンクを行います。

```{code-block} iecst
{attribute 'qualified_only'}
VAR_GLOBAL CONSTANT
  NUM_OF_MOVERS :UINT := 5;
  NUM_OF_TRACKS : UINT := 3;
END_VAR
VAR_GLOBAL
  planar_movers	: ARRAY [1..NUM_OF_MOVERS] OF MC_PlanarMover;
  planar_environment : MC_PlanarEnvironment;
  planar_group	: MC_PlanarGroup;
  planar_tracks	: ARRAY [1..NUM_OF_TRACKS] OF MC_PlanarTrack;	
END_VAR
```
