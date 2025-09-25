# VNCで接続できるようにする

```{code} bash
$ sudo apt install wayvnc
```
TF1200ユーザへ切り替えて、ホームディレクトリへ移動する

```{code} bash
$ su TF1200
$ cd
```

swayの設定ファイルを編集。

```{code} bash
$ nano .config/sway/config
```

最終行に以下を追加する。

```{code-block} conf
:caption: `~TF1200/.config/sway/config` の編集

### Start wayvnc
exec /usr/bin/wayvnc 0.0.0.0 5900
```

`/etc/nftables.conf.d/` 以下に新規で`60-wayvnc.conf`を作成する。

```{code-block} json
:caption: /etc/nftables.conf.d/60-wayvnc.conf を新規作成

table inet filter {
  chain input {
    # accept VNC
    tcp dport 5900 accept
  }
}
```

