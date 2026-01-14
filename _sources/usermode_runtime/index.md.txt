(chapter_usermode_runtime)=
# ユーザモードランタイム

ユーザモードランタイムは、TwinCAT 3.1 4026 から追加された機能です。

それまでのバージョンでは、開発用のホストシステムにXAEだけをインストールすることができず、同時にカーネルモードで動作するXARがインストールされていました。このXAR上に開発したTwinCATプロジェクトを動作させることで机上でのシミュレーション確認ができました。

しかし、近年Hyper-Vを用いた仮想化技術により、Windows自体が仮想マシン上で動作することがトレンドとなっています。代表的なものとして、Windows 11 より採用された仮想化ベースのセキュリティ（Virtualization Based Security）です。これは単純に言えば仮想環境上で動作するプログラムコードやドライバの署名をチェックし、不正なプログラムを動作させないようにするためのセキュリティ機能です。

カーネルドライバに対しても仮想環境で動作することを強要するため、ハードウェア上でのリアルタイム動作の保証を要求するTwinCATとの相性はよくありません。

このため、VBSのようなHyper-V上でWindowsカーネルを動作させる機能を完全に無効化させる必要があります。しかし、表面上Hyper-Vを無効化設定したとしても、たとえばWSL（Windows上でLinuxカーネルを動作させる技術）など他にもHyper-Vを利用するものが動作していれば無効化することができません。

従って、開発用PC上でテストやシミュレーション目的でランタイムを動作させるには、カーネルモードではなくユーザモードでXARを動作させる事が求められるようになりました。これがユーザモードランタイムの意義です。

また今後、コンテナベースの TwinCAT / Linux での実現を目指しているCI（Continuous Integration）を実現する場合も、変更を加えたソース変更に対して自動的にビルド・テスト実行する機能が求められます。この際、コンテナ上でランタイムを動作させることを実現するためにも重要な技術となります。

## ユーザモードランタイムのアーキテクチャ

リアルタイムランタイムはハードウェアに直接アクセスできるため、開発用のホストであってもTwinCATプロジェクトのRealtime設定に準じたコアが使用されます。

一方、Twincat Usermodeランタイムにはこのオプションがありません。したがって、Twincat 3 Usermodeランタイムは、タスクをスレッドにマッピングします。

CPUコアへのタスクの割り当ては、Usermodeランタイムで受け入れられますが、オペレーティングシステムがこれらのスレッドを管理するため、技術的には考慮されていません。

![](https://infosys.beckhoff.com/content/1033/tc170x_tc3_usermode_runtime/Images/png/9007211118189707__en-US__Web.png)

これらのハードウェアの挙動まで厳密シミュレーションしたい場合は、[こちらの説明](https://infosys.beckhoff.com/content/1033/tc170x_tc3_usermode_runtime/11319881355.html?id=8811394885253244222)にあるように有償版のTC1701などを用いて外部ロジックで生成したサイクルティックに同期してタスク制御する必要があります。

```{warning} 
同期タスクなど厳密なタスク間のタイミング評価を行いたい場合、 [外部同期用のAPI](https://infosys.beckhoff.com/content/1033/tc170x_tc3_usermode_runtime/11324440715.html?id=3527837835434224128)が用意されています。
```

この節では、無償版のTC1700の説明について触れます。

## 基本パッケージのインストール

パッケージマネージャから `usermode` という文字列で検索して現れる `TC170x | TwinCAT 3 Usermode Runtime` をインストールしてください。

![](../setup_twincat/assets/2025-09-24-22-25-55.png){align=center}

## 追加パッケージ

それ以外に使用する機能毎に追加パッケージのインストールまたは、設定が必要なものがあります。下記のリンクをご覧ください。NCPTPなどのモーションをシミュレーション動作させるのに必要な追加パッケージは次節でも手順をご説明します。

```{tip}
参考：[各種TwinCAT Functionのユーザモードランタイムへの統合](https://infosys.beckhoff.com/content/1033/tc170x_tc3_usermode_runtime/15569026315.html?id=2226885034770686651)
```

### モーションパッケージ向けドライバ

NC-PTPやNCI, CNCなどを取り扱う場合、別途ユーザモードランタイム向けのドライバが用意されています。これらはWorkloadでは現れませんので、一覧をPackagesに切り替えた上で、`XARUM` という文字列で一覧されるパッケージを個別にインストールする必要があります。

```{list-table}
:align: center

- * ![](assets/2025-09-09-19-55-02.png){align=center width=300px}
  * ![](assets/2025-09-09-19-55-26.png){align=center width=450px}
```

## ユーザモードランタイムの基本的な使い方

1. ユーザモードランタイムはタスクトレーのTwinCATアイコンのサブメニューからStartさせるところから始まります。

    ```{list-table}
    :align: center

    - * ![](assets/2025-04-10-10-22-32.png){align=center}
      * ![](assets/2025-04-10-10-24-12.png){align=center}
    - * スタート前
      * スタート後
    ```

2. スタートすれば、後はXAEからターゲットを `UmRT_Default` に切り替えてから構成の有効化（Active Configuration）を行うだけです。

    ![](assets/2025-04-10-10-38-24.png){align=center}

3. 実行中はコンソール上で制御できます。

    ```{code} powershell
    TcSysSrvUm: started
    2025-04-10 11:26:48.183175 - Init client interface
    TcSysSrvUm state: Config [8976]
    AmsNetId: 199.4.42.250.1.1
    TcSysSrvUm state: Config [8976]

    Press 'c' for Reconfig TwinCAT System.  ---> Configuモードへ移行
    Press 'r' for Restart TwinCAT system.   ---> Runモードへ移行
    Press 's' to view current state.        ---> 現在の状態を表示
    Press 'x' to exit TwinCAT system service.   ---> ユーザモードランタイムの終了
    Press 'd' to detach the exception handler   ---> 例外やブレークポイントによる停止を無視します。
    ```

    終了したい場合は、`x` を押してください。

```{admonition} 制限事項
:class: warning

カーネルモードで提供されるXARに対して[いくつか制約事項](https://infosys.beckhoff.com/content/1033/tc170x_tc3_usermode_runtime/11319889035.html?id=6099265847340807990)があります。ご確認ください。
```

## よくあるトラブル

(section_umr_not_enough_memory)=
### ユーザモードランタイムでRUN中のPLCにログインしようとすると not enough memory というウィンドウが現れる

![](https://infosys.beckhoff.com/content/1033/tc170x_tc3_usermode_runtime/Images/png/9007215564000267__en-US__Web.png)

対処方法
  : ユーザモードランタイムの使用するHeapメモリを設定するように定義を追加する必要があります。次のとおり、`HeapMemSizeMB` に十分なサイズのHeapメモリサイズ（単位：MByte）を設定します。512MByte程度あれば十分でしょう。
  : ```{code-block} xml
    :caption: C:\ProgramData\Beckhoff\TwinCAT\3.1\Runtimes\UmRT_Default\3.1\TcRegistry.xml

    <?xml version="1.0"?>
     <TcRegistry>
      <Key Name="HKLM">
        <Key Name="Software">
          <Key Name="Beckhoff">
            <Key Name="TwinCAT3">
              <Value Name="CurrentVersion" Type="SZ">3.1</Value>
              <Key Name="System">
                  :
                <Value Name="HeapMemSizeMB" Type="DW">512</Value>
    ```