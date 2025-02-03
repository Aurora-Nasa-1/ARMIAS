#!/system/bin/sh
# shellcheck disable=SC2034
# shellcheck disable=SC2154
# shellcheck disable=SC3043
# shellcheck disable=SC2155
# shellcheck disable=SC2046
# shellcheck disable=SC3045
# shellcheck disable=SC2164
NOW_PATH="/data/local/tmp"
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
    if [ -z "$1" ]; then
        return_code=$1
        if [ "$return_code" -eq 0 ]; then
            echo "- ${USER_SUCCESSFULLY_COMPRESS}: $2"
        else
            abort "- ${USER_FAILED_COMPRESS}: $2"
        fi
    fi
}

main() {
    MODPATH=$(cat /data/local/tmp/clickinformation.txt)
    rm -rf "/data/local/tmp/clickinformation.txt"
    if [ ! -f "$NOW_PATH/settings/settings.sh" ]; then
        abort "Notfound File!!!(settings.sh)"
    else
        # shellcheck source=/dev/null
        . "$NOW_PATH/settings/settings.sh"
    fi
    if [ ! -f "$NOW_PATH/$langpath" ]; then
        abort "Notfound File!!!($langpath)"
    else
        # shellcheck disable=SC1090
        . "$NOW_PATH/$langpath"
        eval "lang_$print_languages"
    fi
    if [ ! -f "$NOW_PATH/$script_path" ]; then
        abort "Notfound File!!!($script_path)"
    else
        # shellcheck disable=SC1090
        . "$NOW_PATH/$script_path"
    fi
    if [ -f "$NOW_PATH/prebuilts.tar.xz" ]; then
        tar -xJf "$NOW_PATH/prebuilts.tar.xz" -C "$NOW_PATH/"
        zstd="$NOW_PATH/prebuilts/zstd"
        zips="$NOW_PATH/prebuilts/7zzs"
        chmod 755 "$zips"
        chmod 755 "$zstd"
    fi
}
main
print_KEY_title "$USER_KEY_BACKUPMODULE" "$USER_NOT_BACKUPMODULE"
if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
    print_KEY_title "$USER_KEY_BACKUPMODULE(Zip)" "${USER_KEY_BACKUPMODULE}Zstd ($USER_CHOOSE_ZSTD)"
    if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
        echo "- $USER_START_ZIP"
        for DIR in "/data/adb/modules/"*/; do
            DIR_NAME=$(basename "$DIR")
            OUTPUT_FILE="$NOW_PATH/files/modules/${DIR_NAME}.zip"
            $zips a -r "$OUTPUT_FILE" "$DIR*" >/dev/null 2>&1
        done
        echo "- $USER_ZIPPED $NOW_PATH/files/modules"
    else
        echo "- $USER_START_COPY_FILE"
        cp -r "/data/adb/modules"/* "$NOW_PATH/files/modules" >/dev/null 2>&1
        echo "- $USER_END_COPY_FILE $NOW_PATH/files/modules"
    fi
fi
print_KEY_title "$USER_PACK_MODULE_ZSTD" "$USER_PACK_MODULE"
if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
    echo "- $USER_START_COMPRESS"
    tar -cf "$NOW_PATH/output.tar" -C "$NOW_PATH" files/
    zip_if "$?" "output.tar"
    $zstd -19 "$NOW_PATH/output.tar.zst" "$NOW_PATH/output.tar" >/dev/null 2>&1
    zip_if "$?" "output.tar.zst"
    rm "$NOW_PATH"/output.tar
    $zips a -r "$MODPATH"/ARMIAS.zip "$NOW_PATH/"* -xr!"$NOW_PATH/files/" >"/dev/null" 2>&1
    zip_if "$?" "ARMIAS.zip"
else
    echo "- $USER_START_COMPRESS"
    $zips a -r "$MODPATH"/ARMIAS.zip "$NOW_PATH/"* >"/dev/null" 2>&1
    zip_if "$?" "ARMIAS.zip"
fi
print_KEY_title "$USER_CLEAN_REMAINING_EXIT" "$EXIT"
if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
    find "$MODPATH" -mindepth 1 ! -name "ARMIAS.zip" -exec rm -rf {} +
fi
rm -rf $NOW_PATH/files/
rm -rf $NOW_PATH/settings/
rm -rf $NOW_PATH/prebuilts.tar.xz
rm -rf $NOW_PATH/prebuilts/
echo "- Done"
exit 0
