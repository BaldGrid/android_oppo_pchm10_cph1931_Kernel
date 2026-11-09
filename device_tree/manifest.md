# OPPO A11 (PCHM10) 设备树清单

原厂 `[4]boot.img` 的 kernel 载荷 = `Image.gz` + 26 个设备 DTB + 1 个 RTIC MP DTB。
26 个设备 DTB 已全部与内核源码 `arch/arm64/boot/dts/{19021,19375,19571}` 重新编译出的
DTB 做语义比对：除 `phandle` 属性外完全一致（原厂 dtc 不写 `linux,phandle`）。

| # | 原厂 DTB | oppo,dtsi_no | 工程 | 硬件阶段 | 对应源码 |
|---|----------|--------------|------|----------|----------|
| 0 | dtb00.dtb | 19328 (0x4b80) | 19328 | - | `dts/19021/trinket-19328.dts` |
| 1 | dtb01.dtb | 19026 (0x4a52) | 19026 | - | `dts/19021/trinket-19026.dts` |
| 2 | dtb02.dtb | 19021 (0x4a4d) | 19021 | - | `dts/19021/trinket-19021.dts` |
| 3 | dtb03.dtb | 19321 (0x4b79) | 19321 | - | `dts/19021/trinket-19321.dts` |
| 4 | dtb04.dtb | - | 19021 | base | `dts/19021/trinket.dts` |
| 5 | dtb05.dtb | 19571 (0x4c73) | 19571 | EVT2 | `dts/19571/trinket-EVT2.dts` |
| 6 | dtb06.dtb | 19571 | 19571 | EVT1 | `dts/19571/trinket-EVT1.dts` |
| 7 | dtb07.dtb | 19571 | 19571 | MP1 | `dts/19571/trinket-MP1.dts` |
| 8 | dtb08.dtb | 19571 | 19571 | T0 | `dts/19571/trinket-T0.dts` |
| 9 | dtb09.dtb | 19571 | 19571 | PVT1 | `dts/19571/trinket-PVT1.dts` |
| 10 | dtb10.dtb | 19571 | 19571 | EVB1 | `dts/19571/trinket-EVB1.dts` |
| 11 | dtb11.dtb | 19571 | 19571 | MP2 | `dts/19571/trinket-MP2.dts` |
| 12 | dtb12.dtb | 19571 | 19571 | DVT1 | `dts/19571/trinket-DVT1.dts` |
| 13 | dtb13.dtb | - | 19571 | base | `dts/19571/trinket.dts` |
| 14 | dtb14.dtb | 19571 | 19571 | T1 | `dts/19571/trinket-T1.dts` |
| 15 | dtb15.dtb | 19375 (0x4baf) | 19375 | EVT2 | `dts/19375/trinket-EVT2.dts` |
| 16 | dtb16.dtb | 19375 | 19375 | EVT1 | `dts/19375/trinket-EVT1.dts` |
| 17 | dtb17.dtb | 19375 | 19375 | MP1 | `dts/19375/trinket-MP1.dts` |
| 18 | dtb18.dtb | 19375 | 19375 | T0 | `dts/19375/trinket-T0.dts` |
| 19 | dtb19.dtb | 19375 | 19375 | DVT2 | `dts/19375/trinket-DVT2.dts` |
| 20 | dtb20.dtb | 19375 | 19375 | PVT1 | `dts/19375/trinket-PVT1.dts` |
| 21 | dtb21.dtb | 19375 | 19375 | EVB1 | `dts/19375/trinket-EVB1.dts` |
| 22 | dtb22.dtb | 19375 | 19375 | MP2 | `dts/19375/trinket-MP2.dts` |
| 23 | dtb23.dtb | 19375 | 19375 | DVT1 | `dts/19375/trinket-DVT1.dts` |
| 24 | dtb24.dtb | - | 19375 | base | `dts/19375/trinket.dts` |
| 25 | dtb25.dtb | 19375 | 19375 | T1 | `dts/19375/trinket-T1.dts` |
| 26 | dtb26.dtb | RTIC | - | - | `rtic_mp.dts`（MPGen 生成，非 DTS 编译产物） |

说明：
- `device_tree/dtb/` 是原厂 boot 镜像里原样提取的 DTB（打包时使用这一份）。
- `device_tree/dts/` 是用 dtc 反编译出的可读 DTS。
- `device_tree/rebuilt/` 是用内核源码重新编译出的 DTB（用于验证源码完整性）。
- `device_tree/rtic_mp.dts` 是原厂 RTIC 元数据，MP_DATA 中含内核对齐摘要。
