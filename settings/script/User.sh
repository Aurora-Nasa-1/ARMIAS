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
    echo "         ${KEY_VOLUME}-$2"
    echo "******************************************"
    echo ""
    key_select
}
zip_if() {
    if [ -f "$1" ]; then
        return_code="$1"
        if [ "$return_code" -eq 0 ]; then
            echo "${USER_SUCCESSFULLY_COMPRESS}: $2"
        else
            abort "${USER_FAILED_COMPRESS}: $2"
        fi
    fi
}

main() {
    MODPATH=$(cat /data/local/tmp/clickinformation.txt)
    rm -rf "/data/local/tmp/clickinformation.txt"
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
        zstd="/data/local/tmp/prebuilts/zstd"
        zips="/data/local/tmp/prebuilts/7zzs"
        chmod 755 "$zips"
        chmod 755 "$zstd"
    fi
}
main
print_KEY_title "$USER_KEY_BACKUPMODULE" "$USER_NOT_BACKUPMODULE"
if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
    print_KEY_title "$USER_KEY_BACKUPMODULE(Zip)" "$USER_KEY_BACKUPMODULE($USER_CHOOSE_ZSTD)"
    if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
        echo "$USER_START_ZIP"
        for DIR in "/data/adb/modules/"*/; do
            DIR_NAME=$(basename "$DIR")
            OUTPUT_FILE="$MODPATH/files/modules/${DIR_NAME}.zip"
            $zips a -r "$OUTPUT_FILE" "$DIR*" >/dev/null 2>&1
        done
        echo "- $USER_ZIPPED $MODPATH/files/modules"
    else
        echo "- $USER_START_COPY_FILE"
        cp -r "/data/adb/modules"/* "$MODPATH/files/modules" >/dev/null 2>&1
        echo "- $USER_END_COPY_FILE $MODPATH/files/modules"
    fi
fi
print_KEY_title "$USER_PACK_MODULE_ZSTD" "$USER_PACK_MODULE"
if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
    echo "- $USER_START_COMPRESS"
    tar -cf "$MODPATH/output.tar" -C "$MODPATH" files/
    zip_if "$?" "output.tar"
    $zstd -ultra -22 "$MODPATH/output.tar.zst" "$MODPATH/output.tar" >/dev/null 2>&1
    zip_if "$?" "output.tar.zst"
    rm "$MODPATH"/output.tar
    $zips a "$MODPATH"/ARMIAS.zip "$MODPATH/"* -xr!"$MODPATH/files/*" >"/dev/null" 2>&1
    zip_if "$?" "ARMIAS.zip"
else
    $zips a "$MODPATH"/ARMIAS.zip "$MODPATH/"* >"/dev/null" 2>&1
    zip_if "$?" "ARMIAS.zip"
fi
print_KEY_title "清理剩余文件并退出(! 谨慎)" "退出"
if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
    find "$MODPATH" -mindepth 1 ! -name "ARMIAS.zip" -exec rm -rf {} +
fi
rm -rf /data/local/tmp/settings/
rm -rf /data/local/tmp/prebuilts.tar.xz
rm -rf /data/local/tmp/prebuilts/
exit 0
