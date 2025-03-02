[简体中文](README.md) | [日本語](README_JP.md) | **English**

# Highly Customizable Automatic Installation Module

## Introduction

This module is developed based on the [Aurora-Magisk-Modules-Framework](https://github.com/Aurora-Nasa-1/AMMF).
This module aims to provide a highly customizable automated installation and configuration solution, supporting multiple languages and various features, including batch installation of APKs, downloading files from the internet, post-installation module patching, and more.
[Telegram](https://t.me/+w7TQLtEex00wMDk1)

## Basic Operations

### 1. Batch Module Installation

- Place all the modules (zip files) you want to install into the `./files/modules` folder.

### 2. Backup Modules / Automatically Package This Module

- Unzip this module's zip folder.
- Run the `Click.sh` script with `SU` permissions to choose to backup modules and package this module. It includes various built-in features.

## Advanced Features (Optional Reading)

### One-Click Overwrite for DATA and SDCARD

- Since some modules generate configuration files in the `/data/` or `Android` folders after installation, this module provides a one-click feature to batch copy target files within the module to `/data/` or `/sdcard/` for easier configuration and usage.
- It also supports directly modifying `data` and `sdcard`.
  **Note**: This operation will overwrite all files in the target directory. Please ensure the correct folder structure and **set permissions correctly**.
  Example directories within the module: `./files/patches/sdcard/`, `./files/patches/data/`, `./files/patches/apks/`
- APK files in `./files/patches/apks/` will be installed in batch.

### Download Files from the Internet

- Supports fetching the latest specific release files from a GitHub repository. (Beta)
- Supports batch downloading of files.
- Supports batch downloading and installing of modules.

### Post-Installation Module Patching

- Copy files from the `./files/patches/modules/` directory to `data/adb/modules_update/`.
  Please create a folder with the same module ID as the installed module in the `./files/patches/modules/` directory and place the patch files in that folder.

### Configuration File: settings.sh

- Supports modifying module path variables, language, disabling logs, setting minimum Android API, Magisk version, ksu version, apatch version, and custom scripts.

### Language File: languages.ini

- Supports modifying the language file.

### Advanced Feature: Custom Installation Template

- See comments for details.

## Compatibility

- Compatible with Magisk, KernelSU, APatch.

**If you like this project, please give it a Star!**

## Thanks

- [Android_zstd_builds]
- [Zstd]
- [7zzs]

[Android_zstd_builds]: https://github.com/j2rong4cn/android-zstd-builds
[Zstd]: https://github.com/facebook/zstd
[7zzs]: https://github.com/AestasBritannia/Hydro-Br-leur