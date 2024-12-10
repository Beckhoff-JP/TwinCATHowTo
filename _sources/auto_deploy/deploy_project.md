## 展開先への配置と起動

展開先IPCへのプログラムの配置方法は以下の手順となります。

```{blockdiag}
blockdiag {
    "Bootイメージの展開" -> "自動起動の設定" -> "コンピュータの再起動";
}
```

```{admonition} 警告
:class: warning

この章の手順は必ず事前に Config モードに移行してから実施してください。
```{image} 2023-02-24-18-18-38.png
:width: 250px
:align: center
```



1. 前項で採取したモデルマシンのファイル・フォルダをターゲットマシンに配置する


    ```{csv-table}
    :header: モデルマシンのファイル, ターゲットマシンの配置先, 備考

    _Boot\TwinCAT RT(X**)\PLC,C:\TwinCAT\3.X\Boot, PLCモジュール有り時
    _Boot\TwinCAT RT(X**)\CustomConfig.xml,C:\TwinCAT\3.X\Boot, PLCモジュール有り時
    _Development\TwinCAT RT(X**)\*.pdb, C:\TwinCAT\3.X\AutoInstall, C++モジュール有り時
    _Development\TwinCAT RT(X**)\*.sys, C:\TwinCAT\3.X\AutoInstall, C++モジュール有り時
    ```

2. 自動ログイン・自動RUNモード移行設定

    自動ログイン設定
    :   
    1. スタートメニューの検索ウィンドウより、 `netplwiz` と入力する。
        ```{image} 2023-02-24-18-02-54.png
        :width: 400px
        :align: center
        ```
    2. 次のチェックBOXをOFFにする。
        ```
        Users must enter a user name and password to use this comuputer.
        ```
        ```{image} 2023-02-24-17-58-21.png
        :width: 300px
        :align: center
        ```
    
    自動RUNモード設定
    :    おなじく検索ウィンドウで `regedit` と入力してレジストリエディタを起動します。次のレジストリ項目を、 `0x0000000f` から `0x00000005` へ変更してください。
        ```ini
        Windows Registry Editor Version 5.00

        [HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Beckhoff\TwinCAT3\System]
        "SysStartupState"=dword:00000005
        ```

        ```{admonition} 注意
        :class: notice

        上記レジストリパスはWindows10に限ります。
        ```
    
3. IPCを再起動する

    再起動後、自動的にログイン・RUNモードへ移行し、プログラムが稼働していることを確認します。


    ```{admonition} 警告
    :class: warning

    コンピュータの再起動を行う前に手動でRUNモードへ移行させないでください。展開元のプログラム設定が正しく反映されず、プログラムが作動しなくなる可能性があります。万が一RUNモードへ移行させた場合は、再度Configモードへ移行し、この章の手順を最初からやりなおしてください。
    ```