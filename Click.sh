#!/system/bin/sh
current_dir=$(pwd)
temp_dirs=("/tmp" "/temp" "/Temp" "/TEMP" "/TMP" "/Android/data")
for dir in "${temp_dirs[@]}"; do
    if [[ $current_dir == *"$dir"* ]]; then
        echo "現在のディレクトリは一時ディレクトリまたはそのサブディレクトリです。別のディレクトリに解凍してからスクリプトを実行してください。"
        echo "当前目录是临时目录或其子目录。请解压到其他目录再执行脚本"
        echo "The current directory is a temporary directory or its subdirectory. Please extract to another directory before executing the script."
        exit 0
    fi
done
if [ "$(whoami)" != "root" ]; then
    echo "此脚本必须以root权限运行。请使用root用户身份运行此脚本。"
    echo "This script must be run with root privileges. Please run this script as a root user."
    echo "このスクリプトはroot権限で実行する必要があります。このスクリプトをrootユーザーとして実行してください。"
    exit 1
fi
detect_environment() {
    ENVIRONMENT="UNKNOWN"
    BUSYBOX_PATH=""

    if [ -d "/data/adb/magisk" ]; then
        ENVIRONMENT="MAGISK"
        BUSYBOX_PATH="/data/adb/magisk/busybox"
    fi

    if [ -d "/data/adb/ksu" ]; then
        ENVIRONMENT="KERNELSU"
        BUSYBOX_PATH="/data/adb/ksu/bin/busybox"
    fi

    if [ -d "/data/adb/ap" ]; then
        ENVIRONMENT="APATCH"
        BUSYBOX_PATH="/data/adb/ap/bin/busybox"
    fi
    if [ "$ENVIRONMENT" = "UNKNOWN" ]; then
        echo "UNKNOWN ENVIRONMENT"
        exit 1
    fi
    echo "Environment: $ENVIRONMENT"
    echo "BusyBox path: $BUSYBOX_PATH"
}
detect_environment
MODPATH=${0%/*}
VERSION=$(grep "version" "$MODPATH/module.prop" | awk -F'=' '{print $2}')
echo "Module Version: $VERSION"
NOW_PATH="/data/local/tmp"
cp -r "$MODPATH"/files/ "$NOW_PATH"/
cp -r "$MODPATH"/settings/ "$NOW_PATH"/
cp "$MODPATH"/prebuilts.tar.xz "$NOW_PATH"/
chmod -R 755 "$NOW_PATH"/settings/
ASH_STANDALONE=1 $BUSYBOX_PATH sh "$NOW_PATH"/settings/script/User.sh "$MODPATH" "$NOW_PATH"
