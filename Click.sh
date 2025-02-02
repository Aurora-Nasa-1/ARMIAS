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
ASH_STANDALONE=1
MODPATH=${0%/*}
FILE=/data/local/tmp/clickinformation.txt
echo $MODPATH >$FILE
cp -r $MODPATH/settings/ /data/local/tmp/
chmod -R 755 /data/local/tmp/settings/
$BUSYBOX_PATH sh /data/local/tmp/settings/script/User.sh
