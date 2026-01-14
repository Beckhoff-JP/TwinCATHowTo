% TwinCAT開発におけるプログラム標準化マニュアル documentation master file, created by
%  sphinx-quickstart on Tue Feb 21 11:50:42 2023.
%   You can adapt this file completely to your liking, but it should at least
%   contain the root `toctree` directive.

# TwinCAT3 ライブラリの活用

TwinCATのプロジェクトをパッケージ化し、ライブラリファイルとして配布することで、その中に含まれるファンクションブロック、ファンクション、データ型などが他のプロジェクトでもお使い頂く事が可能になります。

この機能により、プログラム機能を部品化し、複数の開発者間で共有することで開発生産性の大きな向上が期待できます。

作成したライブラリをチームでご活用いただくには、次の要件が欠かせません。

* ライブラリの開発と、そのライブラリを読み込むプロジェクト間でそれぞれのバージョンの依存性を解決すること。
* ライブラリが提供する機能にどのようなものがあり、どうすれば使えるのか、ドキュメントを整備すること。

本節ではこれらの要件を満たすTwinCAT 3のライブラリ管理機能の使い方について説明します。

```{toctree}
:caption: 目次

use_library
make_library
documentation
```

