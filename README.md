# build-openwrt-with-actions

使用 GitHub Actions 云编译 OpenWrt / ImmortalWrt 固件，目标设备为 **小米 MiWiFi Mini（ramips/mt7620）**。

## 使用方法

1. **Fork 本仓库**
2. 进入 **Actions** 页面，选择要编译的 workflow：
   - `🚀 编译 immortalwrt` → 编译 ImmortalWrt（默认 `immortalwrt/immortalwrt` 仓库，`openwrt-24.10` 分支）
   - `🚀 编译 openwrt` → 编译 OpenWrt（默认 `coolsnowwolf/lede` 仓库，`master` 分支）
3. 点击 **Run workflow** 手动触发，可配置参数：
   - `owner` / `repo` / `branch`：编译的源码仓库
   - `multithreading`：多线程编译（默认开启）
   - `ssh`：是否开启 SSH 调试（编译中可连入环境手动改配置）
   - `isFiles`：是否使用 `files/` 目录覆盖配置（详见下文）
   - `skip_download`：是否跳过 `make download`（默认开启，省磁盘、省时间）
4. 编译完成后，在 run 页面下载 **Artifact**：`openWRT-build-result`（tar.xz 打包的 `bin/targets` 固件）

### 配置方式（三选一）

| 方式 | 说明 |
|---|---|
| **`diy.sh`** | 编译前自动执行，已内置：LAN IP `192.168.31.1`、主机名、双频 WiFi 名称、中文界面、首次开机脚本 `99-custom`（uci-defaults） |
| **`.config`** | 仓库根目录的完整 OpenWrt 配置，编译时自动复制到源码目录 |
| **`files/` 目录 + `isFiles=true`** | 把已有 OpenWrt 的 `/etc` 下配置放入 `files/`，编译时自动覆盖，更新固件不丢配置 |

> 提示：勾选太多插件会导致编译慢甚至报错，建议按需勾选、增量测试。

### 仓库可见性（重要）

- **公开仓库**：可使用 GitHub 约 120G 存储空间，编译稳定
- **私有仓库**：存储空间受限（约 50G+），**大概率报磁盘空间不足**，建议保持公开

## 首次开机默认配置（99-custom）

由 `diy.sh` 在编译时写入 `package/base-files/files/etc/uci-defaults/99-custom`，首次开机自动生效：

- **LAN IP**：`192.168.31.1`
- **主机名**：`Xiaomi Mini`
- **2.4G WiFi**：`MIwifi`（无密码）
- **5G WiFi**：`MIwifi`（无密码）
- **时区**：`Asia/Shanghai (CST-8)`
- **root 密码**：默认空（ImmortalWrt 默认），如需设置请修改 `diy.sh` 中 `root_password` 变量

修改 `diy.sh` 顶部的变量即可自定义（如 WiFi 名、密码、PPPoE 拨号账号等）。

## 默认 .config 摘要

- 目标：`ramips/mt7620`，设备 `Xiaomi MiWiFi Mini`
- 存储：160M 内核空间 / 1600M root 空间
- 主题：`luci-theme-argon`（默认）、`luci-theme-bootstrap`
- 无线中继：`relayd` + `luci-proto-relay`（支持无线中继/WISP）
- 基础组件：`luci-app-firewall`、`luci-app-package-manager`、`luci-app-commands`、`wpad-basic`、`wireless-regdb`

## 常见问题

### 编译失败：磁盘空间不足
- 原因：私有仓库存储受限，或磁盘优化步骤异常
- 解决：将仓库设为**公开**；workflow 已包含手动清理步骤与磁盘检查（<8G 自动中止）

### 预清理步骤报错 "No such file or directory"
- 已修复：预清理不再使用 `working-directory: openWRT`（目录在克隆前不存在），改为显式路径

### 如何开启无线中继
- 固件已包含 `relayd` 与 `luci-proto-relay`，开机后在 LuCI「网络 → 无线」中选择对应接口，模式选「Client」+「中继桥接（relayd）」即可

## 更新日志

- 2026-08-06：修复两个 workflow（immortalwrt / openwrt）——移除 `maximize-build-space`（曾导致根分区 100% 满）、预清理步骤去掉 `working-directory`、磁盘阈值统一为 8G
- 2026-08-06：diy.sh 内置首次开机配置（uci-defaults 99-custom），不依赖 files 大法
- 2025-11-08：初始版本
