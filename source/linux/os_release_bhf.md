# OSのセキュリティアップデートに関する情報について

現在インストール済みのパッケージにどのような問題が含まれているのかを調べる方法についてご説明します。

## パッケージ監査

Beckhoff RT Linux®には、インストール済みのソフトウェアに既知の脆弱性がないかを確認できるdebsecanというツールが用意されています。`debsecan --suite trixie`コマンドを実行すると、既知の脆弱性に関する情報とローカルにインストールされているパッケージが比較されます。その結果、CVE（共通脆弱性識別子）番号と、影響を受けるパッケージに関する情報が表示されます。

debsecan のインストールは以下のコマンドを発行してください。

```{code} bash
sudo apt install debsecan
```

下記のコマンドを発行することで、1画面づつスクロール可能です。上下カーソルキーで行送り、戻しが可能となります。
このコマンドによって、インストール済みのパッケージの現在バージョンとどのバージョンで修正されるのかと共に、公表されている脆弱性が一覧されます。

```{code} bash
debsecan --suite trixie | grep "high urgency"
```

また、修正版が提供可能なものだけを表示するには次のコマンドとなります。

```{code} bash
debsecan --suite trixie --only-fixed | grep "high urgency"
```

```{warning}
debsecan の結果に linux-image-* などのカーネル関連パッケージが含まれる場合がありますが、Beckhoff RT Linux は独自の PREEMPT_RT カーネルを採用しています。標準の Debian カーネルへ意図せず切り替わらないよう、このコマンドの結果を使って自動的にアップグレードを行うスクリプトは組まないでください。
```

## Linuxカーネルの監査

Beckhoff製品および、Beckhoff RT LinuxカーネルはDebianパッケージではないため、debsecanでは問題は一覧されません。

* [Advisories](https://infosys.beckhoff.com/content/1033/ipc_security/976057355.html?id=8613544776192728862)
* [RSS feed](https://www.beckhoff.com/en-en/company/news/rss-feeds/rss-ipc-security/beckhoff_ipc_security_rss_feed.xml)


なお、現在インストールされているカーネルのバージョンを調べるには、`apt info os-release-bhf` コマンドを発行します。`Version` 欄をご確認ください。

```{code} bash
sudo apt info os-release-bhf
[sudo] password for Administrator:
Package: os-release-bhf
Version: 13.0.440542-1
Priority: optional
Section: bhf
Maintainer: Beckhoff Automation GmbH & Co. KG <info@beckhoff.com>
Installed-Size: 33.8 kB
Download-Size: 7792 B
APT-Manual-Installed: yes
APT-Sources: https://deb.beckhoff.com/debian trixie-stable/main amd64 Packages
Description: Contains the build pipeline-id
 Installs /etc/os-release.d/666-bhf which includes the pipeline id the package
 was build from.
```

