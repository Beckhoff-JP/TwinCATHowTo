(chapter_reverse_proxy_nginx)=
# nginx を用いたリバースプロキシの設定

WindowsやTwinCAT BSDでは、クライアントからPLC HMI Webに直接接続するのではなく、別途リバースプロキシを設置しています。これによって、デバイスマネージャやPLC HMI Webが統合的にPort80や443を使ってHTTPやHTTPS経由の通信を行うことができます。

## 自己署名証明書の作成

nginxでアクセスする際には、ポート443を用いたSSL通信が可能です。このための自己署名証明書ファイルを作成します。

最初に、証明書を配置する場所を作成してその場所へ移動します。

```{code} bash
$ sudo mkdir -p /usr/local/etc/nginx/ssl
$ cd /usr/local/etc/nginx/ssl
```

ここからの作業は全て `root` ユーザとして実行する必要があります。よって、次のコマンドで一時的に `root` ユーザへ切り替えます。

```{code} bash
$ sudo -s
Password:
# 
```

`root` に切り替わるとプロンプトが`$`から`#`へ変化します。移動したカレントディレクトリ上で秘密鍵を作成します。暗号化に用いるパスフェーズを設定してください。

```{code} bash
# openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -aes-256-cbc -out privkey.pem
.+.....+.+..+...+.........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*..+....+...+...+........+.......+.....+.........+...+.+......+.........+...........+...............+...+.......+...+...+..+......+......+....+...........+.+.....+.......+.....+...+...+.+......+...+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.+.....+............+...+...+...+....+...+..............+.+........+....+..+....+...........+...+.+..+...+.+......+.....+.......+..+.+........+.+.........+..+....+.....+......+....+...+..+.+...............+...+..+.........+.............+............+...+...........+................+.....+.+..+.......+.....+....+..+............+.+..+.......+........+...+.+...+...+...+..+...+.+.....+.........+.........+...+..................+....+...+........+......+..................+................+..+...+.......+...+......+.........+.....+....+........+.......+..+..................................+.....+....+...........+.+.....+.+........+.......+...+............+.......................+.........+.......+...........+...+....+......+..+............+......+.......+.........+........+.......+...+..+.+...+...........+....+..+....+........+......+....+...+...+.....+....+..+.+..............+..........+........+......+....+........+..........+.........+...+.....+...+..........+..+.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.+....+...+..................+..+...+.........+..........+...+......+..+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*..+......+.+.....+.+...+.........+...+.....+............+......+.......+.....+...+......+..........+...........+...+.+...+.................+.+...............+.........+...+.....+......+....+.....+...+...+....+..+.+........+..........+.....+......+.............+..+...............+....+..+.......+.....+...+...+....+......+.........+.....+.+...........+.+........+....+...........+.......+........+...................+..................+..+......+..........+.....+.+...........+....+.....+.............+........+...+.......+..+...+....+...+...............+.....+...+..........+...+...........+......+...+....+..+.........+....+......+..............+...+....+.....+...+................+.....+.+..............+......+.+..+.+.........+..+......+...+...................+......+.........+......+.........+.....+.+..+...+.......+..+.+.....+.......+..+.........................+...+.....+.........+....+..+............+...+...+.+......+.....+....+.........+...........+...+.+..+...............+.......+...+...+..+...+..........+.........+........+.............+..............+......+......+....+.....+......+...+......+.+...+...+.....+..........+...+......+...............+...+...+............+.....+.+...........+.+..+.......+...+.................+......+.......+.....+.+..+....+.....+....+.....+..........+.....+.+...+..+................+..+...+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
$
```

次に証明書署名要求（CSR）を作成します。最初に秘密鍵に設定したパスフェーズを求められますので、入力してください。

```{code} bash
# openssl req -new -key privkey.pem -out csr.pem
Enter pass phrase for privkey.pem:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:JP
State or Province Name (full name) [Some-State]:Kanagawa
Locality Name (eg, city) []:Yokohama
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Beckhoff Automation K.K.
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:beckhoff.co.jp
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
#
```

