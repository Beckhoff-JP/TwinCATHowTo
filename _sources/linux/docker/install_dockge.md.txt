# Dockgeのインストール

Dockgeは、DockerやDocker composeの稼働状態の監視、開始、停止処理、compose 定義ファイルをブラウザ上から行えるWEBアプリケーションです。

```{tip}

この節で説明するDockgeのインストールは必須ではありません。読み飛ばして次の節へ進んでいただいても構いません。

ただし、Dockerのデプロイを行うホスト上のディレクトリは、Dockgeにより管理される次のディレクトリにインストールするものとしてマニュアルの説明が続きます。

/opt/dockge
    : dockgeのデプロイディレクトリです。docker composeにて

/opt/stacks
    : dockgeが監視する docker デプロイディレクトリです。
```

1. ディレクトリ作成


    ``` bash
    $ sudo mkdir -p /opt/stacks /opt/dockge
    $ cd /opt/dockage
    ```

2. 