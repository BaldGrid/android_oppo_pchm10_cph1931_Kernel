# OPPO A11 / A11n / A11x / A5 2020 / A9 2020（UFS）内核源码与设备树

**语言 / Languages：** [English](README.en.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

> 当前文件是简体中文版本；[README.md](README.md) 是同一内容的主文档。

- **作者：小白叶114514**
- 内核版本：`4.14.180-XBaiYe`
- 基线：OPPO 官方 SM6125 / trinket F.14 内核源码
- KernelSU：v0.9.5，版本码 `11872`
- 目标设备：OPPO A11 / A11n / A11x、OPPO A5 2020、OPPO A9 2020（**仅 UFS 存储版本**；A-only，非 A/B）

---

## 1. 项目简介

本项目包含两大部分：

1. **完整可编译的内核源码**：OPPO 官方 `android_kernel_oppo_sm6125` + 配套
   `android_kernel_modules_and_devicetree_oppo_sm6125`，已还原成可编译的
   Android 源码树布局，并集成 KernelSU。
2. **完整设备树**：从原厂 boot 镜像提取的 26 个设备 DTB、反编译 DTS、
   重新编译验证结果、以及按新内核生成的 RTIC 元数据。

> 设备树目录 `device_tree/` 仅作资料整理与参考，**未经过任何测试与编译，
> 可能不能用**，详见 [device_tree/README.md](device_tree/README.md)。

---

## 兼容机型

已测试可用（**仅限 UFS 存储版本**）：

| 系列 | 机型 | 平台 |
|---|---|---|
| OPPO A11 系列 | A11 / A11n / A11x | Qualcomm SM6125 (trinket) |
| OPPO A5 2020 | A5 2020 | Qualcomm SM6125 (trinket) |
| OPPO A9 2020 | A9 2020 | Qualcomm SM6125 (trinket) |

使用条件：

- **必须是 UFS 存储**；eMMC 版本未测试，不保证可用；
- bootloader 已解锁，能刷入 `boot` 和 `vbmeta`；
- 不同固件版本、区域版本、运营商版本可能有差异，刷前务必备份原厂 boot；
- 只刷 boot 不刷 vbmeta，在开启 AVB 的机器上会不开机。

---

## 2. 特性

- 内核版本 `4.14.180-XBaiYe`（基于 `4.14.180-perf+`）
- KernelSU v0.9.5 / 11872，手动 hook（exec、faccessat、read、stat、input、devpts），不依赖 Kprobes
- 官方工具链：Snapdragon LLVM ARM Compiler 10.0.7 for Android NDK + GNU binutils 2.27
- `SHIPPING_API_LEVEL=28`，包含原厂 API 28 分支的触摸、电池、充电等驱动
- Qualcomm MPGen 2.1.1 生成 RTIC MP 数据与 `rtic_mp.dtb`
- 保留 `CONFIG_MODVERSIONS`、`CONFIG_MODULE_SIG_FORCE`，并内嵌原厂模块签名证书
- 公共导出符号 CRC 与原厂基线差异为 0（基线 11,676，最终 11,675，少 1 个 RTIC 相关符号）

---

## 3. 目录结构

```
.
├─ README.md                     本文件
├─ README_构建说明.md            完整的构建记录、踩坑与验证过程
├─ 刷机与救砖.md                 刷机、诊断、恢复步骤
├─ kernel-source.tar.gz          完整内核源码（解压到不含空格的路径）
├─ scripts/build.sh              构建脚本（内核源码根目录也有 build.sh）
├─ tools/mpgen/                  Qualcomm MPGen 2.1.1（Python 2）
├─ device_tree/                  设备树资料（未测试，可能不能用）
│  ├─ README.md                  设备树说明与免责声明
│  ├─ dtb/                       26 个原厂设备 DTB + 原厂 RTIC DTB
│  ├─ dts/                       反编译 DTS
│  ├─ rebuilt/                   源码重编译 DTB（19021/19375/19571）
│  ├─ rtic_mp.generated.dts      新内核生成的 RTIC MP_DATA
│  └─ manifest.md                DTB ↔ 工程/硬件阶段/源码 对照表
├─ scripts/
│  ├─ build.sh                   构建脚本（工作区版本）
│  ├─ sign_boot.sh               一键 AVB 签名
│  ├─ pack_boot.py               boot 镜像重打包
│  ├─ flash_signed.sh            刷入 signed/ 镜像
│  └─ flash_stock.sh             恢复原厂
├─ signed/                       签名后的 boot / vbmeta
└─ artifacts/                    内核、ksud、APK、配置、校验值
```

源码解压后的布局：

```
oppo_a11/
├─ android/
│  ├─ kernel/msm-4.14/          内核源码（build.sh 在这里）
│  └─ vendor/                   OPPO/QCOM 配套源码
└─ msm_amss/                    OPPO sensor 等 msm_amss 源码
```

---

## 4. 依赖的工具

| 工具 | 版本/说明 | 用途 |
|---|---|---|
| **Snapdragon LLVM ARM Compiler** | 10.0.7 for Android NDK（SDClang） | 编译内核（与原厂版本串一致） |
| **AOSP GCC 4.9** | aarch64-linux-android-4.9 | 提供 GNU as/ld/objcopy 等 |
| **GNU binutils** | 2.27（bd24d23f） | 链接、汇编、objcopy |
| **Qualcomm MPGen** | 2.1.1，`tools/mpgen`，需 Python 2.7 | 生成 RTIC MP / `rtic_mp.dtb` |
| **Python** | Python 2.7（MPGen）、Python 3（打包/签名脚本） | 构建与打包 |
| **GNU make** | 3.81+ | 构建 |
| **OpenSSL** | 1.1/3.x | 生成 AVB 测试密钥、证书处理 |
| **dtc** | 1.4+ | 编译/反编译设备树 |
| **avbtool** | 1.2.0，`scripts/avbtool.py` | AVB 签名 |
| **git / curl** | 任意较新版本 | 获取源码、工具 |

推荐环境：Ubuntu 22.04，4 核 CPU，6 GB 内存，至少 20 GB 空闲磁盘。
构建目录**不能包含空格**，否则内核 Makefile 会直接报错。

工具链目录示例：

```
toolchain/
├─ sdclang1007/      Snapdragon LLVM 10.0.7
└─ aarch64/          AOSP GCC 4.9 + binutils 2.27
```

---

## 5. 编译

### 5.1 解压源码

```bash
mkdir -p ~/oppo_a11/android/kernel
tar xzf kernel-source.tar.gz -C ~/oppo_a11/android/kernel
# 同时确保 android/vendor 与 msm_amss 已按上面的源码布局放好
cd ~/oppo_a11/android/kernel/msm-4.14
```

> `kernel-source.tar.gz` 只包含内核子目录；`android/vendor` 与 `msm_amss`
> 来自配套的 modules 源码包，需要按上面的源码布局放在同级目录。

### 5.2 使用 build.sh

编辑 `build.sh` 顶部的工具链路径，或通过环境变量覆盖：

```bash
export TOOLCHAIN_SDCLANG=/path/to/sdclang1007
export TOOLCHAIN_GCC=/path/to/aarch64
export MPGEN=/path/to/tools/mpgen/mpgen.py
export JOBS=3

./build.sh
```

### 5.3 最终构建参数

`build.sh` 等价于：

> 直接 `make` 时请确保 `out/.config` 中 `CONFIG_LOCALVERSION="-XBaiYe"`；
> 推荐直接用 `./build.sh`，它会自动写入。手动构建示例：

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

关键参数说明：

| 参数 | 值 | 作用 |
|---|---|---|
| `ARCH` | `arm64` | 目标架构 |
| `TARGET_PRODUCT` | `trinket` | 选择 OPPO trinket 平台配置 |
| `SHIPPING_API_LEVEL` | `28` | **必须**，否则缺少原厂 API 28 触摸/电池/充电驱动 |
| `RTIC_MPGEN` | `python2 .../mpgen.py` | **必须**，否则内核没有 RTIC MP 数据 |
| `CONFIG_LOCALVERSION` | `"-XBaiYe"` | 生成 `4.14.180-XBaiYe`（`build.sh` 自动写入） |
| `CC` | `clang`（SDClang 10.0.7） | 与原厂一致的编译器 |
| `CLANG_TRIPLE` | `aarch64-linux-gnu-` | clang target |
| `CROSS_COMPILE` | `aarch64-linux-gnu-` | GNU binutils 前缀 |

### 5.4 产物

```
out/arch/arm64/boot/Image.gz      内核镜像
out/vmlinux                       带符号 ELF
out/System.map                    符号表
out/rtic_mp.dts                   MPGen 生成的 RTIC DTS
out/rtic_mp.dtb                   建议用 dtc 编译后追加到 boot
```

`build.sh` 会自动用 `dtc` 把 `out/rtic_mp.dts` 编译成 `out/rtic_mp.dtb`。

---

## 6. 打包与刷机

### 6.1 一键签名

```bash
./scripts/sign_boot.sh
```

产物在 `signed/`：

- `boot-signed.img`：KSU 内核 + 26 个 DTB + 新生成的 RTIC
- `vbmeta-disabled-signed.img`：关闭 AVB / dm-verity 的 vbmeta
- `vbmeta-boot-only.img`、`vbmeta-disabled.img`、`vbmeta-stock-flags3.img`：备用

### 6.0 最终镜像

- `signed/boot-ksu-XBaiYe.img`：KSU + API28 + RTIC，推荐
- `signed/boot-ksu-XBaiYe-nortic.img`：同上，不带 RTIC，备用
- `signed/boot-signed.img`：与 `boot-ksu-XBaiYe.img` 相同的默认产物

```bash
sha256sum signed/boot-ksu-XBaiYe.img
# 6f281ea2fb925a16f67979d6218dab5649be6b7a0ff86965ef37614145b526f4
```

### 6.2 刷入

```bash
./scripts/flash_signed.sh \
  signed/boot-ksu-XBaiYe.img \
  signed/vbmeta-disabled-signed.img
```

> 前提：bootloader 已解锁。只刷 boot 不刷 vbmeta，在开启 AVB 的机器上会不开机。

### 6.3 恢复原厂

```bash
./scripts/flash_stock.sh
```

更多诊断与救砖步骤见 [刷机与救砖.md](刷机与救砖.md)。

---

## 7. 设备树

`device_tree/` 包含：

- `dtb/`：从原厂 boot 原样提取的 26 个设备 DTB + 1 个原厂 RTIC DTB；
- `dts/`：对应反编译 DTS；
- `rebuilt/`：用内核源码重新编译的 DTB，按 19021 / 19375 / 19571 分类；
- `rtic_mp.generated.dts` / `.dtb`：新内核的 RTIC 元数据；
- `manifest.md`：DTB ↔ 工程 / 硬件阶段 / 源码文件对照表。

> **重要：`device_tree/` 仅作资料整理与参考，未经过任何测试与编译，
> 可能不能用。** 直接使用导致的任何后果由使用者自行承担。
> 详见 [device_tree/README.md](device_tree/README.md)。

---

## 8. 已验证 / 未验证

已在以下 UFS 机型实测可用：

- OPPO A11 / A11n / A11x
- OPPO A5 2020
- OPPO A9 2020

实测内容：

- 原厂内核重打包 + 自定义 vbmeta 可开机；
- 原厂源码 + `SHIPPING_API_LEVEL=28` 可开机；
- 上述机型 UFS 版本可正常使用。

待真机确认：

- 最终 KernelSU 镜像 `signed/boot-ksu-XBaiYe.img` 的开机与 root 授权。

本机构建层面验证：

- 内核版本串 `4.14.180-XBaiYe`；
- 官方 SDClang 10.0.7 版本串与原厂一致；
- 26 个设备 DTB 与源码重编译结果语义一致；
- 公共导出符号 CRC 差异 0（11,676 → 11,675，少 1 个 RTIC 相关符号）；
- 原厂模块签名证书已内嵌。

未验证/有限制：

- RTIC MPGen 2.1.1 生成的接口版本为 27，原厂为 30.3（2.7）；实测不带 RTIC 也能开机；
- AVB 使用本地测试密钥，bootloader 需接受自定义 vbmeta；
- 长期稳定性、所有厂商模块、SELinux 行为未做压力测试。

---

## 9. 致谢

- OPPO / Qualcomm 开源源码
- KernelSU（tiann/KernelSU）
- Qualcomm MPGen 2.1.1
- DeepSeek Harness
- 以及所有提供帮助的大佬

本项目由 **小白叶114514** 整理与维护。
