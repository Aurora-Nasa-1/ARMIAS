[简体中文](README.md) | **日本語** | [English](README_EN.md)

このモジュールは [Aurora-Magisk-Modules-Framework](https://github.com/Aurora-Nasa-1/AMMF) を基に開発されています。

# 高自定义度の自動インストールモジュール

<div style="display: flex; justify-content: space-between;">
    <img src="https://img.shields.io/github/downloads/Aurora-Nasa-1/ARMIAS/total" alt="GitHub Downloads (all assets, all releases)" style="margin-right: 10px;">
    <img src="https://img.shields.io/github/license/Aurora-Nasa-1/ARMIAS" alt="GitHub License">
</div>

## 概要

このモジュールは、高度にカスタマイズ可能な自動インストールおよび構成ソリューションを提供することを目的としており、複数の言語とさまざまな機能をサポートしています。これには、APKの一括インストール、インターネットからのファイルのダウンロード、インストール後のモジュールのパッチ適用などが含まれます。
[Telegram](https://t.me/+w7TQLtEex00wMDk1)

## 基本操作

### 1. モジュールの一括インストール

- インストールしたいすべてのモジュール（zipファイル）を `./files/modules` フォルダーに配置します。

### 2. モジュールのバックアップ / このモジュールの自動パッケージ化

- このモジュールのzipフォルダーを解凍します。
- `Click.sh` スクリプトを `SU` 権限で実行して、モジュールのバックアップとこのモジュールのパッケージ化を選択できます。さまざまな機能が組み込まれています。

## 高度な機能（オプションの読み物）

### DATAとSDCARDのワンクリック上書き

- 一部のモジュールはインストール後に `/data/` または `Android` フォルダーに設定ファイルを生成するため、このモジュールはモジュール内のターゲットファイルを `/data/` または `/sdcard/` に一括コピーするワンクリック機能を提供し、設定と使用を容易にします。
- `data` と `sdcard` の直接変更もサポートしています。
  **注意**：この操作はターゲットディレクトリ内のすべてのファイルを上書きします。正しいフォルダ構造を設定し、**正しく権限を設定**してください。
  モジュール内のディレクトリ例：`./files/patches/sdcard/`, `./files/patches/data/`, `./files/patches/apks/`
- `./files/patches/apks/` 内のAPKファイルは一括インストールされます。

### インターネットからのファイルのダウンロード

- GitHubリポジトリから最新の特定のリリースファイルを取得することをサポートしています。（ベータ版）
- ファイルの一括ダウンロードをサポートしています。
- モジュールの一括ダウンロードとインストールをサポートしています。

### インストール後のモジュールのパッチ適用

- `./files/patches/modules/` ディレクトリから `data/adb/modules_update/` にファイルをコピーします。
  `./files/patches/modules/` ディレクトリにインストールされたモジュールと同じモジュールIDのフォルダーを作成し、そのフォルダーにパッチファイルを配置してください。

### 設定ファイル：settings.sh

- モジュールパス変数、言語、ログの無効化、最小Android API、Magiskバージョン、ksuバージョン、apatchバージョン、およびカスタムスクリプトの設定をサポートしています。

### 言語ファイル：languages.ini

- 言語ファイルの変更をサポートしています。

### 高度な機能：カスタムインストールテンプレート

- 詳細はコメントを参照してください。

## 互換性

- Magisk、KernelSU、APatchと互換性があります。

**このプロジェクトがお好きでしたら、Starをお願いします！**

## ありがとうございます

- [Android_zstd_builds]
- [Zstd]
- [7zzs]

[Zstd]: https://github.com/facebook/zstd
[Zip-Rust]: https://github.com/yxy-os/zip-rust
