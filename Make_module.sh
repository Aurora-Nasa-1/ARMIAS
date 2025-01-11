current_dir=$(pwd)
zstd="/data/local/tmp/zstd"
zips="/data/local/tmp/7zzs"

temp_dirs=("/tmp" "/temp" "/Temp" "/TEMP" "/TMP" "/Android/data")
for dir in "${temp_dirs[@]}"; do
    if [[ $current_dir == *"$dir"* ]]; then
        echo "当前目录是临时目录或其子目录。请解压到其他目录再执行脚本"
        echo "当前目录是临时目录或其子目录。请解压到其他目录再执行脚本"
        echo "The current directory is a temporary directory or its subdirectory. Please extract to another directory before executing the script."
        exit 0
    fi
done
if [ "$(whoami)" != "root" ]; then
    echo "此脚本必须以root权限运行。请使用root用户身份运行此脚本。"
    echo "This script must be run with root privileges. Please run this script as a root user."
    exit 1
fi
echo "脚本正在以root权限运行。"
cp "$current_dir/prebuilts/zstd" "/data/local/tmp/"
cp -r "$current_dir"/prebuilts/7zzs "/data/local/tmp/"

chmod 777 "$zstd"
chmod 777 "$zips"
tar -cf "$current_dir/output.tar" -C "$current_dir" files/
$zstd -ultra -22 "$current_dir/output.tar.zst" "$current_dir/output.tar"
rm "$current_dir"/output.tar
if [ $? -eq 0 ]; then
    echo "Successfully created archive: $current_dir/output.tar.zst"
else
    echo "Failed to create archive for directory: output.tar.zst"
fi
    $zips a "$current_dir"/ARMIAS.zip "$current_dir/"* -xr!"$current_dir/files/*"
    return_code=$?
if [ "$return_code" -eq 0 ]; then
    echo "Successfully created archive: $current_dir/ARMIAS.zip"
else
    echo "Failed to create archive for directory: ARMIAS.zip"
    exit 0
fi
rm -rf "$current_dir"/prebuilts/
rm -rf "$current_dir"/META-INF/
rm -rf "$current_dir"/settings/
rm -f "$current_dir"/customize.sh
rm -f "$current_dir"/languages.ini
rm -f "$current_dir"/service.sh
rm -f "$current_dir"/backup_all_modules_zip.sh
rm -f "$current_dir"/module.prop
rm -f "$zstd"
rm -f "$zips"
rm -f "$current_dir"/output.tar.zst
rm -f "$current_dir"/Make_module.sh
echo "将保留files文件夹，其余文件已删除。如需删除，请手动执行。"
(
    sleep 1
    rm -f "$0"
) &
