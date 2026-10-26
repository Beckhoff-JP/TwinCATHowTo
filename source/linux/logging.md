# ロギング

TwinCAT RT Linux上でTwinCATのエラーログやメッセージを記録する方法について説明します。

## TwinCATサービスの設定

`TcSystemServiceUm` の設定ファイル `TcRegistry.xml` により、内部で発生したエラーログとメッセージについてDebianのJournal Logに連動させるかどうかを設定します。

### レジストリファイルの編集

TwinCAT システムサービスを一度停止してから、設定ファイルを編集します。

```bash
# TwinCAT サービスの停止
sudo systemctl stop TcSystemServiceUm

# レジストリファイルの編集
sudo nano /etc/TwinCAT/3.1/TcRegistry.xml
```

### 設定項目の追加・変更

`<Registry>` 内の **`\EventLogger\OsEventLog\`** に関連するキーを設定します。

```{code-block} xml
:caption: OSにEventlogを連携するための設定
:name: code_map_event_logger_with_journals
<Key Name="EventLogger">
  <Key Name="OsEventLog">
    <!-- 0: None(無効), 1: Messagesのみ, 2: Alarmsのみ, 3: 両方 -->
    <Value Name="TypesSupported" Type="DWORD">3</Value>
    
    <!-- 必要に応じてJournalDとSysLogの切り替え用(通常はデフォルトで動作) -->
    <!-- <Value Name="BackendSwitch" Type="DWORD">0</Value> -->
  </Key>
</Key>
```
```{tip}
`TypesSupported` を `3` に設定することで、メッセージとアラームの両方が OS 側に転送されるようになります。
```

### 変更の適用

保存してエディタを閉じたら（Nano の場合は `Ctrl+O` > `Enter` > `Ctrl+X`）、TwinCAT サービスを再起動します。

```bash
# TwinCAT サービスの開始
sudo systemctl start TcSystemServiceUm
```

### OS 側でのログ確認方法

Beckhoff RT Linux では、標準のログ管理に **`journald`** が使用されています。転送された TwinCAT のログを確認するには、以下のコマンドを実行します。

```bash
# TwinCAT 関連のログのみをフィルタリングして表示
sudo journalctl | grep -i tc

# TwinCAT サービス（TcSystemServiceUm）に絞ってログを確認する場合
sudo journalctl -u TcSystemServiceUm
```

## Docker container上のTwinCATの場合

コンテナ内のログを、ホスト（物理マシン）側のシステムログ（`journald`）へ直接流し込み、他のシステムログと統合して管理したい場合は、**Docker のロギングドライバー（Logging Driver）を `journald` に変更**します。

### Dockerイメージ再作成

コンテナ内の `/etc/TwinCAT/3.1/TcRegistry.xml` を更新するにはコンテナの再ビルドが必要です。変更する内容はコンテナソースのディレクトリ `TC_XAR_Container_Sample/tc31-xar-base/TwinCAT` 以下の `SysStartupState.reg` に定義します。TwinCATのEvent loggerの内容をホスト側のjournaldに反映するには、次の最終2行のハイライト箇所の追加が必要です。

この変更を行ってコンテナのビルドを行うと、コンテナ内の `/etc/TwinCAT/3.1/TcRegistry.xml` に対して {numref}`code_map_event_logger_with_journals`の設定（"TypesSupported"=3）が反映されます。

```{code-block} ini
:emphasize-lines: 9,10
Windows Registry Editor Version 5.00

; SysStartupState defines the TwinCAT System Service Startup State
; RUN = "SysStartupState"=dword:00000005
; CONFIG = "SysStartupState"=dword:0000000f
[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Beckhoff\TwinCAT3\System]
"SysStartupState"=dword:00000005
"HeapMemSizeMB"=dword:00000200
[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Beckhoff\TwinCAT3\EventLogger\OsEventLog]
"TypesSupported"=dword:00000003
```

ビルド後、 `/etc/TwinCAT/3.1/TcRegistry.xml` を反映させたコンテナを起動するには {ref}`section_modify_tcregistory` の手順が必要です。こちらを実施してください。

````{important}
{ref}`section_modify_tcregistory` では、永続化ボリュームを設定した `/etc/TwinCAT/` を削除してから起動することで新しいコンテナイメージの `/etc/TwinCAT/` を新規生成させています。ここはXARのランタイムイメージやライセンス、保持変数などを保存する場所でもあるため、稼働データを事前にバックアップを取っています。重要なデータを失わないためにもこの節の手順は必ず守ってください。
````

### ランタイム設定

これまでの設定によりTwinCATランタイムの設定にて、コンテナ内のLinuxのjournaldとの連携は取れましたが、コンテナのjournaldとホスト側のjournaldを連携する必要があります。この設定は `docker-compose.yaml` にて行います。`logging:` 以下を追加します。

```yaml
services:
  tc31-xar-1:
    image: tc31-xar-base:latest
    container_name: tc31-xar-1
    
       :
    logging:
      driver: "journald"
      options:
        tag: "twincat-container1"

tc31-xar-2: # 複数TwinCATコンテナを起動する場合
    image: tc31-xar-base:latest
    container_name: tc31-xar-2
       :
    logging:
      driver: "journald"
      options:
        tag: "twincat-container2"
```

### ホスト側での確認方法

コンテナを起動すると、ホスト側の `journalctl` でコンテナのログを直接検索できるようになります。

```bash
# タグ名で絞り込んで確認
sudo journalctl CONTAINER_TAG=twincat-container1

# またはコンテナ名で絞り込んで確認
sudo journalctl CONTAINER_NAME=tc31-xar-1
```

TwinCAT {ref}`chapter_event_logger` をお使いいただくことで、PLC等のアプリケーション上で発生させるアラームやメッセージについてもjournaldと連携することができます。

大規模なシステムにおいては、PrometheusやXabbixなどの統合監視システムなどと組み合わせることで、装置全体の異常検出をより迅速に行うことができます。