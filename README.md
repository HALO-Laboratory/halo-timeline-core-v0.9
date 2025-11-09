# HALO-TIMELINE Core v0.9
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![DFIR](https://img.shields.io/badge/DFIR-Forensics-blueviolet)]()
[![Reproducible](https://img.shields.io/badge/Reproducible-Yes-brightgreen)]()

Minimal DFIR timeline builder for learning and reproducible analysis.

> **First, get it to run once. Understanding starts from there.**

HALO-TIMELINE Core v0.9 merges key Windows forensic artifacts  
(**EVTX / LNK / JumpList / MFT / USNJ**) into a single timeline CSV.  
It is designed to stay **minimal** and **reproducible**, especially for learners practicing timeline-based investigation workflows.

---

## ✨ Features
- Single PowerShell entrypoint (`Build-HALO-Timeline.ps1`)
- No extra external tools required
- Reproducible results suitable for training / workshops
- Easy to modify or extend for your own learning environment

---

## 🚀 Quick Start

### 1) Clone the repository
```powershell
git clone https://github.com/HALO-Laboratory/halo-timeline-core-v0.9.git
cd halo-timeline-core-v0.9/HALO-TIMELINE_v0.9
```

### 2) Run the timeline builder
```powershell
powershell -ExecutionPolicy Bypass -File .\Build-HALO-Timeline.ps1 -Root ".\examples\example_case"
```

### 3) Output location
```
examples/example_case/Timeline/super_timeline_v09.csv
```

Open the CSV in:
- Excel
- Timeline Explorer
- Your preferred analysis tool

---

## 📂 Project Structure
```
HALO-TIMELINE_v0.9/
 ├─ Build-HALO-Timeline.ps1        # Main timeline builder
 ├─ csv/                           # Place extracted CSVs here
 │   ├─ Evtx/
 │   ├─ LNK/
 │   ├─ JumpList/
 │   ├─ MFT/
 │   └─ USNJ/
 ├─ examples/
 │   └─ example_case/              # Minimal demonstration input & output
 └─ docs/
     ├─ README.md                  # Detailed usage and background
     ├─ RELEASE_NOTES_v0.9.md
     └─ REPRO_CHECKLIST.md         # Reproducibility checklist
```

---

## 🧭 HALO Philosophy

```
Clear. Reproducible. Sharable.
```

This project focuses on **reproducible forensic workflow**.  
Not just *"run a tool"*, but *"understand what happened and why."*

---

## 📄 License
This project is released under the **MIT License**.

---

## 🌱 Next Steps for Learners
- Run against another real or training case
- Compare artifacts across layers (EVTX ↔ LNK ↔ MFT ↔ USNJ)
- Practice explaining *why* each action occurred in sequence

---

**HALO-Laboratory**  
For people who learn by *doing*, not by watching.
