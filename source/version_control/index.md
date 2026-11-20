# Gitによる共同開発

TwinCATでチーム開発を行う為の機能が大別して2つ用意されています。どちらも [Git](https://git-scm.com/) をコアに使った機能ですが、用途が異なります。

[ソースコントロール機能](https://infosys.beckhoff.com/content/1033/tc3_sourcecontrol/index.html?id=6468228250695776754)
    : Visual StudioのTeam explorerを用いた、プロジェクト全体のGitによるバージョン管理機能を提供します。PLCの各言語に対する差分ビューワやマージツールと連携し、各リビジョン間の差分を把握する方法を提供します。[Github](https://github.com/)や[Gitlab](https://gitlab.com/)といった任意のリモートリポジトリを通して各開発者が行った個々の開発差分を統合することができます。

    : ```{tip}
      Gitlabはクラウドサービスだけではなく、[独自インストーラ](https://gitlab-docs.creationline.com/ee/install/install_methods.html)にてクローズネットワーク内に配置するなど、オンプレミス運用が可能です。
    
      同様のソフトウェアは他に [Gitea](https://about.gitea.com/) があります。
      ```

[マルチユーザ機能](https://infosys.beckhoff.com/content/1033/tc3_multiuser/index.html?id=5229654811780766970)
    : Gitコマンドや概念を理解することなく、通常の手順でIPCにプログラムを書き込む操作によってIPC上のリポジトリへ各開発者の行ったソースコード差分を統合します。チームで作業を行う場合においても競合する個所の変更を行った際に競合を対話的に解決する手段を提供したり、誰がいつ変更を行ったのか、等の追跡が可能になります。
    
    : 簡単な反面、任意のブランチ管理などの機能はありません。また、リモートリポジトリをIPC以外に選択できないため、実機以外で他の開発者が行った変更差分のマージができません。

    
ここでは、 **ソースコントロール機能** による共同開発手順についてご説明します。マルチユーザ機能については、「{ref}`section_multiuser`」節を参照してください。

```{toctree}
:maxdepth: 2
:caption: 目次

source_control
project_preperation
create_repository
clone_repository
commit
sync
```
