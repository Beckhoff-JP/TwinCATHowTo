% TwinCAT開発におけるプログラム標準化マニュアル documentation master file, created by
%  sphinx-quickstart on Tue Feb 21 11:50:42 2023.
%   You can adapt this file completely to your liking, but it should at least
%   contain the root `toctree` directive.

(chapter_dev_ops)=
# DevOps開発環境構築

特にクラウドコンピューティングにおいては、DevOpsという概念が注目されています。例えばソフトウェアの構成管理にGithubおよびそのマージシステムを用いて開発フローをIT上で完結させます。必要なプログラムコードが集まった後は、CI/CDと呼ばれるビルド・テスト・ターゲットマシンへのデプロイまでの開発工程を自動化する仕組みが提供されます。DevOpsはこれらを包括した概念です。これにより、開発者は開発に専念する事ができ、現場ニーズに適した機能を短期間で提供することが可能となり、生産性の向上に役立ちます。

産業用の制御ソフトウェアにおいてこの仕組みを活用するには、次の課題を克服する必要があります。

* モジュール開発フェーズ
    * ライブラリ管理システムとそれを活用する開発フローの標準化
    * GitやGithubなどを使ったマージシステム
    * 単体テスト（ファンクションやファンクションブロック単体でのテスト）の自動化
* 結合・デプロイフェーズ
    * ハードウェアのシミュレーション
    * 結合テスト（負荷を含めたアプリケーションとしてのテスト）の自動化
    * 自動デプロイシステム

```{toctree}
:caption: 目次

../version_control/index.md
../multiuser/index.md
../library/index.md
../simulation/index.md
../usermode_runtime/index.md
```

```{admonition} FAエンジニアリングもクラウドベースへ - TwinCAT Cloud Engineeringのご紹介
:class: note

TwinCAT Cloud Engineeringは、2020年に発表されたクラウド上でXAEとユーザモードXARを動作させるコンテナ技術です。

このコンテナ上では、 {numref}`section_iot_overview` にてご紹介している TE3500 Analytics Workbench により生成されたTF3550 Analytics runtimeのロジックを動作させることができ、世界中の設備で動作するIPCの制御サイクル周期で収集したデータを使ったダッシュボード表示や監視が可能になります。

それだけではなく、TC1700 Usermode runtime、そして、Githubなどの技術と組み合わせることで、クラウド上における自動ビルドとテスト、また、エッジIPCへの自動デプロイを可能にする、CI/CD環境を提供します。

この二つにより、設備の稼動状況を把握して最適な制御を切れ目なく実機に提供する、いわゆるDevOps環境が実現できます。

[![](assets/2023-06-05-15-02-59.png)](https://www.beckhoff.com/ja-jp/products/automation/cloud-engineering/)

このような、ITの世界で取り入れられているフレームワークを制御コンピューティング環境でお使いいただけるのも、PC制御であるTwinCATの強みとなります。本章でご説明する機能群はその中核を成すものですので、ぜひとも未来に向けて触れていただければ幸いです。
```