# HALO-TIMELINE v0.9 — Reproducibility Checklist

このチェックリストは、タイムライン生成が「正しく再現」できているかを確認するためのものです。

---

## 1. 前提ブロック
| 項目 | OK? | メモ |
|---|---|---|
| 入力 CSV は合法的に取得されたものか | ☐ |  |
| Eric Zimmerman ツールのバージョンが明示できる | ☐ |  |
| csv/ 以下のディレクトリ構造が乱れていない | ☐ |  |

---

## 2. 出力ファイル確認
| 確認内容 | OK? | メモ |
|---|---|---|
| `Timeline/super_timeline_v09.csv` が生成されている | ☐ |  |
| `Timeline/build_timeline.log` が生成されている | ☐ |  |
| 行数 > 0 である | ☐ |  |

---

## 3. タイムレンジ確認

```
最小 TimestampUTC
最大 TimestampUTC
```
これが **解析対象の期間と整合すること**。

| 項目 | OK? |
|---|---|
| Timeline の期間が 0 でない | ☐ |
| 不自然な未来/過去時刻が混入していない | ☐ |

---

## 4. スキーマ整合性

以下の列が全行に存在すること：
```
TimestampUTC, Source, SubSource, Artifact, Action,
User, Host, Process, Path, Details,
EventId, RecordId, PID, TID, SourceFile
```

| 項目 | OK? |
|---|---|
| 列が欠落していない | ☐ |
| TimestampUTC の NULL 行が過剰でない | ☐ |

---

## 5. ログ確認
`build_timeline.log` に `ERR` が含まれていないこと。

| 項目 | OK? |
|---|---|
| WARN はあっても ERR は無い | ☐ |
| セクションごとの行数が異常に少なくない | ☐ |

---

再現性が取れていれば、  
**解析と理解はここから先に進められます。**
