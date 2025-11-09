# C:\HALO.Pipeline.v0.9\Build-HALO-Timeline.ps1
# v0.9a-merge-normalize-utc — EVTX/LNK/JumpList/MFT/USNJ → Timeline/super_timeline_v09.csv
# 出力: Timeline\super_timeline_v09.csv, Timeline\build_timeline.log

[CmdletBinding()]
param(
  [string]$Root = "C:\HALO.Pipeline.v0.9"
)

$ErrorActionPreference = 'Stop'
$swAll = [System.Diagnostics.Stopwatch]::StartNew()

# === Paths ===
$csvDir  = Join-Path $Root 'csv'
$outDir  = Join-Path $Root 'Timeline'
$logPath = Join-Path $outDir 'build_timeline.log'
$outCsv  = Join-Path $outDir 'super_timeline_v09.csv'

if (-not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

# === Logger ===
function Write-Log([string]$msg) {
  $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss.fffK')
  Add-Content -LiteralPath $logPath -Value "$ts $msg"
}

# 起動ヘッダ
Write-Log ("[START] root={0} utcOffset={1} ver=v0.9a" -f $Root, ([TimeZoneInfo]::Local.GetUtcOffset([datetime]::UtcNow)))

# 入力親ディレクトリ存在チェック
if (-not (Test-Path $csvDir)) {
  Write-Log "[WARN] csv directory not found: $csvDir"
  Write-Log "[DONE] rows=0 file=$outCsv elapsed_total=0ms"
  "WARN: csv directory not found. path=$csvDir"
  exit 0
}

# === Utils ===
function To-UTC([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return $null }
  try {
    $dt = [datetime]::Parse($s)
    return ([datetimeoffset]$dt).ToUniversalTime().UtcDateTime
  } catch {
    try {
      $dt2 = [datetimeoffset]::Parse($s)
      return $dt2.ToUniversalTime().UtcDateTime
    } catch { return $null }
  }
}

function FirstNonEmpty {
  param([Parameter(ValueFromRemainingArguments=$true)]$Values)
  foreach ($v in $Values) {
    if ($null -ne $v -and -not [string]::IsNullOrWhiteSpace([string]$v)) { return $v }
  }
  return $null
}

# === 統一列順 ===
$cols = @(
  'TimestampUTC','Source','SubSource','Artifact','Action',
  'User','Host','Process','Path','Details',
  'EventId','RecordId','PID','TID',
  'SourceFile'
)

$all = New-Object System.Collections.Generic.List[object]

# ========== EVTX ==========
try {
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $evtx = Get-ChildItem (Join-Path $csvDir 'Evtx') -Filter *.csv -ErrorAction SilentlyContinue
  Write-Log "[EVTX] files: $($evtx.Count)"
  foreach ($f in $evtx) {
    $rows = Import-Csv -LiteralPath $f.FullName
    foreach ($r in $rows) {
      $payload = if ($r.Payload) { $r.Payload } else { ($r.PayloadData1, $r.PayloadData2, $r.PayloadData3, $r.PayloadData4, $r.PayloadData5, $r.PayloadData6) -join ' | ' }
      $recId   = FirstNonEmpty $r.RecordNumber $r.EventRecordId

      $row = [ordered]@{
        TimestampUTC = To-UTC ($r.TimeCreated)
        Source       = 'EVTX'
        SubSource    = $r.Provider
        Artifact     = $r.Channel
        Action       = $r.Level
        User         = $r.UserName
        Host         = $r.Computer
        Process      = $null
        Path         = $null
        Details      = $payload
        EventId      = $r.EventId
        RecordId     = $recId
        PID          = $r.ProcessId
        TID          = $r.ThreadId
        SourceFile   = $r.SourceFile
      }
      $all.Add([pscustomobject]$row)
    }
  }
  $sw.Stop(); Write-Log ("[EVTX] rows={0} elapsed={1}ms" -f (($all | Where-Object { $_.Source -eq 'EVTX' }).Count), $sw.ElapsedMilliseconds)
} catch { Write-Log "[EVTX][ERR] $($_.Exception.Message)" }

# ========== LNK ==========
try {
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $lnk = Get-ChildItem (Join-Path $csvDir 'LNK') -Filter *.csv -ErrorAction SilentlyContinue
  Write-Log "[LNK] files: $($lnk.Count)"
  foreach ($f in $lnk) {
    $rows = Import-Csv -LiteralPath $f.FullName
    foreach ($r in $rows) {
      $ts       = FirstNonEmpty $r.TargetAccessed $r.LastModified $r.SourceAccessed
      $pathJoin = FirstNonEmpty $r.LocalPath $r.CommonPath
      $details  = "Arg=$($r.Arguments); Rel=$($r.RelativePath)"

      $row = [ordered]@{
        TimestampUTC = To-UTC $ts
        Source       = 'LNK'
        SubSource    = 'LECmd'
        Artifact     = 'LNK'
        Action       = 'LinkOpen'
        User         = $null
        Host         = $r.MachineID
        Process      = $null
        Path         = $pathJoin
        Details      = $details
        EventId      = $null
        RecordId     = $r.EntryNumber
        PID          = $null
        TID          = $null
        SourceFile   = $r.SourceFile
      }
      $all.Add([pscustomobject]$row)
    }
  }
  $sw.Stop(); Write-Log ("[LNK] rows={0} elapsed={1}ms" -f (($all | Where-Object { $_.Source -eq 'LNK' }).Count), $sw.ElapsedMilliseconds)
} catch { Write-Log "[LNK][ERR] $($_.Exception.Message)" }

# ========== JumpList ==========
try {
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $jl = Get-ChildItem (Join-Path $csvDir 'JumpList') -Filter *.csv -ErrorAction SilentlyContinue
  Write-Log "[JumpList] files: $($jl.Count)"
  foreach ($f in $jl) {
    $rows = Import-Csv -LiteralPath $f.FullName
    foreach ($r in $rows) {
      $ts      = FirstNonEmpty $r.LastModified $r.TargetAccessed $r.CreationTime
      $srcFile = [string](FirstNonEmpty $r.SourceFile)
      $artifact = 'JumpList'
      if ($srcFile -match 'AutomaticDestinations') { $artifact = 'AutomaticDestinations' }
      elseif ($srcFile -match 'CustomDestinations') { $artifact = 'CustomDestinations' }

      $row = [ordered]@{
        TimestampUTC = To-UTC $ts
        Source       = 'JumpList'
        SubSource    = $r.AppIdDescription
        Artifact     = $artifact
        Action       = 'RecentItem'
        User         = $null
        Host         = $r.Hostname
        Process      = $null
        Path         = $r.Path
        Details      = ("MRU={0}; Used={1}; Interactions={2}" -f $r.MRU, $r.LastUsedEntryNumber, $r.InteractionCount)
        EventId      = $null
        RecordId     = $r.EntryNumber
        PID          = $null
        TID          = $null
        SourceFile   = $r.SourceFile
      }
      $all.Add([pscustomobject]$row)
    }
  }
  $sw.Stop(); Write-Log ("[JumpList] rows={0} elapsed={1}ms" -f (($all | Where-Object { $_.Source -eq 'JumpList' }).Count), $sw.ElapsedMilliseconds)
} catch { Write-Log "[JumpList][ERR] $($_.Exception.Message)" }

# ========== MFT ==========
try {
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $mft = Get-ChildItem (Join-Path $csvDir 'MFT') -Filter *.csv -ErrorAction SilentlyContinue
  Write-Log "[MFT] files: $($mft.Count)"
  foreach ($f in $mft) {
    $rows = Import-Csv -LiteralPath $f.FullName
    foreach ($r in $rows) {
      $ts       = FirstNonEmpty $r.Created0x10 $r.LastRecordChange0x10 $r.LastModified0x10 $r.LastAccess0x10
      $fullPath = $r.FileName
      if ($r.ParentPath) { $fullPath = Join-Path $r.ParentPath $r.FileName }
      $action   = if ($r.IsDirectory -eq 'TRUE') { 'DirMeta' } else { 'FileMeta' }

      $row = [ordered]@{
        TimestampUTC = To-UTC $ts
        Source       = 'MFT'
        SubSource    = 'MFTECmd'
        Artifact     = $r.FileName
        Action       = $action
        User         = $null
        Host         = $null
        Process      = $null
        Path         = $fullPath
        Details      = ("Ext={0}; Size={1}; Flags={2}" -f $r.Extension, $r.FileSize, $r.SiFlags)
        EventId      = $null
        RecordId     = $r.EntryNumber
        PID          = $null
        TID          = $null
        SourceFile   = $r.SourceFile
      }
      $all.Add([pscustomobject]$row)
    }
  }
  $sw.Stop(); Write-Log ("[MFT] rows={0} elapsed={1}ms" -f (($all | Where-Object { $_.Source -eq 'MFT' }).Count), $sw.ElapsedMilliseconds)
} catch { Write-Log "[MFT][ERR] $($_.Exception.Message)" }

# ========== USNJ ($J) ==========
try {
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $usn = Get-ChildItem (Join-Path $csvDir 'USN') -Filter *.csv -ErrorAction SilentlyContinue
  Write-Log "[USNJ] files: $($usn.Count)"
  foreach ($f in $usn) {
    $rows = Import-Csv -LiteralPath $f.FullName
    foreach ($r in $rows) {
      $fullPath = $r.Name
      if ($r.ParentPath) { $fullPath = Join-Path $r.ParentPath $r.Name }

      $row = [ordered]@{
        TimestampUTC = To-UTC $r.UpdateTimestamp
        Source       = 'USNJ'
        SubSource    = 'MFTECmd'
        Artifact     = $r.Name
        Action       = $r.UpdateReasons
        User         = $null
        Host         = $null
        Process      = $null
        Path         = $fullPath
        Details      = ("Attr={0}" -f $r.FileAttributes)
        EventId      = $null
        RecordId     = $r.EntryNumber
        PID          = $null
        TID          = $null
        SourceFile   = $r.SourceFile
      }
      $all.Add([pscustomobject]$row)
    }
  }
  $sw.Stop(); Write-Log ("[USNJ] rows={0} elapsed={1}ms" -f (($all | Where-Object { $_.Source -eq 'USNJ' }).Count), $sw.ElapsedMilliseconds)
} catch { Write-Log "[USNJ][ERR] $($_.Exception.Message)" }

# ---- 並べ替え & 出力 ----
Write-Log "[MERGE] total_rows(before sort)=$($all.Count)"
$sorted = $all | Sort-Object TimestampUTC, Source

# 列順固定
$final  = $sorted | Select-Object $cols

# UTC表記をISO8601に固定（Z付き）
foreach ($i in $final) {
  if ($i.TimestampUTC) {
    $i.TimestampUTC = ([datetime]$i.TimestampUTC).ToUniversalTime().ToString('o')
  }
}

# CSV 書き出し（UTF8）
$final | Export-Csv -NoTypeInformation -LiteralPath $outCsv -Encoding UTF8

$swAll.Stop()
Write-Log ("[DONE] rows={0} file={1} elapsed_total={2}ms" -f $final.Count, $outCsv, $swAll.ElapsedMilliseconds)
"OK: Timeline built. Rows=$($final.Count)`nOutCsv=$outCsv`nLog=$logPath"
