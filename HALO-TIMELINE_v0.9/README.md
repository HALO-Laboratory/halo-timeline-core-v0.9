# HALO-TIMELINE v0.9 (Timeline Core)

**まずは一度動きます。そこから理解が始まります。**

HALO-TIMELINE v0.9 は、Windows から取得した主要アーティファクト
（EVTX / LNK / JumpList / MFT / USNJ）の CSV を統合し、
単一のタイムラインとして整理するための **最小構成スクリプト** です。

この版は「再現できること」をいちばん大事にしています。

- 複雑な環境構築は不要
- 手元に CSV があれば動く
- 出力されたタイムラインを見ながら理解を進められる

理解は **出力結果から逆算** していけば大丈夫です。
急ぐ必要はありません。自分のペースで学べます。

```
You can proceed at your own pace.
```

---

## Example Timeline

最小の例は `examples/example_timeline_v09.csv` にあります。

```
TimestampUTC,Source,Artifact,Action,Path,...
2025-01-21T10:14:22Z,EVTX,Security,Logon, -
2025-01-21T10:19:11Z,LNK,LNK,LinkOpen,C:\Users\User\Documents\report.docx
2025-01-21T10:24:55Z,MFT,report.docx,FileMeta,C:\Users\User\Documents\report.docx
```

この 3 行で「起きた → 人が触った → 実体が存在した」の流れが分かります。

---

## Directory Layout

```
HALO-TIMELINE_v0.9/
├ Build-HALO-Timeline.ps1
├ csv/
│ ├ Evtx/
│ ├ LNK/
│ ├ JumpList/
│ ├ MFT/
│ └ USN/
├ Timeline/
└ docs/
```

CSV を配置して実行すると  
`Timeline/` に `super_timeline_v09.csv` が生成されます。

---

## Who is this for?

- **初めてタイムラインを自力で作る人**
- **出力結果から理解していきたい人**
- **環境依存や自動化の前に“本質”を掴みたい人**

強い技術者は、もう触っていると思います。  
このリポジトリは、その手前で迷う人のためにあります。

```
まずは一度動かし、そこから理解を始めましょう。
```

---

## License
MIT
