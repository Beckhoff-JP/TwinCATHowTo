# Ethernetスイッチポートターミナルを通じた通信

[Infosys ページ](https://infosys.beckhoff.com/content/1033/el6601_el6614/index.html?id=5313826722071648862)

Ethernet switchport termnal EL6601、EL6614は、{numref}`figure_ethernet_sw_termnal_connection` のとおりIPCのEtherCATマスターに割り当てたEthernetポートから、EL6601やEL6614のそれぞれのポートに接続された先のコンピュータとEthernet接続するためのターミナルです。

EL6601およびEL6614はリアルタイムデータ交換と、イーサネットスイッチの二通りのユースケースがありますが、ここではイーサネットスイッチとして機能する方法について説明します。

イーサネットスイッチとして機能させる場合、EL6601やEL6614の各Ethernetポートはネットワークの端末として機能するのではなくLayer 2 スイッチとして機能します。したがって、どのポートも、同一ネットワークセグメントのホストを接続いただき、相互に通信する事が可能です。

```{figure-md} figure_ethernet_sw_termnal_connection
![](./assets/connection.png){align=center}

Ethernetスイッチポートターミナルの接続例
```

```{toctree}
:caption: 目次

configuration
```