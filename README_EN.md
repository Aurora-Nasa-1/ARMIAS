
[简体中文](README.md) | [日本語](README_JP.md) | **English**

# Highly Customizable Automatic Installation Module

#### Basic Operations

- Simply place all modules (zip files) into the `./files/modules` folder.
**Note**: Please ensure that file names do **not contain special characters**.
- Unzip this module's zip folder and run `backup_all_modules_zip.sh` to back up all modules.

#### Advanced Features (Optional Reading)

- Run `backup_modules_zstd_all_files.sh` to back up modules (folders) and compress all module files using zstd. This script will also automatically compress this module.

- **One-Click DATA and SDCARD Overwrite**
  - Considering that some modules generate configuration files in the data/ or android folders after installation.
  - This module provides a one-click function to batch copy target files within the module to data/ or sdcard/, facilitating module configuration and usage.
  - At the same time, it also supports direct modification of `data` and `sdcard`.
  **Note**: This operation will copy all files under "target directory within the module/*". Please ensure that the correct folder structure is set up and **permissions are set correctly**.
  Example of directories within the module: `./files/patches/sdcard/`, `./files/patches/data/`, `./files/patches/apks/`

- **Automatic batch installation of APKs** `(su)`
  A simple and straightforward feature that allows you to install multiple APKs in batch.

- **Download Files from the Internet**
  - Supports fetching the latest specific release file from a GitHub repository
  - Supports batch downloading of files
  - Supports batch downloading and installation of modules

- **Post-installation module patching**
  Files in the `./files/patches/modules/` directory will be copied to `data/adb/modules_update/`.
  Please create a folder with the same ID as the installed module in the `./files/patches/modules/` directory and place the necessary patch files in it.

- **Configuration file: settings.sh**
  Supports modifying 80% of the module's path variables, language, disabling logs, setting the minimum Android API, Magisk version, ksu version, apatch version, and custom scripts.
  - **If you encounter installation issues, please try enabling **Compatibility Mode**.**

- **Language File**
  - Default path: `languages.ini`
  - Supports modifying the language file.

- **Advanced Feature: Custom Installation Templates**
  - See comments for details.

#### Compatibility

- Compatible with Magisk, KernelSU, and APatch.

- Supports installing Magisk modules in TWRP.

#### User Guide

- Place modules (zip files) into the `./files/modules` folder.

- Organize other files into corresponding subfolders within the `./files/patches` folder.

#### Important Note

- **Please do not include special characters in file names.**

#### Thanks

- [Android_zstd_builds]
- [Zstd]
- [7zzs]

[Android_zstd_builds]:https://github.com/j2rong4cn/android-zstd-builds
[Zstd]:https://github.com/facebook/zstd
[7zzs]:https://github.com/AestasBritannia/Hydro-Br-leur