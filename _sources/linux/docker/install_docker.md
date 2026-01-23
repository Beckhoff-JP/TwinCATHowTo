# Dockerのインストール

DockerはDebianのリポジトリからも供給されていますが、Ubuntuが提供するdocker.ioとよばれるもので、中身も古く、公式のものではありません。ここではDocker社が提供するdocker-ceに移行するための手順を示します。

既存のDockerのアンインストールから本家のDockerインストールまでの手順となりますので、はじめてDockerを導入される方は、{ref}`section_install_docker_original` まで飛ばしてください。

## docker.ioのアンインストール

まず、稼働中の全コンテナを停止します。

```{note}
はじめてDockerをお使いの方はこの節を実行する必要はありません。
```

```{code} bash
$ sudo docker stop $(sudo docker ps -q)
```

Dockerサービスを無効化します。

```{code} bash
$ sudo systemctl stop docker.service
$ sudo systemctl stop docker.socket
```

現状のコンテナイメージのバックアップを取ります。

```{code} bash
$ sudo tar -czf ~/docker-backup-$(date +%Y%m%d).tar.gz /var/lib/docker
```

docker.ioをアンインストールします。

```{code} bash
$ sudo apt purge docker.io docker-doc docker-compose docker-compose-v2 containerd runc
$ sudo apt autoremove -y
```

もし古いプラグイン等があればディレクトリごと削除します。

```{code} bash
$ rm -rf ~/.docker/cli-plugins/
```

また、設定ファイルからもプラグインのエントリ `cliPluginsExtraDirs` を削除します。

```{code} bash
$ nano ~/.docker/config.json
```

```{code-block} json
:caption: ~/.docker/config.json の例（変更前）
{
  "cliPluginsExtraDirs": [
    "/home/your_user/.docker/cli-plugins"
  ],
  "credsStore": "desktop"
}
```

```{code-block} json
:caption: ~/.docker/config.json の例（変更後）
{
  "credsStore": "desktop"
}
```

(section_install_docker_original)=
## docker-ceのリポジトリ追加とインストール

```{code} bash
# 1. 必要なツールをインストール
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# 2. Docker公式GPGキーを追加
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. APTにリポジトリ情報を追加
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Dockerの公式リポジトリからインストールします。


```{code}
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

バージョンを確認すると最新がインストールされていることがわかります。

```{code} bash
$ docker --version
Docker version 28.3.3, build 980b856
```