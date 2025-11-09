# HALO-TIMELINE v0.9 (Timeline Core)

**まずは一度動きます。そこから理解が始まります。**

HALO-TIMELINE v0.9 は、Windows システムから取得した主要アーティファクトの
CSV 出力を統合し、単一のタイムラインとして整理するための **最小構成のスクリプト** です。

この版は、学習者が「タイムライン生成という行為そのもの」を  
**自分の手で再現できること** を第一の目的としています。

---

## 1. Overview

HALO-TIMELINE v0.9 は、以下の CSV を入力として受け取り、それらを統合します。

| Artifact | 想定元ツール | 主な意味 |
|---|---|---|
| EVTX | EvtxECmd | イベントログの記録 |
| LNK | LECmd | ショートカットの参照履歴 |
| JumpList | JLECmd | 最近開いたファイル・操作履歴 |
| MFT | MFTECmd | ファイルシステムのメタデータ |
| USNJ ($J) | MFTECmd | ファイル変更ログ |

**出力:**  
```
Timeline/super_timeline_v09.csv
```

---

## 2. Directory Layout

```
HALO-TIMELINE_v0.9/
├ Build-HALO-Timeline.ps1
├ csv/
│ ├ Evtx/       *.csv を配置
│ ├ LNK/        *.csv を配置
│ ├ JumpList/   *.csv を配置
│ ├ MFT/        *.csv を配置
│ └ USN/        *.csv を配置
└ Timeline/
   └ (生成物: super_timeline_v09.csv, build_timeline.log)
```

**入力データは配布しません。**  
各自が **合法的にアクセス可能な環境** で取得してください。

---

## 3. Processing Flow

1. 各 CSV を読み込む
2. 共通スキーマへ正規化
3. タイムスタンプを **UTC** に統一
4. `TimestampUTC, Source` でソート
5. タイムラインとして出力

---

## 4. Output Schema

| Column | 説明 |
|---|---|
| TimestampUTC | UTC ISO8601 形式の時刻 |
| Source | アーティファクト種別 (EVTX/MFT/…) |
| SubSource | ツール・チャネル・AppID など |
| Artifact | 対象名（パス/エントリなど） |
| Action | 操作・レベル・種別 |
| User | 関連ユーザー |
| Host | ホスト識別子 |
| Process | 実行プロセス情報 |
| Path | 対象ファイルパス |
| Details | 追加情報 |
| EventId / RecordId / PID / TID | 補助情報 |
| SourceFile | 元 CSV ファイル名 |

---

## 5. Reproducibility

再現性を保つため、以下を確認してください:

- 同一のツールバージョンを利用する
- タイムスタンプは UTC へ統一されることを前提に読む
- 生成された CSV の行数・期間を `REPRO_CHECKLIST.md` に従って確認する

---

## 6. Limitations

- v0.9 は **「タイムライン統合コア」** です
- イメージマウント・抽出処理・Plaso 連携などは **対象外**
- v1.x 系で段階的に再拡張されます

---

## For learners

理解は **出力結果から逆算する** ことで身につきます。  
急ぐ必要はありません。自分のペースで確認してください。

```
You can proceed at your own pace.
```
