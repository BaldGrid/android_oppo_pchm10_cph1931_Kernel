# OPPO A11 / A11n / A11x / A5 2020 / A9 2020 (UFS) Kernel Source & Device Tree

**Languages:** [English](README.en.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

- **Author:** 小白叶114514
- **Kernel version:** `4.14.180-XBaiYe`
- **Base:** OPPO official SM6125 / trinket F.14 kernel source
- **KernelSU:** v0.9.5, version code `11872`
- **Target devices:** OPPO A11 / A11n / A11x, OPPO A5 2020, OPPO A9 2020
  (**UFS storage variants only**; A-only, not A/B)

---

## 1. Compatibility

Tested and working on the following **UFS** devices:

| Series | Models | Platform |
|---|---|---|
| OPPO A11 series | A11 / A11n / A11x | Qualcomm SM6125 (trinket) |
| OPPO A5 2020 | A5 2020 | Qualcomm SM6125 (trinket) |
| OPPO A9 2020 | A9 2020 | Qualcomm SM6125 (trinket) |

Requirements and caveats:

- **UFS storage only.** eMMC variants have not been tested and are not supported.
- The bootloader must be unlocked, and you must be able to flash both `boot`
  and `vbmeta`.
- Different firmware, region or carrier builds may behave differently. Always
  back up the original boot image first.
- Flashing only `boot` without a matching `vbmeta` will fail to boot on devices
  with AVB enabled.

---

## 2. Overview

This repository contains two major parts:

1. **A complete, buildable kernel source tree** based on OPPO's
   `android_kernel_oppo_sm6125` and the matching
   `android_kernel_modules_and_devicetree_oppo_sm6125`, restored to a working
   Android source layout and integrated with KernelSU.
2. **A complete device tree collection**: the 26 factory DTBs extracted from
   the stock boot image, decompiled DTS files, recompiled results, and the RTIC
   metadata generated for the new kernel.

> The `device_tree/` directory is provided **for reference only**. Its contents
> have **not been tested or compiled as a complete device tree and may not
> work**. See [device_tree/README.md](device_tree/README.md).

---

## 3. Features

- Kernel `4.14.180-XBaiYe` (based on `4.14.180-perf+`)
- KernelSU v0.9.5 / 11872 with manual hooks (exec, faccessat, read, stat, input,
  devpts), no Kprobes dependency
- Official toolchain: Snapdragon LLVM ARM Compiler 10.0.7 for Android NDK +
  GNU binutils 2.27
- `SHIPPING_API_LEVEL=28`, including the factory API 28 touch, battery and
  charger drivers
- RTIC MP data and `rtic_mp.dtb` generated with Qualcomm MPGen 2.1.1
- `CONFIG_MODVERSIONS` and `CONFIG_MODULE_SIG_FORCE` kept, with the factory
  module signing certificate embedded
- Exported-symbol CRC parity with the factory baseline (common symbols: 0
  differences; 11,676 baseline vs 11,675 final, one RTIC-related symbol less)

---

## 4. Repository Layout

```
.
├─ README.md                     Simplified Chinese main document
├─ README.en.md                  English
├─ README.zh-CN.md               Simplified Chinese
├─ README.zh-TW.md               Traditional Chinese
├─ kernel-source.tar.gz          Kernel source (build.sh is inside msm-4.14/)
├─ scripts/build.sh              Build helper
├─ tools/mpgen/                  Qualcomm MPGen 2.1.1 (Python 2)
├─ device_tree/                  Device tree data (not tested, may not work)
├─ scripts/
│  ├─ sign_boot.sh               One-click AVB signing
│  ├─ pack_boot.py               Boot image repacking
│  ├─ flash_signed.sh            Flash signed images
│  └─ flash_stock.sh             Restore stock
├─ signed/                       Signed boot / vbmeta images
└─ artifacts/                    Kernel, ksud, APK, config, checksums
```

Kernel source layout after extraction:

```
oppo_a11/
├─ android/
│  ├─ kernel/msm-4.14/          Kernel source (build.sh lives here)
│  └─ vendor/                   OPPO/QCOM companion sources
└─ msm_amss/                    OPPO sensor and other msm_amss sources
```

---

## 5. Requirements

| Tool | Version / Notes | Purpose |
|---|---|---|
| **Snapdragon LLVM ARM Compiler** | 10.0.7 for Android NDK (SDClang) | Kernel compiler; matches the factory version string |
| **AOSP GCC 4.9** | aarch64-linux-android-4.9 | GNU as/ld/objcopy |
| **GNU binutils** | 2.27 (bd24d23f) | Linker, assembler, objcopy |
| **Qualcomm MPGen** | 2.1.1, `tools/mpgen`, requires Python 2.7 | Generates RTIC MP / `rtic_mp.dtb` |
| **Python** | Python 2.7 for MPGen, Python 3 for packaging/signing | Build and packaging |
| **GNU make** | 3.81+ | Build |
| **OpenSSL** | 1.1/3.x | AVB test key generation and certificate handling |
| **dtc** | 1.4+ | Compile/decompile device trees |
| **avbtool** | 1.2.0, `scripts/avbtool.py` | AVB signing |
| **git / curl** | Recent versions | Fetching sources and tools |

Recommended environment: Ubuntu 22.04, 4 CPU cores, 6 GB RAM, at least 20 GB
free disk space. **The build path must not contain spaces**, otherwise the
kernel Makefile will fail immediately.

---

## 6. Build

### 6.1 Extract the source

```bash
mkdir -p ~/oppo_a11/android/kernel
tar xzf kernel-source.tar.gz -C ~/oppo_a11/android/kernel
# Make sure android/vendor and msm_amss are placed alongside, as shown above.
cd ~/oppo_a11/android/kernel/msm-4.14
```

> `kernel-source.tar.gz` contains only the kernel subdirectory. `android/vendor`
> and `msm_amss` come from the companion modules source package and must be
> placed in the same tree.

### 6.2 Use build.sh

Edit the toolchain paths at the top of `build.sh`, or override them with
environment variables:

```bash
export TOOLCHAIN_SDCLANG=/path/to/sdclang1007
export TOOLCHAIN_GCC=/path/to/aarch64
export MPGEN=/path/to/tools/mpgen/mpgen.py
export JOBS=3

./build.sh
```

### 6.3 Final build parameters

`build.sh` is equivalent to:

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

`build.sh` also sets `CONFIG_LOCALVERSION="-XBaiYe"` automatically. If you build
manually, make sure `out/.config` contains that value.

| Parameter | Value | Purpose |
|---|---|---|
| `ARCH` | `arm64` | Target architecture |
| `TARGET_PRODUCT` | `trinket` | OPPO trinket platform configuration |
| `SHIPPING_API_LEVEL` | `28` | **Required**; without it the factory API 28 touch/battery/charger drivers are missing |
| `RTIC_MPGEN` | `python2 .../mpgen.py` | **Required**; generates RTIC MP data |
| `CONFIG_LOCALVERSION` | `"-XBaiYe"` | Produces `4.14.180-XBaiYe` |
| `CC` | `clang` (SDClang 10.0.7) | Matches the factory compiler |
| `CLANG_TRIPLE` | `aarch64-linux-gnu-` | Clang target triple |
| `CROSS_COMPILE` | `aarch64-linux-gnu-` | GNU binutils prefix |

### 6.4 Outputs

```
out/arch/arm64/boot/Image.gz      Kernel image
out/vmlinux                       ELF with symbols
out/System.map                    Symbol table
out/rtic_mp.dts                   RTIC DTS generated by MPGen
out/rtic_mp.dtb                   RTIC DTB (compiled by build.sh)
```

---

## 7. Packaging and Flashing

### 7.1 One-click signing

```bash
./scripts/sign_boot.sh
```

Outputs in `signed/`:

- `boot-signed.img`: KSU kernel + 26 DTBs + generated RTIC
- `vbmeta-disabled-signed.img`: AVB/dm-verity disabled vbmeta
- `vbmeta-boot-only.img`, `vbmeta-disabled.img`, `vbmeta-stock-flags3.img`:
  fallback variants

### 7.2 Final images

- `signed/boot-ksu-XBaiYe.img`: KSU + API28 + RTIC, recommended
- `signed/boot-ksu-XBaiYe-nortic.img`: same, without RTIC, fallback
- `signed/boot-signed.img`: default output of `sign_boot.sh`

```bash
sha256sum signed/boot-ksu-XBaiYe.img
# 6f281ea2fb925a16f67979d6218dab5649be6b7a0ff86965ef37614145b526f4
```

### 7.3 Flash

```bash
./scripts/flash_signed.sh \
  signed/boot-ksu-XBaiYe.img \
  signed/vbmeta-disabled-signed.img
```

> The bootloader must be unlocked. Flashing only `boot` without `vbmeta` will
> fail to boot on devices with AVB enabled.

### 7.4 Restore stock

```bash
./scripts/flash_stock.sh
```

---

## 8. Device Tree

`device_tree/` contains:

- `dtb/`: 26 factory device DTBs and one factory RTIC DTB;
- `dts/`: decompiled DTS files;
- `rebuilt/`: DTBs rebuilt from source (19021 / 19375 / 19571);
- `rtic_mp.generated.dts` / `.dtb`: RTIC metadata for the new kernel;
- `manifest.md`: DTB ↔ project / hardware stage / source mapping.

> **Important: `device_tree/` is for reference only. It has not been tested or
> compiled as a complete device tree and may not work.** Use it at your own
> risk. See [device_tree/README.md](device_tree/README.md).

---

## 9. Verified / Limitations

Tested on real UFS devices:

- OPPO A11 / A11n / A11x
- OPPO A5 2020
- OPPO A9 2020

Verified:

- Stock kernel repack + custom vbmeta boots;
- Stock source + `SHIPPING_API_LEVEL=28` boots;
- The UFS variants above work;
- Kernel version string `4.14.180-XBaiYe`;
- SDClang 10.0.7 version string matches the factory kernel;
- 26 device DTBs are semantically consistent with the rebuilt DTBs;
- Common exported-symbol CRCs: 0 differences (11,676 baseline vs 11,675 final);
- Factory module signing certificate embedded.

Limitations:

- RTIC generated by MPGen 2.1.1 uses interface version 27, while the factory
  uses 30.3 (MPGen 2.7). Booting without RTIC has been verified to work.
- AVB uses a local test key; the bootloader must accept the custom vbmeta.
- Long-term stability, every vendor module and SELinux behavior have not been
  stress-tested.

---

## 10. Credits

- OPPO / Qualcomm open-source kernel sources
- KernelSU (tiann/KernelSU)
- Qualcomm MPGen 2.1.1
- DeepSeek Harness
- Everyone who helped with debugging

Maintained by **小白叶114514**.
