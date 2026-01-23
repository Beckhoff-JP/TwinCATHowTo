# PythonとADSを用いたIoT実装例

TwinCATには様々な通信手段が用意されていますが、最も汎用的でライセンスが不要な通信手段はADSです。ADSプロトコルはオープンな仕様で、[通信用のC++ライブラリ](https://github.com/Beckhoff/ADS)をはじめ、様々な言語へのポーティングが公開されています。

今回は、このライブラリを用いてPythonへポーティングされた[pyads](https://pyads.readthedocs.io/)を用いてPythonによるTwinCATとの通信方法についてご紹介します。

## Githubサンプルコード

250 $\mu s$ のサイクルタイムのPLCタスクの変数データをNotificationで収集するサンプルコードです。詳細はGithubのREADME.MDをご覧ください。

[https://github.com/Beckhoff-JP/Python_ADS_Sample](https://github.com/Beckhoff-JP/Python_ADS_Sample)