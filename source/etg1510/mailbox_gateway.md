# Debian 13 (Trixie) パケットルーティング・NAT 設定構築レポート

## ネットワーク環境・要件
本構成は、Debian マシンをルーター（ゲートウェイ）として機能させ、外部ネットワークから内部（LAN）側の特定サーバーへ、特定の UDP パケットのみを限定してポートフォワーディング（DNAT）および送信元マスカレード（SNAT）を行うものです。

### ネットワーク構成
* **外部・上位ネットワーク (eno1):** `192.168.3.10/24`
  * 外部クライアント (検証機): `192.168.3.9`
* **内部・LAN側ネットワーク (tap2s0):** `192.168.4.1/24`
  * ターゲット（内部サーバー）: **`192.168.4.254`**
* **許可対象プロトコル・ポート:** **`UDP 34980`**

### 実装方針
既存の親設定ファイル（`/etc/nftables-bhf.conf` 等）のファイアウォールルールによるパケット破棄を回避するため、nftables の **`priority`（優先度）を標準より高く設定した独立テーブル（特急レーン）** を作成し、競合を防ぎます。

---

## 構築手順

### Linux カーネルの IP フォワーディング有効化
OS レベルでインターフェース間のパケット転送を許可します。

1. 設定ファイル（例: `60-routing.conf`）を新規作成します。
   ```bash
   sudo nano /etc/sysctl.d/60-routing.conf
   ```
2. 以下の内容を記述して保存します。
   ```ini
   # IPv4 のパケット転送を有効化
   net.ipv4.ip_forward=1

   # IPv6 のパケット転送を有効化（必要に応じて）
   net.ipv6.conf.all.forwarding=1
   ```
3. 設定をシステムに即座に反映します。
   ```bash
   sudo systemctl restart systemd-sysctl
   ```
   *(確認コマンド: `sysctl net.ipv4.ip_forward` を実行し `1` が返れば成功)*

---

### nftables のインストールと有効化
Debian Trixie 標準のネットワークフィルタリングツールを準備します。

```bash
sudo apt update && sudo apt install nftables -y
sudo systemctl enable --now nftables
```

---

### 方法1 : 単純なルーティング設定

`eno1` に届いたIPを `tap2s0` にも転送する設定を行います。 

#### nftablesの設定

新規に `/etc/nftables.conf.d/60-eoe.conf` を作成して次の通り定義してください。

``` nginx
table ip my_pure_router {
    chain forward {
        type filter hook forward priority filter; policy drop;

        # 1. 確立済みの通信（戻りパケットなど）を許可
        ct state established,related accept

        # 2. eno1から入ってtap2s0へ向かう新規パケットのみを許可
        iifname "eno1" oifname "tap2s0" ct state new accept
    }
}
```

設定が正しいか以下のコマンドでチェック

``` bash
$ sudo nft -c -f /etc/nftables.conf
```

エラーがでなければ、次のコマンドで設定を反映します。

``` bash
$ sudo nft -f /etc/nftables.conf
```

#### Windows側のルーティング設定

EoEネットワークはクライアント側で、EoE以下に構成された接続先のノードが `192.168.4.***` ネットワークとなっており、外部から接続する際の接続先のIPCのIPアドレス `192.168.3.10` とした場合のルーティング設定

``` powershell
route add 192.168.4.0 mask 255.255.255.0 192.168.3.10
```

### 方法2 : NAT付きルーティング設定方法

接続先が単一で、UDPポート `34980` ということが分かっている場合、クライアント側のルーティング設定が不要となるよう、NAT設定を行います。たとえば単一のEtherCATメインデバイスのMailbox gatewayに接続する場合は、EtherCATメインデバイスの仮想インターフェースである `tap2s0` のUDPポート34980です。仮想インターフェース `tap2s0` に割り当てたIPアドレスが`192.168.4.1`で、その接続先の Mailbox gateway のIP設定が `192.168.4.254` の設定の場合、次のとおりNAT設定を行うことで、外部から `eno1` アダプタを経由して、直接 UDP port 34980 で接続することが可能となります。

