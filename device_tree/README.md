# OPPO A11 (PCHM10) 设备树资料

> ## ⚠️ 重要声明
>
> **本目录下的设备树（DTB / DTS / 重编译结果 / RTIC 元数据）未经过任何测试与编译，
> 可能不能用。**
>
> 这些文件是从原厂 boot 镜像中提取、反编译、整理得到的资料，仅用于学习、对照和
> 二次开发参考。直接把它们刷入设备、替换原厂 DTB、或用于生产环境，可能导致
> 无法开机、硬件异常或其他不可恢复的后果。使用风险由使用者自行承担。
>
> 作者：**小白叶114514**

---

## 1. 目录内容

| 路径 | 说明 |
|---|---|
| `dtb/dtb00` … `dtb25` | 从原厂 boot 镜像中原样提取的 26 个设备 DTB |
| `dtb/dtb26` | 原厂 RTIC MP DTB（173 字节，接口版本 30.3 / MPGen 2.7） |
| `dts/` | 对应 DTB 的反编译 DTS |
| `rebuilt/19021/` | 用内核源码重新编译的 19021 工程 DTB |
| `rebuilt/19375/` | 用内核源码重新编译的 19375 工程 DTB |
| `rebuilt/19571/` | 用内核源码重新编译的 19571 工程 DTB |
| `rtic_mp.dts` | 原厂 RTIC DTS（从原厂 DTB 反编译） |
| `rtic_mp.generated.dts` | 新内核用 MPGen 2.1.1 生成的 RTIC DTS |
| `rtic_mp.generated.dtb` | 上述 DTS 编译得到的 RTIC DTB（173 字节） |
| `manifest.md` | DTB ↔ 工程 / 硬件阶段 / 源码文件对照表 |

---

## 2. 来源与处理方式

1. 从原厂 `[4]boot.img` 的 kernel 载荷中分离出 `Image.gz` 和追加的 DTB 区；
2. 按 FDT 结构逐个切分，得到 26 个设备 DTB 和 1 个 RTIC DTB；
3. 用 `dtc -I dtb -O dts` 反编译为 DTS；
4. 用内核源码 `arch/arm64/boot/dts/oppo/` 下的 DTS 重新编译，和原厂 DTB
   做语义比较（属性/节点差异）；
5. 用 Qualcomm MPGen 2.1.1 为新内核生成 `rtic_mp.dts`，再用 `dtc` 编译。

重编译结果与原厂 DTB **不是逐字节相同**，因为 `dtc` 版本、`/memreserve/`、
属性顺序、`phandle` 分配等都会影响二进制。对比时请用 `dtc -I dtb -O dts`
反编译后比较语义，不要直接 `cmp`。

---

## 3. 使用建议

- **只做对照/研究**：用 `dtc` 反编译后阅读，不要直接刷入；
- 如果确实要替换 DTB，请先备份原厂 boot，并确认设备已解锁、能进 fastboot；
- 不要把这个目录的 DTB 和 `signed/` 里的成品 boot 混用；
- 设备树必须和内核源码、boot 镜像的 DTB 顺序/数量匹配，否则可能卡第一屏；
- 原厂 RTIC DTB 是给原厂内核用的，新内核应使用 `rtic_mp.generated.dtb`。

---

## 4. 再次声明

**本目录所有文件均未经过任何测试与编译验证，可能不能用。**

作者不对因使用本目录内容造成的任何直接或间接损失负责。
