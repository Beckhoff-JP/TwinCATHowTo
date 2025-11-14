# リバースプロキシの設定

{ref}`section_docker_compose_twincat` で実施した手順では、次の通りTF1800 PLC HMI Webを含めたコンテナが稼働しています。このWEBサーバは以下の仕様で動作しています。

```{csv-table}
:header: コンテナ名, IPアドレス, PLC HMI Web URL

tc31-xar-1, 192.168.20.3, http://192.168.20.3:42341/Tc3PlcHmiWeb/Port_851/Visu/webvisu.htm
tc31-xar-2, 192.168.20.4, http://192.168.20.4:42341/Tc3PlcHmiWeb/Port_851/Visu/webvisu.htm
```

このポートはデフォルトでは外部からアクセスすることができません。nftables等でポートを許可するとアクセスできるようになりますが、一般的にSSL暗号化されていないWEBサーバを外部開放することは推奨されていません。

そこで、nginx によるリバースプロキシにてバーチャルホスト定義を行い、SSLで外部アクセスできるように設定します。

## SSL証明書の作成

SSL自己署名証明書を作成される場合は、{ref}`chapter_reverse_proxy_nginx` を実施してください。証明機関に依頼する場合においても、秘密鍵の作成やSSL/TLS正味書署名要求（CSR）を作成し、機関による署名済みの証明書を本手順で示す場所へ配置してください。

## nginxの設定

IPCの `/etc/nginx/conf.d/` 以下に、{numref}`nginx_xar1` と {numref}`nginx_xar2` の二つのファイルを作成したあと、次のコマンドを発行して設定を有効にします。

```{code-block} bash
$ sudo systemctl restart nginx
```

```{code-block} conf
:caption: /etc/nginx/conf.d/xar1_hmi.conf
:name: nginx_xar1

server {
    listen       127.0.0.1:42343;
    listen       [::1]:42343;
    listen       42343 ssl;
    server_name  beckhoff.co.jp;
    ssl_certificate /usr/local/etc/nginx/ssl/crt.pem;
    ssl_certificate_key /usr/local/etc/nginx/ssl/privkey.pem;
    ssl_password_file /usr/local/etc/nginx/ssl/passwd;

    ssl_protocols TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://192.168.20.3:42341/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

```{code-block} conf
:caption: /etc/nginx/conf.d/xar2_hmi.conf
:name: nginx_xar2

server {
    listen       127.0.0.1:42344;
    listen       [::1]:42344;
    listen       42344 ssl;
    server_name  beckhoff.co.jp;
    ssl_certificate /usr/local/etc/nginx/ssl/crt.pem;
    ssl_certificate_key /usr/local/etc/nginx/ssl/privkey.pem;
    ssl_password_file /usr/local/etc/nginx/ssl/passwd;

    ssl_protocols TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://192.168.20.4:42341/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## 設定したバーチャルホストのポート42343と42344を開放

外部からアクセスできるように、nftables の設定にて 42343と42344のポートを開放します。`/etc/nftables.conf.d/` に、`60-tc31container-plc-hmi.conf` を追加します。

```{code-block} 
:caption: /etc/nftables.conf.d/60-tc31container-plc-hmi.conf

table inet filter {
  chain input {
    # accept plc hmi on container
    tcp dport 42343 accept
    tcp dport 42344 accept
  }
}
```

次に下記のコマンドにて設定を反映します。

```{code} bash
$ sudo systemctl restart nftables
```

## nginx 再起動と試運転

以下のコマンドにてnginxを再起動し、新たなバーチャルホストが有効となります。

```{code} bash
$ sudo systemctl restart nginx
```

IPCにネットワークに接続された周辺PCからブラウザにて次のURLアクセスし、HMI画面が現れることを確認してください。

tc31-xar-1
    : https://<ターゲットIPCのIPアドレス>:42343/Tc3PlcHmiWeb/Port_851/Visu/webvisu.htm

tc31-xar-2
    : https://<ターゲットIPCのIPアドレス>:42344/Tc3PlcHmiWeb/Port_851/Visu/webvisu.htm