(section_memory_alignment)=
# メモリアライメント

x86の64bitアーキテクチャでは、8byteごとにCPU間とメモリ転送が行われます。

このサイズを跨いでメモリ上にデータが配置されていると、その跨いだデータをCPUに読み書きするために、2回分の転送が必要になり非効率的です。このため、この境界を跨がないように適度に空きを入れてメモリ上に配置する仕組みを[メモリアライメント](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/3539428491.html?id=1077154105239192384)といいます。

たとえば、下記の構造体の2番目の要素である`iValue`は2byte占有しますが、その前の`bTest1`は実際には1Byteしか占有しません。ここで詰めて配置してしまうと3Byte占有することとなり、その後データ配列によっていずれ8Byteの境界を跨いでしまいます。

```{code} iecst
TYPE test_structure :
STRUCT
    bTest1 :BOOL;// 1byte だけど、次のINT型は2byte アライメントなので、このあと1byteは空きができる
    iValue : UINT;// 2byte
    bTest3 : BOOL; // 1byte（ここまで 5byte を消費。8byteアライメントだと残り 3byte 空き。）
    diValue2 : UDINT; // 4byte
END_STRUCT
END_TYPE
```

これを防止するため、`bTest1`の後に1Byteの空きを作ってから、次の`iValue`を配置する、といった調整を行います。

同様に、`bTest3`のあとには、4Byte占有する`diValue2`が並んでいます。それまでに5Byte占有していますので、ここで4Byteを詰めて配置すると境界を跨いでしまいます。よって、3Byte空きを挿入してから`diValue2`のデータを配置します。

この構造体データをUNIONでByte配列と共用体で宣言してみます。

```{code} iecst
TYPE u_test :
UNION
    st_test : test_structure;
    b_raw : ARRAY [0..15] OF BYTE;
END_UNION
END_TYPE
```

st_testの各要素変数に最大値（全てbitの1が立った状態）をセットした場合のバイト配列の状態は次の通りとなります。

![](assets/2024-02-23-21-12-25.png){align=center}

`bTest1` はBOOL型なので1Byte占有しますが、その後のUINT型の変数`iValue`は、そのサイズに合わせて1Byteの空きの後に配置されます。また、`bTest3`も同様に1Byte占有しますが、その後`diValue2`は4Byte占有しますので、3Byteの空きの後配置されます。

## pack_mode 指定

メモリアライメントを任意の値に指定する属性指定が、[`pack_mode`](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2529746059.html?id=3686945105176987925)です。構造体の先頭に、`{attribute 'pack_mode' := '<アライメントバイト数>'}`とすることで、指定のアライメントが行われます。

次の例では、1byte アライメントを指定された例です。

```{code} iecst
{attribute 'pack_mode' := '1'}
TYPE test_structure :
STRUCT
    bTest1 :BOOL;// pack_mode=1なのでこのあと空きはできない。
    iValue : INT;// 2byte
    bTest2 : BOOL; // 1byte（追加）
    bTest3 : BOOL; // 1byte（pack_mode=1なのでこのあと空きはできない。）
    diValue2 : DINT; // 4byte
END_STRUCT
END_TYPE
```

先ほどと異なり、ワード語長を跨いだサイズでもバイトごとに配置され、空きは発生しません。

![](assets/2024-02-23-21-29-05.png){align=center}

```{warning}
1バイトアライメントを使用すると、メモリ占有サイズを最小化することができますが、代わりにワード語長を跨いだ変数へのアクセスに余分なCPU処理回数が求められます。少しの演算負荷の増加でもリアルタイム性能に影響するようなシステムにおいては多用しないようにご注意ください。
```