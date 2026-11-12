# TwinCAT 3 ADS通信 開発環境・セキュリティ構成

## 1. 概要
TwinCAT 3のADS（Automation Device Specification）通信を用いたアプリケーション開発において、ターゲットOS・開発言語ごとに必要な環境と、トランスポート層（TCP / MQTT）別のTLSセキュリティ対応状況・暗号化範囲をまとめました。
Windows環境については、**Build 4024** と **Build 4026** で導入方法が大きく異なるため場合分けして記載しています。

---

## 2. 通信方式別の特徴とTLS暗号化（セキュア通信）の可否

ADS通信はトランスポート層として **TCP** または **MQTT** を選択でき、いずれも **TLS（Transport Layer Security）** による暗号化・認証に対応しています（TwinCAT 3.1 Build 4024以降）。

| 通信方式 | プロトコル / 標準ポート | TLS暗号化（セキュア通信）の可否 | 暗号化の範囲と通信の特徴 |
| :--- | :--- | :--- | :--- |
| **標準 ADS (TCP)** | TCP / **48898** | **不可**（平文通信） | 閉域の制御ネットワーク（OT）内での高速・低遅延通信向け。 |
| **Secure ADS (TCP)** | TCP + TLS 1.2 / **8016** | **可能**（PSK / X.509証明書） | 端末間で1対1のTCP+TLS接続を確立（トランスポート暗号化）。 |
| **ADS-over-MQTT** | MQTT (TCP) / **1883** | **不可**（平文通信） | ブローカーを介した1対多通信、NAT越え、クラウド連携向け。 |
| **ADS-over-MQTT (with TLS)** | MQTTS (TLS 1.2) / **8883** | **可能**（PSK / X.509証明書） | **「各端末 ⇔ MQTTブローカー間」** をTLS暗号化。インターネット越え・クラウド連携の標準構成。 |
| **TLS-over-ADS-over-MQTT**<br>*(ペイロードのE2E暗号化)* | MQTT上のADSペイロードをさらにTLS化 | **標準機能では不可** | ブローカー内部ではTLSが終端され、ブローカー上のADSコマンドは平文で扱われる仕様のため。 |

