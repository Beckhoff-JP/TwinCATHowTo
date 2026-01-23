# ライセンスレスポンスファイルの再発行

TwinCAT XAE のプロジェクトフォルダ構成において、TwinCATプロジェクト階層直下には `*.tclrs` というファイルが生成されています。これは、すでにお買い上げいただいたIPCのライセンスや、追加で購入されたライセンスを有効化するため、Beckhoff社のライセンスサーバから取得したレスポンスファイルと呼ばれるおのです。

このファイルを誤って削除してしまった場合、ターゲットIPCにてご購入済みのライセンスが無効化された状態となってしまいます。このような場合、次の手順でライセンスレスポンスファイルを再発行することができます。

```{warning}
本手順は、ライセンスドングル、および、ライセンスターミナルではご使用いただけません。IPC本体に紐づけたライセンスのみ適用可能です。

これらのメディアをお使いの場合でバックアップを取得することなく誤って`Clear Dongle Storage` 操作などを行ってライセンス情報を失ってしまった場合の復元は本手順では実施いただけません。弊社サービス窓口へお問い合わせください。
```

```{tip}
参考
    : [InfoSys : Re-retrieving the License Response File and license certificate from the license server](https://infosys.beckhoff.com/content/1033/tc3_licensing/7905289739.html?id=5011087096973693646)
```


1. 空のTwinCATプロジェクトを作成し、ターゲットIPCに接続します。

   ```{note}
   PLCプロジェクトも作成しないでください。
   ```

2. ソリューションツリーから `SYSTEM` - `LICENSE` を開き、次の設定としてください。

   * License Deviceを `Target (Hardware Id)` を確認してください。
   * License Id欄には、 `Restore` と入力します。
   * ライセンス一覧には、`TC1000 TC3 ADS` のみ表示されている状態とします。

   ![](assets/2026-01-20-10-12-15.png){align=center}

3. `Generate File...` ボタンを押して、`TLR_BI_Restore.tclrq` ファイルを保存します。
   ```{note}
   このあと、`Send license request to Beckhoff` というダイアログが現れます。おつかいのPCの電子メールソフトがOS上で適切に構成されている場合は、そのまま はい(Y) を押してください。
   これにより保存した`TLR_BI_Restore.tclrq`をBeckhoff社のライセンスサーバ [TCLicense@beckhoff.com](mailto:tclicense@beckhoff.com) に添付されたメール作成をアシストしてくれます。いいえを押した場合、次のステップのとおり手動でメールを作成してリクエストファイルを添付して送信してください。
   ```
4. 保存した`TLR_BI_Restore.tclrq`を [TCLicense@beckhoff.com](mailto:tclicense@beckhoff.com) に添付して送信してください。タイトル、本文は空白のままで構いません。
5. しばらくするとレスポンスファイルが添付されたメールが、`TwinCAT Licensing Services` より届きます。添付されたレスポンスファイルを保存します。
6. 実際の稼働させるTwinCATプロジェクトを開き、ターゲットIPCに接続した状態でソリューションツリーから `SYSTEM` - `LICENSE` を開きます。
7. Order Infromationタブの、`License Response File...` ボタンを押して、レスポンスファイルを読み込ませてください。
8. レスポンスファイルを読み込ませたあとは `Restart TwinCAT (Config Mode)` ボタン押してください。購入済みのライセンスが `Valid` となることをご確認ください。

