% TwinCATプロジェクトクローンマニュアル documentation master file, created by
%   sphinx-quickstart on Mon Feb 20 13:38:58 2023.
%   You can adapt this file completely to your liking, but it should at least
%   contain the root `toctree` directive.

(section_auto_deploy)=
# プロジェクト更新をTwinCAT XAEを使わず行う

このドキュメントは、TwinCAT3のPLCプロジェクト、およびC/C++プロジェクトの実行ファイルをTwinCAT3開発環境(以下、XAE)無しに展開する方法について説明します。開発用のモデルマシンにて作成したプログラムイメージは、この手順に従って他の同一ハードウェア構成のマシンへ展開する事ができます。

次の注意事項をよくお読みの上、正しくお使いください。

```{admonition} 危険
:class: danger

本手順は、装置稼働中に絶対に行わないでください。装置が確実に停止している状態(TwinCAT3ランタイム(以下、XAR)がコンフィグレーションモード)で作業を行ってください。稼働中に実施することにより制御対象の装置が安全に停止できなくなる可能性があり、重大な事故につながる可能性があります。

```

```{admonition} 注意
:class: warning

次の様なケースでは、TwinCAT開発環境（XAE）を必要とします。

* 弊社からの出荷時にユーザプログラム実行に必要なライセンスがインストールされていない場合、後からライセンスを追加する際にはTwinCAT開発環境（XAE）を必要とします。

* ライセンスドングルによる運用を行う場合も、さいしょにドングルをアクティベートする必要があります。この際TwinCAT開発環境（XAE）を必要とします。

```

```{admonition} 注意
:class: warning

TwinCAT Safety (TwinSafe) に対するソフトウェアの書き込み、更新については、専用ソフトウェア TwinSafe Loader が必要です。

```

```{toctree}
:caption: 目次

develop_project.md
deploy_project.md
```
