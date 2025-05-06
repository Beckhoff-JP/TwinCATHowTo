(chapter_automation_interface_powershell)=
# PowershellによるAutomation Interfaceを使ったプロジェクト更新の自動化

{ref}`section_auto_deploy` 節では、ターゲットIPC内のWindowsのファイルシステム内（Bootフォルダ）に対してイメージを直接書き込む方法でした。この節では、ファイル操作ではなくTwinCAT XAEとその操作を自動化する [TwinCAT Automation Interface](https://infosys.beckhoff.com/content/1033/tc3_automationinterface/242682763.html?id=5107059583047685772)の機能を使ってプロジェクトを自動更新する方法をご紹介します。

[TwinCAT Automation Interface](https://infosys.beckhoff.com/content/1033/tc3_automationinterface/242682763.html?id=5107059583047685772)とは.NETを用いてさまざまな言語からTwnCAT XAEを操作する仕組みです。

![](https://infosys.beckhoff.com/content/1033/tc3_automationinterface/Images/png/242959243__en-US__Web.png){align=center}

本節では、このうちPosershellを用いる方法でTwinCATプロジェクトを、XAEの操作無しに設備へ展開する方法をご紹介します。 {ref}`chapter_powershell_ads_data_access` でご紹介する事例は Automation Interface ではなくADSライブラリですが、プロジェクトをPowerShellで展開した後に初期データを書き込むために必要な手法ですので、併記いたします。

```{toctree}

auto_deploy
../powershell_data_edit/index
```