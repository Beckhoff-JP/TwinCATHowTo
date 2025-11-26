% TwinCAT開発におけるプログラム標準化マニュアル documentation master file, created by
%  sphinx-quickstart on Tue Feb 21 11:50:42 2023.
%   You can adapt this file completely to your liking, but it should at least
%   contain the root `toctree` directive.

# レシピ機能

PLCプロジェクトにおいて永続化したいデータは、`PERSISTENT` 属性の変数定義を行うとシャットダウンするたびにファイルに保存され、再起動時にその値が復活される仕組みが行われます。この機能については、{numref}`chapter_data_persistance` をご参照ください。

これらの初期値を設定するにはどうすれば良いでしょうか。TwinCATのXAE上でひとつづつPERSISTENT変数を探して、[値の強制書込み](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2527602315.html?id=494443402436376356)を実施するのは現実的ではありません。

また、プログラム上でハードコーディングされた初期値はその値に固定化されてしまい、設備や装置の構成により値を変化させる柔軟性に欠けてしまいます。

そこで、バリエーションを持つ可能性のある初期値を設定する仕組みとしてTwinCATにはRecipe機能があります。この使い方をついてご紹介します。

## TwinCATにおけるRecipeのアーキテクチャ

レシピに関する操作、および、データの構造は{numref}`figure_recipe_architecture`のとおりです。初回にTwinCATの開発環境でRecipe Managerを作成します。そこに、一定の目的毎にグループ化された管理対象の変数セットを定義した`Recipe definition`を作成し、その変数セットの値のバリエーションパターンを`Recipe`として作成します。このスキーマに従った値のデータは、Recipe毎に独立したファイルとしてターゲットIPCのWindows上のファイルシステムに作成されます。

また、このレシピファイルはTwinCAT XAEを通して保存、読み込みが可能となっています。

```{figure-md} figure_recipe_architecture
![](./assets/recipe_architecture.png){align=center}

レシピアーキテクチャ
```

本章では、これらの操作方法について説明します。

```{toctree}
:caption: 目次

setup_recipe
use_recipe
recipe_library
```