1. 対象の設定ファイル（例: `/etc/nftables.conf.d/60-ecmbgateway.conf`）を編集します。
   ```bash
   sudo nano /etc/nftables.conf.d/60-ecmbgateway.conf
   ```
2. 以下の設定（全文）を貼り付けて保存します。
   ```nginx
   # -------------------------------------------------------------
   # 1. 宛先NAT（ポートフォワーディング）設定
   # -------------------------------------------------------------
   table ip ecmb_force_nat {
       chain prerouting {
           # 標準の dstnat よりも高い優先度 (dstnat - 10) で最速実行
           type nat hook prerouting priority dstnat - 10; policy accept;

           # eno1 に届いた 34980/udp を 192.168.4.254 へ強制転送（ログ付き）
           iifname "eno1" udp dport 34980 log prefix "[FORCE-DNAT] " dnat to 192.168.4.254
       }
   }

   # -------------------------------------------------------------
   # 2. パケット転送（フォワード）の最優先許可設定
   # -------------------------------------------------------------
   table inet ecmb_force_filter {
       chain forward {
           # 標準の filter よりも高い優先度 (filter - 10) で最速実行
           type filter hook forward priority filter - 10; policy accept;

           # 転送対象パケットを最優先で通過許可（ログ付き）
           iifname "eno1" oifname "tap2s0" ip daddr 192.168.4.254 udp dport 34980 log prefix "[FORCE-FORWARD] " accept
       }
   }

   # -------------------------------------------------------------
   # 3. 送信元NAT（マスカレード）設定
   # -------------------------------------------------------------
   table ip nat {
       chain prerouting {
           type nat hook prerouting priority dstnat; policy accept;
       }

       chain postrouting {
           type nat hook postrouting priority srcnat; policy accept;

           # 内部セグメントから eno1(外部) へ出ていくパケットをマスカレード（IP変換）
           ip saddr 192.168.4.0/24 oifname "eno1" masquerade
       }
   }
   ```

3. nftables サービスを再起動し、設定を適用します。
   ```bash
   sudo systemctl restart nftables.service
   ```

---

## 動作確認・トラブルシューティング手法

設定適用後、通信が正常に行われているか、またはトラブル時にどこでパケットが止まっているかを追跡するコマンド群です。

### ① nftables 内部ログのリアルタイム監視
設定ファイルに仕込んだ `log prefix` により、パケットが制限を通過した瞬間のログを監視できます。
```bash
sudo journalctl -fu nftables.service | grep FORCE
```
* **正常時の出力例:** `[FORCE-DNAT]...` と `[FORCE-FORWARD]...` の両方が順に出力されれば、Debian 内の処理は正常に完了しています。

### ② カーネル手前での生パケット受信確認（tcpdump）
物理ネットワークカード（NIC）にパケットがそもそも到達しているかを調べる最も確実な方法です。
```bash
sudo tcpdump -i eno1 udp port 34980 -n
```
* 外部から接続を試みた際、ここにパケットの履歴（`192.168.3.9.xxxxx > 192.168.3.10.34980`）が出力されれば、物理層の疎通は問題ありません。

---

## 注意事項（今後の運用に向けて）
1. **ターゲットサーバーのデフォルトゲートウェイ設定**
   内部サーバー（`192.168.4.254`）が外部（`192.168.3.9`）へ返答パケットを正しく戻すためには、ターゲットサーバー側のデフォルトゲートウェイが **`192.168.4.1`（Debian の tap2s0）** に向いている必要があります。タイムアウトが発生した際は、まずこのルーティングを確認してください。
2. **自動起動の確認**
   OS再起動時にも本設定が自動適用されるよう、サービスが有効になっていることを確認してください。
   ```bash
   sudo systemctl is-enabled nftables
   # 結果が "enabled" であれば正常です
   ```
