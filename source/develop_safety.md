(chapter_safety)=
# 開発編（TwinSAFE, 安全機能）

TwinCATで制御上の安全関連部を実装するには、独立した安全コントローラを配置するのではなく、EtherCATネットワークの一部に[EL6910](https://www.beckhoff.com/en-en/products/automation/twinsafe/twinsafe-hardware/el6910.html)に代表される安全ロジックターミナルと、[EL1904](https://www.beckhoff.com/en-en/products/automation/twinsafe/twinsafe-hardware/el1904.html)や[EL2904](https://www.beckhoff.com/en-en/products/automation/twinsafe/twinsafe-hardware/el2904.html)といった安全IOターミナルを混在させます。

EtherCATネットワークのようなシリアルバス内に安全データ（Fail Safe over EtherCAT : FSoE）を組み込んで、安全ロジックと安全IO間のデータ交換を行う事で、 **安全関連部の分散配置** が可能となり、冗長化しがちな配線量の削減が可能となります。

詳細は以下のページをご覧ください。

* [TwinCAT HowTo](https://sites.google.com/site/twincathowto/sefuti-ji-neng?authuser=0)
* [TwinSAFE 製品紹介](https://www.beckhoff.com/en-en/products/automation/twinsafe/?pk_campaign=AdWords-AdWordsSearch-TwinSAFE_EN&pk_kwd=twinsafe&gad_source=1)

ここではよくお問い合わせを受ける内容について特集します。

```{toctree}
:caption: 目次

safety_sync_unit/index.md
```