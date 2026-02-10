(section_install_git)=
# 導入

[InfoSys サイトリンク](https://infosys.beckhoff.com/content/1033/tc3_sourcecontrol/index.html?id=6468228250695776754)

## GITのインストール

[https://git-scm.com/install/windows](https://git-scm.com/install/windows) からインストーラをダウンロードしてインストールするか、管理者権限でターミナルを起動してWingetを使ったインストールを行ってください。

```{code} powershell
winget install Git.Git
```

````{tip}
[WingetとはMicrosoft社が提供する公式パッケージ管理ツール](https://learn.microsoft.com/ja-jp/windows/package-manager/winget/)です。Wingetを使ってインストールされたソフトウェアは、インストーラを使わずに一括で最新ソフトウェアにアップグレードすることができます。

```{code}
> winget upgrade --all
```

任意のソフトウェアを探すには `winget search` に続いて、インストールしたいソフトのキーワードを入力します。

```{code}
> winget search git

名前                                  ID                              バージョン   一致     ソース
---------------------------------------------------------------------------------------------------
My Git                                9NLVK2SL2SSP                    Unknown               msstore
Git                                   Git.Git                         2.53.0                winget
Git                                   Git.Git.PreRelease              2.52.0-rc2            winget
Git                                   Microsoft.Git                   2.52.0.0.5            winget
GitTop                                AmarBego.GitTop                 0.4.0        Tag: git winget
RepoZ                                 AndreasWascher.RepoZ            5.5          Tag: git winget
  :                                           :                        :                       :
SoX_ng                                sox_ng.sox_ng                   14.6.0.4     Tag: di… winget
xploview                              xploview.xploview               3.3.31       Tag: di… winget
```

上記に一覧された中の `ID` 列に表記されたものを、 `winget install` に続いて指定してインストールを行います。gitの場合、`Git.Git` がインストール指定のIDとなります。
````

## Git初期設定

Gitのインストールが終わったら初期設定を行います。

まず、あなたの著者としてユーザ名とメールアドレスを設定します。これは、gitの変更履歴に記録される変更を行った開発者の名前として使用されます。

ターミナルを起動して以下のコマンドを順次入力してください。

```{code} powershell
git config --global user.name "あなたの名前（ニックネームも可）"
```

```{code} powershell
git config --global user.email "あなたのメールアドレス"
```

新規作成するリポジトリの既定ブランチ名を main に設定します。公開リポジトリも幹は `main` ブランチですので、`main` と設定します。

```{code} powershell
git config --global init.defaultBranch main
```

```{admonition} Git用Windows向けクライアントソフト TortoiseGit のご紹介
Gitをインストールしただけですと、原則CUI（コマンドユーザインターフェース）のみの機能が提供されます。Windowsエクスプローラに紐づいてGitの操作を行う便利なヘルパーソフトもありますので、必要に応じて以下のリンクからインストールしてください。

[https://tortoisegit.org/](https://tortoisegit.org/)
```

## TwinCATの設定

1. TwinCAT XAEを立ち上げ、`Tools` > `Options` を開きます。ツリーメニューの、 `TwinCAT` > `XAE Environment` > `File settings` を開き、 `Enable Multiple Project Files` を `True` にします。

    ![](assets/2023-05-23-23-10-38.png){width=600px align=center}

2. 続いて `Source Control` > `Plug-in Slection` にて、`Current source control plug-in` を、 `Git` に設定します。

    ![](assets/2023-05-23-23-17-46.png){width=600px align=center}

