# TwinCAT Build 4026 のセットアップ

TwinCAT Build 4026 の環境セットアップに関する情報をご提供します。次の手順で読み進めてください。

1. パッケージマネージャのインストールと基本設定

    本章の{ref}`section_package_manager_startup` をお読みの上、パッケージマネージャのインストールと基本設定を行ってください。

2. ユーザモードランタイムのセットアップ

    Windows 11からは、VBS（仮想化ベースのセキュリティ）の機能によって、カーネルモードでTwinCATのラインタイムを動作させることが困難になりました。これにより、TwinCAT XAEで開発したプロジェクトを、開発用のコンピュータ上でシミュレーションすることが難しくなりました。

    代替案として、ユーザモードでランタイムを動作させるTC1700（Usermode runtime）をお使いいただく必要があります。{ref}`chapter_usermode_runtime` の章を参照の上、ユーザモードランタイムを稼働させてください。

3. 必要なパッケージ類のインストール

    まずは、{ref}`section_package_manager_gui_ope` をお読みいただき、GUIのパッケージマネージャをお使いいただき、IPCのランタイム、および、開発環境、双方必要な環境を整えてください。

    その後、他の開発チーム内で同一環境を展開したり、量産装置等で他のIPCへおなじパッケージ構成を展開する場合は、`export` や `import` というコマンドを用いてインストール作業を自動化することができます。
    
    この場合、作業はGUIではなくコマンドインターフェースによるパッケージ操作で行う方がPowershellなどのスクリプトによって自動化しやすく、現場展開が容易になります。併せて {ref}`section_package_manager_cli_ope` や、 {ref}`section_package_manager_offline_install` をご覧ください。
    
```{toctree}
:caption: 目次

package_manager
package_manager_gui_ope
package_manager_cli_ope
offline_install
remote_manager
```