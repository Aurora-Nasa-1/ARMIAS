**简体中文** | [日本語](README_JP.md) | [English](README_EN.md)

# 高自定义度的自动安装模块

## 简介

本模块旨在提供一个高自定义度的自动安装和配置解决方案，支持多种语言和多种功能，也包括批量安装 APK、从网络下载文件、安装后模块修补等功能。

## 基础操作

### 1. 批量模块安装

- 将需要安装的所有模块（zip 文件）放入 `./files/modules` 文件夹中。

### 2. 备份模块/自动打包本模块

- 将此模块 zip 文件夹解压。
- 使用`SU`权限运行Cilck.sh脚本，可以自行选择备份模块和打包本模块，内置了多种功能。

## 进阶功能（安装本模块时）（可选阅读）

### DATA 和 SDCARD 一键覆盖

- 鉴于某些模块安装后会生成配置文件等在`/data/`或`Android`文件夹中，本模块提供一键将模块内目标文件批量复制至`/data/`或`/sdcard/`的功能，便于模块的配置与使用。
- 同时，也支持直接修改 `data` 和 `sdcard`。
  **注意**：此操作会覆盖目标目录下的所有文件，请确保设置了正确的文件夹结构，并 **正确设置权限**。
  模块内目录示例：`./files/patches/sdcard/`, `./files/patches/data/`, `./files/patches/apks/`
- `./files/patches/apks/`下的apk文件会被批量安装

### 从网络下载文件

- 支持获取某个 GitHub 仓库的最新的特定 release 文件。（Beta）
- 支持批量下载文件。
- 支持批量下载模块并安装。

### 安装后模块修补

- 将 `./files/patches/modules/` 目录下的文件复制到 `data/adb/modules_update/` 下。
  请在 `./files/patches/modules/` 目录下创建与安装模块 id 相同的文件夹，并将需要补丁的文件放入该文件夹中。

### 配置文件：settings.sh

- 支持修改模块路径变量，语言，禁用 log，设置最低安卓 API、Magisk 版本、ksu 版本、apatch 版本，以及自定义脚本。

### 语言文件：languages.ini

- 支持修改语言文件。

### 高级功能：自定义安装模板

- 详情见注释。

## 兼容性

- 兼容 Magisk、KernelSU、APatch。

## Star History

<iframe style="width:100%;height:auto;min-width:600px;min-height:400px;border-radius:10px;box-shadow:0 4px 8px rgba(0,0,0,0.1);" src="https://star-history.com/embed?secret=Z2hwX1BVNlVHcHp2RmFmc3ZCODV2TDlZamNhSHpQQUVjbDNaSGNqVA==#Aurora-Nasa-1/ARMIAS&Date" frameBorder="0"></iframe>
**如果您喜欢这个项目，请给它一个 Star ！**

## 感谢

- [Android_zstd_builds]
- [Zstd]
- [7zzs]

[Android_zstd_builds]: https://github.com/j2rong4cn/android-zstd-builds
[Zstd]: https://github.com/facebook/zstd
[7zzs]: https://github.com/AestasBritannia/Hydro-Br-leur