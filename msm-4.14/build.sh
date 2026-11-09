#!/bin/bash
# OPPO A11 (PCHM10 / trinket) kernel build script
# Author: 小白叶114514
#
# Final parameters:
#   ARCH=arm64  TARGET_PRODUCT=trinket  SHIPPING_API_LEVEL=28
#   CC=SDClang 10.0.7  CROSS_COMPILE=aarch64-linux-gnu-
#   RTIC_MPGEN=python2 .../mpgen.py
#   CONFIG_LOCALVERSION="-XBaiYe"  ->  4.14.180-XBaiYe
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
cd "$SRC"

# ---- overridable paths -----------------------------------------------------
TOOLCHAIN_SDCLANG="${TOOLCHAIN_SDCLANG:-/home/xbaiye/oppo_a11/toolchain/sdclang1007}"
TOOLCHAIN_GCC="${TOOLCHAIN_GCC:-/home/xbaiye/oppo_a11/toolchain/aarch64}"
MPGEN="${MPGEN:-/home/xbaiye/oppo_a11/mpgen/common/scripts/mpgen/mpgen.py}"
JOBS="${JOBS:-3}"
OUT="${OUT:-out}"

# ---- environment -----------------------------------------------------------
export PATH="$TOOLCHAIN_SDCLANG/bin:$TOOLCHAIN_GCC/bin:$PATH"
export LD_LIBRARY_PATH="$TOOLCHAIN_SDCLANG/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
unset LOCALVERSION

if ! command -v python2 >/dev/null 2>&1; then
    echo "ERROR: python2 is required by Qualcomm MPGen 2.1.1" >&2
    exit 1
fi
if [ ! -f "$MPGEN" ]; then
    echo "ERROR: MPGen not found: $MPGEN" >&2
    exit 1
fi
export RTIC_MPGEN="${RTIC_MPGEN:-python2 $MPGEN}"

# ---- output dir / config ---------------------------------------------------
mkdir -p "$OUT"
if [ ! -f "$OUT/.config" ] && [ -f "$SRC/configs/trinket-XBaiYe.config" ]; then
    echo "[*] using bundled config: configs/trinket-XBaiYe.config"
    cp "$SRC/configs/trinket-XBaiYe.config" "$OUT/.config"
fi
if [ ! -f "$OUT/.config" ]; then
    echo "[*] generating base config (vendor/trinket-perf_defconfig)"
    make O="$OUT" ARCH=arm64 TARGET_PRODUCT=trinket \
        CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- \
        vendor/trinket-perf_defconfig
fi

# Force the requested local version, regardless of the base config.
"$SRC/scripts/config" --file "$OUT/.config" --set-str LOCALVERSION "-XBaiYe"
make O="$OUT" ARCH=arm64 TARGET_PRODUCT=trinket SHIPPING_API_LEVEL=28 \
    CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- \
    olddefconfig >/dev/null

echo "[*] building Image.gz ..."
make O="$OUT" ARCH=arm64 TARGET_PRODUCT=trinket SHIPPING_API_LEVEL=28 \
    RTIC_MPGEN="$RTIC_MPGEN" \
    CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- \
    LD=aarch64-linux-gnu-ld AR=aarch64-linux-gnu-ar NM=aarch64-linux-gnu-nm \
    OBJCOPY=aarch64-linux-gnu-objcopy OBJDUMP=aarch64-linux-gnu-objdump \
    -j"$JOBS" Image.gz

# ---- RTIC DTB --------------------------------------------------------------
if [ -f "$OUT/rtic_mp.dts" ]; then
    echo "[*] compiling RTIC DTB ..."
    dtc -I dts -O dtb -o "$OUT/rtic_mp.dtb" -b 0 "$OUT/rtic_mp.dts"
fi

echo
echo "[+] build finished"
echo "    kernel : $OUT/arch/arm64/boot/Image.gz"
echo "    vmlinux: $OUT/vmlinux"
echo "    RTIC   : $OUT/rtic_mp.dtb"
echo "    version: $(strings "$OUT/vmlinux" | grep -m1 'Linux version')"
