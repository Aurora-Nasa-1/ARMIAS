**简体中文** | [日本語](README_JP.md) | [English](README_EN.md)

# 高自定义度的自动安装模块

## 简介

本模块旨在提供一个高自定义度的自动安装和配置解决方案，支持多种语言和多种功能，包括批量安装 APK、从网络下载文件、安装后模块修补等。

## 基础操作

### 1. 准备工作

- 将所有模块（zip 文件）放入 `./files/modules` 文件夹中。
  **注意**：请确保文件名 **不含特殊字符**。
- 将此模块 zip 文件夹解压。

### 2. 备份所有模块

- 运行 `backup_all_modules_zip.sh` 来备份所有模块。

### 3. 打包模块

- 运行 `Make_module.sh` 打包本模块。（并使用 zstd 压缩所有文件）

## 进阶功能（可选阅读）

### 备份与压缩（高压缩率）

- 运行 `backup_modules_zstd_all_files.sh` 批量备份模块（文件夹）并使用 zstd 压缩所有文件。此脚本将自动压缩本模块。

### DATA 和 SDCARD 一键覆盖

- 鉴于某些模块安装后会生成配置文件等在 data/ 或 android 文件夹中，本模块提供一键将模块内目标文件批量复制至 data/ 或 sdcard/ 的功能，便于模块的配置与使用。
- 同时，也支持直接修改 `data` 和 `sdcard`。
  **注意**：此操作会复制 “模块内目标目录/*” 下的所有文件，请确保设置了正确的文件夹结构，并 **正确设置权限**。
  模块内目录示例：`./files/patches/sdcard/`, `./files/patches/data/`, `./files/patches/apks/`

### 自动批量安装 APK `(su)`

- 一个简洁明了的功能，方便您批量安装 APK。

### 从网络下载文件

- 支持获取某个 GitHub 仓库的最新的特定 release 文件。
- 支持批量下载文件。
- 支持批量下载模块并安装。

### 安装后模块修补

- 将 `./files/patches/modules/` 目录下的文件复制到 `data/adb/modules_update/` 下。
  请在 `./files/patches/modules/` 目录下创建与安装模块 id 相同的文件夹，并将需要补丁的文件放入该文件夹中。

### 配置文件：settings.sh

- 支持修改模块 80% 的路径变量，语言，禁用 log，设置最低安卓 API、Magisk 版本、ksu 版本、apatch 版本，以及自定义脚本。
  **如遇安装问题，请尝试启用** 兼容模式 **。**

### 语言文件

- 默认路径 `languages.ini`
- 支持修改语言文件。

### 高级功能：自定义安装模板

- 详情见注释。

## 兼容性

- 兼容 Magisk、KernelSU、APatch。
- 支持在 TWRP 中安装 Magisk 模块。

## 使用指南

### 1. 准备工作

- 将模块（zip 文件）放入 `./files/modules` 文件夹。
- 将其他文件分类放入 `./files/patches` 文件夹的对应子文件夹中。

### 2. 备份所有模块

- 运行 `backup_all_modules_zip.sh` 来备份所有模块。

### 3. 打包模块

- 运行 `Make_module.sh` 打包本模块。

## 重要提示

- **文件名请勿包含特殊字符**。

## 感谢

- [Android_zstd_builds]
- [Zstd]
- [7zzs]

[Android_zstd_builds]: https://github.com/j2rong4cn/android-zstd-builds
[Zstd]: https://github.com/facebook/zstd
[7zzs]: https://github.com/AestasBritannia/Hydro-Br-leur