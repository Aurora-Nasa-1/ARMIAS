#!/system/bin/sh
# shellcheck disable=SC2034
# shellcheck disable=SC2154
# shellcheck disable=SC3043
# shellcheck disable=SC2155
# shellcheck disable=SC2046
# shellcheck disable=SC3045
abort() {
    echo "$1"
    exit 1
}
print_KEY_title() {
    echo ""
    echo "******************************************"
    echo "         ${KEY_VOLUME}+$1"
    echo "         ${KEY_VOLUME}+$2"
    echo "******************************************"
    echo ""
    key_select
}
zip_if() {
    if [ -f "$1" ]; then
        return_code="$1"
        if [ "$return_code" -eq 0 ]; then
            echo "Successfully created archive: $2"
        else
            abort "Failed to create archive for directory: $2"
        fi
    fi
}
main() {
    MODPATH=$(cat /data/local/tmp/clickinformation.txt)
    rm -rf data/local/tmp/clickinformation.txt
    if [ ! -f "/data/local/tmp/settings/settings.sh" ]; then
        abort "Notfound File!!!(settings.sh)"
    else
        # shellcheck source=/dev/null
        . "/data/local/tmp/settings/settings.sh"
    fi
    if [ ! -f "/data/local/tmp/$langpath" ]; then
        abort "Notfound File!!!($langpath)"
    else
        # shellcheck disable=SC1090
        . "/data/local/tmp/$langpath"
        eval "lang_$print_languages"
    fi
    if [ ! -f "/data/local/tmp/$script_path" ]; then
        abort "Notfound File!!!($script_path)"
    else
        # shellcheck disable=SC1090
        . "/data/local/tmp/$script_path"
    fi
    if [ -f "/data/local/tmp/prebuilts.tar.xz" ]; then
        tar -xJf "/data/local/tmp/prebuilts.tar.xz" -C "/data/local/tmp/"
        zstd="/data/local/tmp/zstd"
        zips="/data/local/tmp/7zzs"
        chmod 755 "$zips"
        chmod 755 "$zstd"
    fi
}
main
print_KEY_title "备份现有模块" "不备份"
if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
    print_KEY_title "备份现有模块(Zip)" "备份现有模块(文件夹) (配合Zstd使用)"
    if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
        for DIR in "/data/adb/modules/"*/; do
            DIR_NAME=$(basename "$DIR")
            echo "Processing directory: $DIR_NAME"
            OUTPUT_FILE="$MODPATH/files/modules/${DIR_NAME}.zip"
            $zips a -r "$OUTPUT_FILE" "$DIR*"
            zip_if "$?" "${DIR_NAME}.zip"
        done
    else
        cp -r "/data/adb/modules"/* "$OUTPUT_DIR"
        echo "All files have been copied to $OUTPUT_DIR"
    fi
else
    echo 1
fi
print_KEY_title "打包模块(Zstd)(慢)" "打包模块"
if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
    tar -cf "$MODPATH/output.tar" -C "$MODPATH" files/
    zip_if "$?" "output.tar"
    $zstd -ultra -22 "$MODPATH/output.tar.zst" "$MODPATH/output.tar"
    zip_if "$?" "output.tar.zst"
    rm "$MODPATH"/output.tar
    $zips a "$MODPATH"/ARMIAS.zip "$MODPATH/"* -xr!"$MODPATH/files/*"
    zip_if "$?" "ARMIAS.zip"
else
    $zips a "$MODPATH"/ARMIAS.zip "$MODPATH/"*
    zip_if "$?" "ARMIAS.zip"
fi
