(section_boot_image)=
## Bootイメージの作成

XAEにより開発されたソフトウェアや各種設定をActive Configurationを行うと、次図の場所に実行モジュールがダウンロードされます。これらをブートイメージと呼びます。

```{figure} develop_history_and_deployment.png
:align: center
```

このブートイメージをファイルとして保存しておくことで、稼働中のTwinCATの環境をバックアップしておくことが可能です。

それだけではなく、同一のIPC, ランタイムモジュール, IO構成であれば、ブートイメージをコピーしてXAEを用いる事なく複製する事が可能になります。

```{warning}
ただし、Windowsにインストールするファンクションや、{ref}`ライブラリインストール<install_library>`が必要なものは別途インストールが必要となります。
```

ただし、ブートイメージには、ネットワークカードのMACアドレスなど幾つかの個体依存の設定が含まれます。この設定汎化したモデルマシン上でブートイメージを取得し、他のマシンへ展開する手順について説明します。

### 個体依存設定の汎化

AMSNetIdやEtherCATマスターの各種設定を機器固有のものではなく汎用的な名前で解決できるように設定したり、起動後プログラムが自動スタートする設定を行います。

次の手順に従い設定を行ってください。

* PLC Projectのオプション設定

   PLCプロジェクトのProject設定画面を開き、次の二つとも有効になっていることを確認する。

   * Symbolic Mapping

   ```{image} 2023-02-22-15-12-48.png
   :align: center
   ```

* AMSNetIDを相対アドレスで解決する設定を有効にする。

   ```{image} 2023-02-20-14-17-27.png
   :align: center
   ```

   ```
   SYSTEM > Routes > [NetId Management] > Use Relative NetIds
   ```

* EtherCATマスターが使用するEthernetポートをMACアドレスではなくシンボル参照にする

   ```{image} 2023-02-20-17-07-34.png
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
   ```

2. マスタとなるプロジェクトをリビルド

   ```{image} 2023-02-24-11-52-57.png
   :align: center
   ```

3. Outputウィンドウでビルドエラーがないことを確認

   ```{image} 2023-02-24-11-54-43.png
   :align: center
   ```

4. プロジェクトをアクティベート ⇒ RUNモード

   ```{image} 2023-02-24-11-55-32.png
   :align: center
   ```

5. 動作テスト実施

   可能であればモデルマシンにて動作テストを実施してください。少なくとも、正常にRUNモードへ移行し、PLCがスタートし、ソフトウェアロジックが正常に機能している事を確認してください。

6. Boot イメージの保存

   PLCのモジュールは、`_Boot`フォルダ、C++モジュールは `_Deployment`フォルダを取り出して保存してください。

   ```
      <<TwinCATプロジェクトフォルダ>>\_Boot
      <<TwinCATプロジェクトフォルダ>>\_Deployment
   ```