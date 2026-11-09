# OPPO A11 / A11n / A11x / A5 2020 / A9 2020（UFS）核心原始碼與裝置樹

**語言：** [English](README.en.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

- **作者：小白叶114514**
- 核心版本：`4.14.180-XBaiYe`
- 基線：OPPO 官方 SM6125 / trinket F.14 核心原始碼
- KernelSU：v0.9.5，版本碼 `11872`
- 目標機型：OPPO A11 / A11n / A11x、OPPO A5 2020、OPPO A9 2020
  （**僅限 UFS 儲存版本**；A-only，非 A/B）

---

## 1. 專案簡介

本專案包含兩大部分：

1. **完整可編譯的核心原始碼**：OPPO 官方 `android_kernel_oppo_sm6125` 與配套的
   `android_kernel_modules_and_devicetree_oppo_sm6125`，已還原成可編譯的
   Android 原始碼樹佈局，並整合 KernelSU。
2. **完整裝置樹**：從原廠 boot 映像提取的 26 個裝置 DTB、反編譯 DTS、
   重新編譯驗證結果，以及為新核心產生的 RTIC 中繼資料。

> 裝置樹目錄 `device_tree/` 僅作資料整理與參考，**未經過任何測試與編譯，
> 可能不能用**，詳見 [device_tree/README.md](device_tree/README.md)。

---

## 相容機型

已測試可用（**僅限 UFS 儲存版本**）：

| 系列 | 機型 | 平台 |
|---|---|---|
| OPPO A11 系列 | A11 / A11n / A11x | Qualcomm SM6125 (trinket) |
| OPPO A5 2020 | A5 2020 | Qualcomm SM6125 (trinket) |
| OPPO A9 2020 | A9 2020 | Qualcomm SM6125 (trinket) |

使用條件：

- **必須是 UFS 儲存**；eMMC 版本未測試，不保證可用；
- bootloader 已解鎖，能刷入 `boot` 與 `vbmeta`；
- 不同韌體版本、區域版本、電信商版本可能有差異，刷機前務必備份原廠 boot；
- 只刷 boot 不刷 vbmeta，在開啟 AVB 的機器上會不開機。

---

## 2. 特性

- 核心版本 `4.14.180-XBaiYe`（基於 `4.14.180-perf+`）
- KernelSU v0.9.5 / 11872，手動 hook（exec、faccessat、read、stat、input、
  devpts），不依賴 Kprobes
- 官方工具鏈：Snapdragon LLVM ARM Compiler 10.0.7 for Android NDK +
  GNU binutils 2.27
- `SHIPPING_API_LEVEL=28`，包含原廠 API 28 分支的觸控、電池、充電等驅動
- 以 Qualcomm MPGen 2.1.1 產生 RTIC MP 資料與 `rtic_mp.dtb`
- 保留 `CONFIG_MODVERSIONS`、`CONFIG_MODULE_SIG_FORCE`，並內嵌原廠模組簽名憑證
- 匯出符號 CRC 與原廠基線的公共符號差異為 0（基線 11,676，最終 11,675，
  少 1 個 RTIC 相關符號）

---

## 3. 目錄結構

```
.
├─ README.md                     簡體中文主文件
├─ README.en.md                  英文
├─ README.zh-CN.md               簡體中文
├─ README.zh-TW.md               繁體中文（本文件）
├─ kernel-source.tar.gz          核心原始碼（build.sh 在 msm-4.14/ 內）
├─ scripts/build.sh              建置腳本
├─ tools/mpgen/                  Qualcomm MPGen 2.1.1（Python 2）
├─ device_tree/                  裝置樹資料（未測試，可能不能用）
│  ├─ README.md                  裝置樹說明與免責聲明
│  ├─ dtb/                       26 個原廠裝置 DTB + 原廠 RTIC DTB
│  ├─ dts/                       反編譯 DTS
│  ├─ rebuilt/                   原始碼重編譯 DTB（19021/19375/19571）
│  ├─ rtic_mp.generated.dts      新核心產生的 RTIC MP_DATA
│  └─ manifest.md                DTB ↔ 專案/硬體階段/原始碼 對照表
├─ scripts/
│  ├─ sign_boot.sh               一鍵 AVB 簽名
│  ├─ pack_boot.py               boot 映像重新打包
│  ├─ flash_signed.sh            刷入 signed/ 映像
│  └─ flash_stock.sh             恢復原廠
├─ signed/                       簽名後的 boot / vbmeta
└─ artifacts/                    核心、ksud、APK、設定、校驗值
```

原始碼解壓後的佈局：

```
oppo_a11/
├─ android/
│  ├─ kernel/msm-4.14/          核心原始碼（build.sh 在這裡）
│  └─ vendor/                   OPPO/QCOM 配套原始碼
└─ msm_amss/                    OPPO sensor 等 msm_amss 原始碼
```

---

## 4. 依賴工具

| 工具 | 版本／說明 | 用途 |
|---|---|---|
| **Snapdragon LLVM ARM Compiler** | 10.0.7 for Android NDK（SDClang） | 編譯核心（與原廠版本字串一致） |
| **AOSP GCC 4.9** | aarch64-linux-android-4.9 | 提供 GNU as/ld/objcopy 等 |
| **GNU binutils** | 2.27（bd24d23f） | 連結、組譯、objcopy |
| **Qualcomm MPGen** | 2.1.1，`tools/mpgen`，需 Python 2.7 | 產生 RTIC MP / `rtic_mp.dtb` |
| **Python** | Python 2.7（MPGen）、Python 3（打包／簽名腳本） | 建置與打包 |
| **GNU make** | 3.81+ | 建置 |
| **OpenSSL** | 1.1/3.x | 產生 AVB 測試金鑰、憑證處理 |
| **dtc** | 1.4+ | 編譯／反編譯裝置樹 |
| **avbtool** | 1.2.0，`scripts/avbtool.py` | AVB 簽名 |
| **git / curl** | 較新版本 | 取得原始碼與工具 |

建議環境：Ubuntu 22.04，4 核 CPU，6 GB 記憶體，至少 20 GB 可用磁碟空間。
建置路徑**不能包含空格**，否則核心 Makefile 會直接報錯。

---

## 5. 編譯

### 5.1 解壓原始碼

```bash
mkdir -p ~/oppo_a11/android/kernel
tar xzf kernel-source.tar.gz -C ~/oppo_a11/android/kernel
# 同時確認 android/vendor 與 msm_amss 已按上面的佈局放好
cd ~/oppo_a11/android/kernel/msm-4.14
```

> `kernel-source.tar.gz` 只包含核心子目錄；`android/vendor` 與 `msm_amss`
> 來自配套的 modules 原始碼包，需放在同一棵樹的同級目錄。

### 5.2 使用 build.sh

編輯 `build.sh` 頂部的工具鏈路徑，或以環境變數覆蓋：

```bash
export TOOLCHAIN_SDCLANG=/path/to/sdclang1007
export TOOLCHAIN_GCC=/path/to/aarch64
export MPGEN=/path/to/tools/mpgen/mpgen.py
export JOBS=3

./build.sh
```

### 5.3 最終建置參數

`build.sh` 等價於：

```bash
export RTIC_MPGEN="python2 $MPGEN"

make O=out ARCH=arm64 \
  TARGET_PRODUCT=trinket \
  SHIPPING_API_LEVEL=28 \
  RTIC_MPGEN="$RTIC_MPGEN" \
  CC=clang \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE=aarch64-linux-gnu- \
  LD=aarch64-linux-gnu-ld \
  AR=aarch64-linux-gnu-ar \
  NM=aarch64-linux-gnu-nm \
  OBJCOPY=aarch64-linux-gnu-objcopy \
  OBJDUMP=aarch64-linux-gnu-objdump \
  -j3 Image.gz
```

`build.sh` 會自動寫入 `CONFIG_LOCALVERSION="-XBaiYe"`；若手動建置，請確認
`out/.config` 內有這個值。

| 參數 | 值 | 作用 |
|---|---|---|
| `ARCH` | `arm64` | 目標架構 |
| `TARGET_PRODUCT` | `trinket` | OPPO trinket 平台設定 |
| `SHIPPING_API_LEVEL` | `28` | **必須**，否則缺少原廠 API 28 觸控／電池／充電驅動 |
| `RTIC_MPGEN` | `python2 .../mpgen.py` | **必須**，否則核心沒有 RTIC MP 資料 |
| `CONFIG_LOCALVERSION` | `"-XBaiYe"` | 產生 `4.14.180-XBaiYe` |
| `CC` | `clang`（SDClang 10.0.7） | 與原廠一致的編譯器 |
| `CLANG_TRIPLE` | `aarch64-linux-gnu-` | clang target |
| `CROSS_COMPILE` | `aarch64-linux-gnu-` | GNU binutils 前綴 |

### 5.4 產物

```
out/arch/arm64/boot/Image.gz      核心映像
out/vmlinux                       含符號的 ELF
out/System.map                    符號表
out/rtic_mp.dts                   MPGen 產生的 RTIC DTS
out/rtic_mp.dtb                   由 dtc 編譯的 RTIC DTB
```

---

## 6. 打包與刷機

### 6.1 一鍵簽名

```bash
./scripts/sign_boot.sh
```

產物在 `signed/`：

- `boot-signed.img`：KSU 核心 + 26 個 DTB + 新產生的 RTIC
- `vbmeta-disabled-signed.img`：關閉 AVB / dm-verity 的 vbmeta
- `vbmeta-boot-only.img`、`vbmeta-disabled.img`、`vbmeta-stock-flags3.img`：備用

### 6.2 最終映像

- `signed/boot-ksu-XBaiYe.img`：KSU + API28 + RTIC，推薦
- `signed/boot-ksu-XBaiYe-nortic.img`：同上，不含 RTIC，備用
- `signed/boot-signed.img`：`sign_boot.sh` 的預設產物

```bash
sha256sum signed/boot-ksu-XBaiYe.img
# 6f281ea2fb925a16f67979d6218dab5649be6b7a0ff86965ef37614145b526f4
```

### 6.3 刷入

```bash
./scripts/flash_signed.sh \
  signed/boot-ksu-XBaiYe.img \
  signed/vbmeta-disabled-signed.img
```

> 前提：bootloader 已解鎖。只刷 boot 不刷 vbmeta，在開啟 AVB 的機器上會不開機。

### 6.4 恢復原廠

```bash
./scripts/flash_stock.sh
```

---

## 7. 裝置樹

`device_tree/` 包含：

- `dtb/`：從原廠 boot 原樣提取的 26 個裝置 DTB + 1 個原廠 RTIC DTB；
- `dts/`：對應的反編譯 DTS；
- `rebuilt/`：用核心原始碼重新編譯的 DTB，依 19021 / 19375 / 19571 分類；
- `rtic_mp.generated.dts` / `.dtb`：新核心的 RTIC 中繼資料；
- `manifest.md`：DTB ↔ 專案 / 硬體階段 / 原始碼檔案對照表。

> **重要：`device_tree/` 僅作資料整理與參考，未經過任何測試與編譯，
> 可能不能用。** 直接使用導致的任何後果由使用者自行承擔。
> 詳見 [device_tree/README.md](device_tree/README.md)。

---

## 8. 已驗證／限制

已於以下 UFS 機型實測可用：

- OPPO A11 / A11n / A11x
- OPPO A5 2020
- OPPO A9 2020

已驗證：

- 原廠核心重新打包 + 自訂 vbmeta 可開機；
- 原廠原始碼 + `SHIPPING_API_LEVEL=28` 可開機；
- 上述 UFS 機型可正常使用；
- 核心版本字串 `4.14.180-XBaiYe`；
- 官方 SDClang 10.0.7 版本字串與原廠一致；
- 26 個裝置 DTB 與原始碼重編譯結果語意一致；
- 公共匯出符號 CRC 差異 0（11,676 → 11,675，少 1 個 RTIC 相關符號）；
- 原廠模組簽名憑證已內嵌。

限制：

- MPGen 2.1.1 產生的 RTIC 介面版本為 27，原廠為 30.3（2.7）；實測不帶 RTIC
  也能開機；
- AVB 使用本機測試金鑰，bootloader 需接受自訂 vbmeta；
- 長期穩定性、所有廠商模組、SELinux 行為未做壓力測試。

---

## 9. 致謝

- OPPO / Qualcomm 開源原始碼
- KernelSU（tiann/KernelSU）
- Qualcomm MPGen 2.1.1
- DeepSeek Harness
- 以及所有提供協助的大佬

本專案由 **小白叶114514** 整理與維護。