### セキュリティ設計上の重要ポイント（ADS-over-MQTTのTLS仕様）
* **暗号化される区間**: [Beckhoff公式ドキュメント（ADS-over-MQTT Security）](https://beckhoff.com "Beckhoff Information System ADS-over-MQTT Security") の仕様上、TLSは **「TwinCATルーター（またはクライアント） ⇔ MQTTブローカー間」の通信経路（MQTTS）** を保護します。
* **ブローカーの信頼性要件**: TLSを使用しても **MQTTブローカー上ではADSフレーム（コマンドや変数データ）が平文でルーティング** されます。そのため、ブローカー自体は信頼できるサーバー（自社管理のMosquittoや適切なACLを設定したAWS IoT Core / Azure IoT Hub等）で運用する必要があります。
* **ブローカーを含めた完全なE2E暗号化が必要な場合**: 標準のADS-over-MQTTでは実現できないため、VPN（IPsec / WireGuard等）によるネットワーク層のトンネル化、またはアプリケーション側での独自暗号化を併用してください。

---

## 3. OS別の基盤環境（ランタイム・ルーター）

OS側にADSルーターを常駐させる場合、ルーター自体が **Secure ADS** および **ADS-over-MQTT (with TLS)** のエンドポイントとして機能します。

| 対象OS | ビルド / 区分 | 準備すべきパッケージ / インストーラー | 役割・導入方式とTLS / MQTT対応状況 |
| :--- | :--- | :--- | :--- |
| **Windows** | **Build 4024** | **TC1000** (`TC31-ADS-Setup.3.1.4024.xx.exe`)<br>※開発機は `TC31-Full-Setup` 等でも可 | 従来の単体インストーラー（`.exe`）を実行して導入。`StaticRoutes.xml` により **Secure ADS (8016)** と **ADS-over-MQTT with TLS (8883)** に対応。 |
| **Windows** | **Build 4026** | **[TwinCAT Package Manager](https://beckhoff.com "TwinCAT 3.1 Build 4026 ベッコフ")** 経由で<br>**`TC1000` ワークロード**（または `TwinCAT.XAR.ADS` 等の関連パッケージ）を導入 | 単体 `.exe` は廃止。GUIのPackage ManagerまたはCLI（`tcpkg`）からmyBeckhoff認証でフィード接続しインストール。ルーター機能は4024同様に両方式へ対応。 |
| **Beckhoff RT Linux®** | Build 4024 / 4026 | **`tc31-xar-um`**（ルーター・サーバー用途）<br>または **`adstool`**（クライアント用途のみ） | `tc31-xar-um` のシステムサービス（`TcSystemServiceUm`）はWindows版と同様に **Secure ADS** と **ADS-over-MQTT (with TLS)** のルーター機能に対応。 |
| **汎用 Linux**<br>(Ubuntu / Debian等) | ― | 基盤パッケージの事前導入は不要<br>（各言語のライブラリ側で実装） | OS標準のルーターは存在しないため、各言語のライブラリ（.NET等）が持つTCP/MQTTスタックで直接TLS通信を行う。 |
| **TwinCAT/BSD**<br>(FreeBSDベース) | Build 4024 / 4026 | OS標準搭載（`TcSystemServiceUm`）<br>※パッケージ管理は `pkg` を使用 | OS組み込みのADSルーターが **Secure ADS** および **ADS-over-MQTT (with TLS)** に対応。 |

### Windows Build 4024 と Build 4026 の運用上の違い（注意点）
* **同一PCへの混在不可**: 1台のWindows PCに Build 4024 と Build 4026 のランタイム／ルーター（TC1000含む）を同時にインストールすることはできません（4024環境があるPCへ4026を入れる場合はマイグレーションが必要になります）。
* **通信の相互互換性**: ADSプロトコル自体は上位・下位互換性があるため、**開発PC側が Build 4026（TC1000）で、接続先PLC側が Build 4024**（またはその逆）であっても、TCP・Secure ADS・ADS-over-MQTTのいずれも問題なく通信可能です。
* **Visual Studio対応**: 開発機としてXAEも同居させる場合、Build 4024は32bit版Visual Studio（VS 2019以前）、Build 4026は64bit版Visual Studio（VS 2022）に対応します。

---

## 4. 言語・ライブラリ別の開発環境とTLS/MQTT対応状況

### ① C# / .NET（最も推奨：全方式・全OSにフル対応）
最新の公式マネージドライブラリは、OSのADSルーター（および4024/4026のローカルインストール）に依存せず単体でTCP・Secure ADS・MQTT（TLS）のすべてを扱えます。

* **使用ライブラリ**:
  * **`Beckhoff.TwinCAT.Ads`**（NuGet / v6.x 以降）：TCP および **Secure ADS (TLS 8016)** 対応
  * **`Beckhoff.TwinCAT.Ads.Mqtt`**（NuGet）：**ADS-over-MQTT** および **MQTTS (TLS 8883)** 対応
* **準備するもの**:
  1. .NET SDK（.NET 6 / .NET 8 以降推奨）
  2. NuGetから上記パッケージを追加
* **TLS / MQTT 可否**:
  * **TCP (TLS 8016)**: **対応**（PSKまたはX.509証明書を指定して直接接続可能）
  * **MQTT (TLS 8883)**: **対応**（ブローカーのURL・TLS証明書・認証情報を指定して直接接続可能）

### ② C / C++
使用するAPIによってTLSおよびMQTTの対応範囲が大きく異なります。

* **パターンA：Windows 従来型API（ローカルルーター経由）**
  * **使用ライブラリ**: `TcAdsDll`（`TcAdsDef.h`, `TcAdsAPI.h`, `TcAdsDll.lib`）
  * **準備するもの（ビルド別）**:
    * **Build 4024の場合**: `TC31-ADS-Setup.3.1.4024.xx.exe` を実行し、`C:\TwinCAT\AdsApi\TcAdsDll\` 等のパスを参照。
    * **Build 4026の場合**: **TwinCAT Package Manager** で `TC1000` ワークロード（C++ヘッダ・ライブラリ含む）をインストールし、`C:\Program Files (x86)\Beckhoff\TwinCAT\...` 等の配置パスを参照。
  * **TLS / MQTT 可否**: **対応（ローカルルーター依存）**。アプリ側は通常のADS APIを呼ぶだけで、背後のTwinCATルーター設定（`StaticRoutes.xml`）側で **Secure ADS (TLS)** や **ADS-over-MQTT (with TLS)** に変換して通信可能。
* **パターンB：Linux / Windows オープンソース版（ルーター不要）**
  * **使用ライブラリ**: **Beckhoff AdsLib**（GitHub: [`Beckhoff/ADS`](https://github.com "Beckhoff/ADS GitHub repository")）
  * **準備するもの**: `Beckhoff/ADS` ソースコード（または `libads-dev`）、`Meson`, `Ninja`, `g++`
  * **TLS / MQTT 可否**: **原則不可（標準TCP 48898のみ）**。`AdsLib` 単体にはTLSやMQTT機能がないため、暗号化が必要な場合はVPN/SSHトンネルを併用するか、OS側にルーター（Windows TC1000 / Linux `tc31-xar-um`）を入れてローカルルーター経由で通信する構成が必要。

### ③ Python
オープンソースのラッパーライブラリを使用します。

* **使用ライブラリ**: **`pyads`**（`pip install pyads`）
* **準備するもの**:
  * Python 3.8 以降
  * **Windowsの場合（ビルド別）**:
    * **Build 4024**: `TC31-ADS-Setup`（TC1000）をインストール（内部で `TcAdsDll.dll` をロード）。
    * **Build 4026**: **TwinCAT Package Manager** で `TC1000` ワークロードをインストール（`TcAdsDll.dll` の配置ディレクトリが環境変数PATHに通っていることを確認）。
  * **Linuxの場合**: 追加パッケージ不要（同梱の `adslib.so` を使用）。
* **TLS / MQTT 可否**:
  * **Windows環境（4024 / 4026共通）**: **対応（ローカルルーター依存）**。内部で `TcAdsDll.dll` を呼ぶため、Windows側のTwinCATルーターで **Secure ADS (TLS)** や **ADS-over-MQTT (with TLS)** のルートを設定しておけば透過的に利用可能。
  * **Linux環境**: **原則不可（標準TCP 48898のみ）**。同梱の `adslib.so` がTLS・MQTTに非対応のため。Linux上のPythonからTLS/MQTTでADS通信したい場合は、同機上に `tc31-xar-um`（ADSルーター）を立ててローカル接続する構成が必要。

---

## 5. 構成選定のまとめ（早見表）

1. **クラウド連携やファイアウォール越えで、TLS暗号化（MQTTS 8883）を使いたい場合**
   * **C# (.NET 8)** で `Beckhoff.TwinCAT.Ads.Mqtt` を使用するのが最もシンプルでOSやTwinCATビルド（4024/4026）に依存しません。
   * **Python / C++** で実現したい場合は、クライアント端末に `TC1000`（Windows 4024は `.exe` / 4026は `Package Manager`）または `tc31-xar-um`（RT Linux）をインストールし、ローカルのADSルーターにMQTTブローカーへのTLS接続（PSKまたはX.509証明書）を担わせてください。
   * ※いずれも **MQTTブローカー自体は信頼できる管理下に置く** ことが必須条件です。
2. **工場内ネットワークで、ルーターレスかつセキュア（TCP TLS 8016）に通信したい場合**
   * **C# (.NET 8)** の `Beckhoff.TwinCAT.Ads`（v6以降）を使用してください。
3. **Linux上で Python (`pyads`) や C++ (`AdsLib`) を単体で動かす場合**
   * 通信は **非暗号化の標準TCP（ポート 48898）** となるため、ネットワーク層（閉域網、IPsec VPN、WireGuard等）でセキュリティを担保してください。