CSRファイルができているか確認してください。

```{code} bash
# ls -l
total 12
-rw-r--r-- 1 root root 1013 Aug  1 01:46 csr.pem
-rw------- 1 root root 1874 Aug  1 01:44 privkey.pem
```

ここから証明書を発行します。

```{code} bash
# openssl x509 -req -in csr.pem -signkey privkey.pem -days 90 -out crt.pem
Enter pass phrase for privkey.pem:
Certificate request self-signature ok
subject=C = JP, ST = Kanagawa, L = Yokohama, O = Beckhoff Automation K.K., CN = beckhoff.co.jp
```

最後に、pemに設定したパスワードをファイルに出力しておきます。

```{code} bash
# sudo echo 'パスフレーズ' > passwd
```

再度生成された証明書ディレクトリ内を確認すると以下の通りとなります。

```{code} bash
# ls -l
total 16
-rw-r--r-- 1 root root 1237 Aug  1 01:54 crt.pem
-rw-r--r-- 1 root root 1013 Aug  1 01:46 csr.pem
-rw-r--r-- 1 root root    5 Aug  1 02:09 passwd
-rw------- 1 root root 1874 Aug  1 01:44 privkey.pem
```

`passwd` ファイルは所有者以外に読み取られることがないようにパーミッションを変更しておきます。

```{code}
# chmod 600 passwd
# ls -l
total 16
-rw-r--r-- 1 root root 1237 Aug  1 01:54 crt.pem
-rw-r--r-- 1 root root 1013 Aug  1 01:46 csr.pem
-rw------- 1 root root    5 Aug  1 02:09 passwd
-rw------- 1 root root 1874 Aug  1 01:44 privkey.pem
#
```


最後に忘れずにAdministratorユーザへ戻ってください。

```{code} bash
# exit
$
```

## nginxのインストールと設定


`nginx` をインストールします。次のコマンドでインストールを行ってください。

```{code} bash
$ sudo apt install nginx
```

つづいて、設定ファイルを新規作成します。

```{code} bash
$ sudo touch /etc/nginx/conf.d/IPC_plchmi.conf
```

編集します。

```{code} bash
$ sudo touch /etc/nginx/conf.d/IPC_plchmi.conf
```

設定は以下の通りです。ポート80は外部からはアクセスできず、自分自身からのみリクエストに受け付ける設定です。外部からは443（SSL）のみ接続を許可しています。

```{code-block} nginx
:caption: /etc/nginx/conf.d/IPC_plchmi.conf

# This is only for TwinCAT PLC HMI Web (TF1810) on TwinCAT RT Linux beta
server {
    listen       127.0.0.1:80;
    listen       [::1]:80;
    listen       443 ssl;
    server_name  beckhoff.co.jp;
    ssl_certificate /usr/local/etc/nginx/ssl/crt.pem;
    ssl_certificate_key /usr/local/etc/nginx/ssl/privkey.pem;
    ssl_password_file /usr/local/etc/nginx/ssl/passwd;

    ssl_protocols TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;


    location /Tc3PlcHmiWeb {
        proxy_pass http://0.0.0.0:42341;
    }
}
```

## nginx のサービススタート

nginx を起動します。

```{code} bash
$ sudo systemctl start nginx
```

また、次回起動以後もnginxデーモンを自動起動する場合、以下のとおりサービス自動起動を有効にします。

```{code} bash
$ sudo systemctl enable nginx
```

これにより他のTwinCATのOSと同様、ポート `42341` に直接ではなく、SSLでアクセスする事ができるようになりました。今回は自己署名証明書でしたが、ドメイン名やメールアドレス等正規な値を設定した証明書要求ファイルを作成の上、正式な署名ファイルにてSSL通信していただくとより安全です。

`https://192.168.3.45/Tc3PlcHmiWeb/Port_851/Visu/webvisu.htm`
