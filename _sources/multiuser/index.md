(section_multiuser)=
# マルチユーザ機能

[Infosys サイトリンク](https://infosys.beckhoff.com/content/1033/tc3_multiuser/index.html?id=5229654811780766970)

複数の開発者間で共同で開発を行う場合、同一のプロジェクトの変更管理と、互いの開発成果のマージがとても重要です。これを実現する方法として、Visual studio のTeam explorer機能（Git）を用いたプロジェクトリビジョン管理が一般的です。

しかし、Gitを使うには独自のコマンドや概念についての理解が必要です。設備の現場においては、開発者だけでなく保守や調整担当者もソフトウェアを変更する機会が生じます。設備立ち上げからのソフトウェア変更履歴をトラッキングする為には、これらの人員全てがGitの操作スキルを獲得する必要があります。しかしこれは現実的ではありません。

マルチユーザ機能を使うことで、Gitを操作する知識や概念理解が無くとも暗黙的にリビジョン管理を行う事ができます。

マルチユーザ機能では、中央リポジトリはターゲットIPCとなります。開発者はターゲットIPCを通じて変更履歴を共有します。（{numref}`figure_multiuser_overview`）


```{figure-md} figure_multiuser_overview
![](https://infosys.beckhoff.com/content/1033/tc3_multiuser/Images/png/6782225035__Web.png)

マルチユーザ機能のリポジトリイメージ
```


```{admonition} 使用するGitプログラムの切り替え
:class: note

マルチユーザ機能は内部でGitを使用します。このため、TwinCATインストール時にオプションでGitをインストールすることができます。 {ref}`section_install_git` で説明する手順でインストールされたGitがある場合は、これを TwinCAT 3 マルチユーザー機能に使用できます (参照サーバー設定を参照)。
```

```{toctree}
:maxdepth: 2
:caption: 目次

working_multiuser
```
