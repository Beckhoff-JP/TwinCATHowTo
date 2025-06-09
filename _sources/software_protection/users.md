# ユーザ管理

ここまでで、グループおよび権限が設定し終わっていますので、認証ユーザを追加します。

## ユーザの追加

まずは、{numref}`protection_menu` メニューを選択し、Software Protectionウィンドウを開いてください。

:::{figure-md} protection_menu
![](assets/2023-05-15-13-38-59.png){align=center width=350px}

TwinCATメニューのSoftware Protection
:::

`Users` タブの `Add...`ボタンを押します。

![](https://infosys.beckhoff.com/content/1033/tc3_security_management/Images/png/9007206982010891__en-US__Web.png){align=center width=600px}

Edit User Credentials ウィンドウが現われたら、Name: 欄にユーザ名を、Groups: に所属グループを設定します。複数グループ設定した場合、そのグループに与えられた権限が全て与えられます。（OR条件）

![](https://infosys.beckhoff.com/content/1033/tc3_security_management/Images/png/9007206982012555__en-US__Web.png){align=center width=500px}

OKボタンを押すと、追加したユーザのパスワード設定画面が現われます。登録パスワード、および、確認パスワードを入力してください。

![](assets/2023-05-15-17-39-17.png){align=center width=450px}