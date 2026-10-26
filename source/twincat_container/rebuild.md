(section_modify_tcregistory)=
# TcRegistory.xml の変更手順

TwinCAT の環境設定は `/etc/TwinCAT/3.1/TcRegistory.xml` にて行います。このファイルは、TwinCAT 3 において、Windowsレジストリに代わる設定情報を管理するための構成ファイルです。したがって、コンテナ生成時にあらかじめ登録しておく必要があります。

このファイルは {ref}`section_tc_container_build_image` の手順に記載された、コンテナソースコードのTwinCATコンテナイメージをビルドする場所以下に配置されている {ref}`code_sys_startup_state_reg` のファイルに定義してコンテナイメージのビルドを行います。この節の例として次のような項目を設定しています。

System.HeapMemSize
  : コンテナプロセスが確保するヒープメモリサイズ。必然的にADSルータメモリの上限に依存します。TwinCAT Visionなど巨大な画像イメージを取り扱うには大きなサイズのADSメモリが必要となり、併せてヒープ領域を大きく確保する必要があります。この場合、この値を設定変更する必要があります。

EventLogger.OsEventLog.TypeSupported
  : TwinCATイベントエラーやメッセージをLinuxのログシステムと連携する設定です。コンテナ内で発生した事象を、ホスト側のjournaldに通知するための設定を行います。デフォルトでは通知を行いませんので、この例にみられるように、アラームとメッセージの全てをホスト側のログ管理機構に通知する設定を行うにはこの項目の定義が必要となります。

これらの `TcRegistory.xml` で定義可能なパラメータの変更を行った場合、都度、TwinCATコンテナイメージを再作成する必要があります。

新しく作成されたイメージは `docker compose` の再デプロイにて適用できますが、コンテナ内の `/etc/TwinCAT` ディレクトリはホスト側のファイルシステムに永続化されています。よって、再デプロイだけではこのディレクトリ以下の内容は更新されません。おなじくビルドにより新しくできた `TcRegistory.xml` は反映されません。

そこで、一度このボリュームを削除してからコンテナを再デプロイする必要があります。

しかしこのままでは、これまで稼働していたTwinCATプロジェクト環境やライセンスや、 `VAR PERSISTENT` で宣言した永続化変数の値もすべて初期化されてしまいます。このため、下記の手順で一度バックアップを取ってからコンテナのビルド、最後に、リストアを行う手順が必要となります。

1. TwinCAT ボリュームを確認してBootフォルダをバックアップする

    例として{numref}`whole_docker_compose_yaml` に示したdocker compose定義ファイルで作成されたTwinCATボリュームの例は以下の通りです。

    ```{code-block} bash
    $ sudo docker volume ls
    DRIVER    VOLUME NAME
    local     2c5affc676569f106b32178efd3439c9d61c7251d85ea36371014d23734134c6
    local     85ecff1e87bd3ee1bba1573de624fc132b05d5519733fd121fceb4f80e5d8af9
    local     tc_xar_container_sample_xar1data
    local     tc_xar_container_sample_xar2data
    ```

    管理者へスイッチします。
    ``` bash
    $ sudo -s
    [sudo] password for Administrator:
    # 
    ```

    docker-ceであれば、ホスト上の次のディレクトリにコンテナ内の `/etc/TwinCAT` のボリュームの内容が配置されています。まずはここへ移動します。

    ``` bash
    # cd /var/lib/docker/volumes/tc_xar_container_sample_opc_server_xar_data/_data/
    # ls
    3.1  Functions
    ```

    この中から、`3.1`ディレクトリ以下の`Boot`と`Target/License` ディレクトリをまるごと、Administratorユーザのホームディレクトリ内の`backup`ディレクトリ以下にコピーします。

    ```{code} bash
    # cp -r 3.1/Boot ~Administrator/backup
    # cp -r 3.1/Target/License ~Administrator/backup
    ```

2. Dockerの停止

    ```{code-block} bash
    docker compose down
    ```

3. TwinCAT ボリュームの削除

    手順1で確認した最後が`docker-compose.yaml`で定義したボリューム名となっている`/etc/TwinCAT`のボリュームを削除します。
    ```{code-block} bash
    $ docker volume rm tc_xar_container_sample_xar1data tc_xar_container_sample_xar2data
    ```

4.  {ref}`code_sys_startup_state_reg` の編集と {ref}`section_tc_container_build_image` を実施する。

5. Docker compose 有効化（再デプロイ）

    ```{code-block} bash
    $ docker compose up -d
    ```

6. Bootフォルダを復帰

    ```{code} bash
    $ sudo -s
    [sudo] password for Administrator:
    # cd /var/lib/docker/volumes/tc_xar_container_sample_tc31xar/_data/
    # cp -r ~Administrator/backup/Boot 3.1/
    # cp -r ~Administrator/backup/License 3.1/Target
    # exit
    ```

7. Docker compose 再起動

    ```{code-block} bash
    $ docker compose restart
    ```

以上で、`TcRegistory.xml` を新しいものに更新した上で、`Boot`や`License`は以前のものを引き継ぐことができます。