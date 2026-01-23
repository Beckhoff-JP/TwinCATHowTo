(chapter_event_logger)=
# イベントロガーとアラーム管理

装置の制御ロジックで発生した様々なインシデントについて、その発生時刻や重大度、および、メッセージをロギングする機構があり、TwinCAT EventLoggerと呼びます。

![](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/Images/png/4992463627__Web.png){align=center}

本章では、PLCプログラム上における異常監視ロジックの実装と、アラームイベントの登録方法、そして全てのアラームの集計や、ブザーやHMIへの表示・制御インターロックへ用いるための一連のデザインパターンをご紹介します。

{ref}`alarm_system_library` 節の実装を独立したライブラリとして保存しておくと、汎用的なアラーム管理フレームワークとして活用いただく事が可能になっています。

## 本フレームワークの特徴

TwinCATが提供するイベントロガーの機能には、アラームとメッセージの二つがあります。メッセージは単なるイベントを記録するだけの機能（ステートレス）ですが、アラームはこれに加えて状態を持ちます。（ステートフル）

![](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/Images/png/4318234251__Web.png){align=center}

まず、該当アラームが発生中か否か、という状態を持ちます。

![](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/Images/png/5286741131__Web.png){align=center}

また、アラームが発生して、未だ制御対象の機械のオペレータがそのアラームに気付いていない状態と、確認済みの状態を持ちます。

![](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/Images/png/5290627339__Web.png){align=center}

TwinCATの提供するファンクションブロック[`FB_TcEventLogger`](https://infosys.beckhoff.com/content/1033/tc3_eventlogger/5002818315.html?id=6803183681524141353)の中には、アラームの状態などを集計して監視する機能はあるのですが、上記の未確認アラームの有無や、重要度を指定した細かなクエリ機能までは用意されていません。

本フレームワークはこれらの機能を実現すると共に、Raise/Not Raisedの状態遷移時のイベントハンドラを実装する事で様々なメディアに対する履歴記録機能を提供します。

```{toctree}
:maxdepth: 2
:caption: 目次

make_user_event
plc_api
sample
windows_event_logger
```
