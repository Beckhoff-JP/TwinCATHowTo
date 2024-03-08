## Bootイメージの作成

展開先に配布するソフトウェアを作成するには、展開先のターゲットマシンと同一のハードウェア構成を持つIPCが一台必要です。これを「モデルマシン」と呼びます。モデルマシンに接続した開発環境において取得したPLCランタイムモジュール、C++ランタイムモジュールを「Bootイメージ」と呼びます。次図に示す通り展開先のIPCにコピーすることでソフトウェアの展開ができます。

```{figure} develop_history_and_deployment.png
:width: 700px
:align: center
```

Bootイメージの作成方法は次の手順となります。

```{blockdiag}
blockdiag {
   "デプロイ設定" -> "ビルド" -> "動作テスト" -> "Bootイメージの取り出し";
}
```

### デプロイ設定

デプロイ設定とは、展開先IPCに配置に適した状態に設定することを言います。AMSNetIdやEtherCATマスターの各種設定を機器固有のものではなく汎用的な名前で解決できるように設定したり、起動後プログラムが自動スタートする設定を行います。

次の手順に従い設定を行ってください。



* PLC Projectのオプション設定

   PLCプロジェクトのProject設定画面を開き、次の二つとも有効になっていることを確認する。

   * Autostart Boot Project
   * Symbolic Mapping

   ```{image} 2023-02-22-15-12-48.png
   :width: 600px
   :align: center
   ```

* AMSNetIDを相対アドレスで解決する設定を有効にする。

   ```{image} 2023-02-20-14-17-27.png
   :width: 600px
   :align: center
   ```

   ```
   SYSTEM > Routes > [NetId Management] > Use Relative NetIds
   ```

* EtherCATマスターが使用するEthernetポートをMACアドレスではなくシンボル参照にする

   ```{image} 2023-02-20-17-07-34.png
   :width: 600px
   :align: center
   ```

   ```
   I/O > EtherCAT Master Device > [Adapter] > Virtual Device Names
   ```


### ビルド～Bootイメージの取り出し

展開先ターゲットマシンと同一ハードウェア構成のモデルマシンに接続されたXAE環境において、次の手順を実施いただく事で、展開するファイルが取得できます。

```{admonition} 警告
:class: warning

* モデルマシンに開発環境（XAE）で用いるPLCプロジェクトファイルは、展開先のIPCのハードウェアと完全に一致したものを使用してください。
* かならず Active configurationとRUNモードへの移行を確認してください。
```

1. Target Systemで<ダミーターゲット>、SolutionPlatformで<TwinCAT RT(x86)>を選択する

   ```{image} 2023-02-24-11-52-00.png
   :align: center
   :width: 600px
   ```

2. マスタとなるプロジェクトをリビルド

   ```{image} 2023-02-24-11-52-57.png
   :align: center
   :width: 600px
   ```

3. Outputウィンドウでビルドエラーがないことを確認

   ```{image} 2023-02-24-11-54-43.png
   :align: center
   :width: 600px
   ```

4. プロジェクトをアクティベート ⇒ RUNモード

   ```{image} 2023-02-24-11-55-32.png
   :align: center
   :width: 600px
   ```

5. 動作テスト実施

   可能であればモデルマシンにて動作テストを実施してください。少なくとも、正常にRUNモードへ移行し、PLCがスタートし、ソフトウェアロジックが正常に機能している事を確認してください。

6. Boot イメージの保存

   PLCのモジュールは、`_Boot`フォルダ、C++モジュールは `_Deployment`フォルダを取り出して保存してください。

   ```
      <<TwinCATプロジェクトフォルダ>>\_Boot
      <<TwinCATプロジェクトフォルダ>>\_Deployment
   ```