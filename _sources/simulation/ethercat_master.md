# EtherCAT構成の定義

まず、制御側のTwinCATプロジェクトに、すでにEtherCATメインおよび、そのサブの構成が作成されていることを前提として、シミュレーションプロジェクトを新規に作成し、手順を示します。

1. 制御側のマスタからENI(EtherCAT Network Information)ファイルをエクスポートする

    ![](assets/2023-09-13-15-46-43.png){align=center}

2. シミュレーション用EtherCATマスタの作成

    ![](assets/2023-09-13-15-48-48.png){align=center}

    ![](assets/2023-09-13-15-49-31.png){align=center}

3. ENIファイルのインポート

    ![](assets/2023-09-13-15-52-44.png){align=center}

    これにより、制御側のEtherCATネットワーク構成に対応したシミュレーション用EtherCATネットワークが構成されます。

4. Simulation用のEtherCATが使用するネットワークアダプタをSearchボタンを押して選択します。

    ![](assets/2023-09-13-15-54-24.png){align=center}

