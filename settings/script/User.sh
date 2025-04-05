#!/system/bin/sh
# shellcheck disable=SC2034
# shellcheck disable=SC2154
# shellcheck disable=SC3043
# shellcheck disable=SC2155
# shellcheck disable=SC2046
# shellcheck disable=SC3045
# shellcheck disable=SC2164
MODPATH="$1"
NOW_PATH="$2"
abort() {
    echo "$1"
    exit 1
}
print_KEY_title() {
    echo ""
    echo -e "\033[36m******************************************\033[0m"
    echo "         ${KEY_VOLUME}+$1"
    echo "         ${KEY_VOLUME}-$2"
    echo -e "\033[36m******************************************\033[0m"
    echo ""
    key_select
}
zip_if() {
    echo "- ${USER_SUCCESSFULLY_COMPRESS}: $1"
}

main() {
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
        zips="$NOW_PATH/prebuilts/zip"
        chmod 755 "$zips"
        chmod 755 "$zstd"
    fi
}
main
echo -e "\033[32m$USER_START\033[0m"
echo ""
ZIP_DIR="$NOW_PATH/files/modules/"
if ls "$ZIP_DIR"*.zip 1>/dev/null 2>&1; then
    echo "- $USER_FOUND_ZIP"
    print_KEY_title "$USER_KEY_UNZIP_MODULES" "$USER_NOT_UNZIP_MODULES"
    if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
        for zip_file in "$ZIP_DIR"*.zip; do
            zip_name=$(basename "$zip_file" .zip)
            unzip "$zip_file" -d "$NOW_PATH/files/modules/$zip_name/" >/dev/null 2>&1
            rm "$zip_file"
        done
        echo "- $UNZIP_FINNSH"
    fi
fi
print_KEY_title "$USER_KEY_BACKUPMODULE" "$USER_NOT_BACKUPMODULE"
if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
    print_KEY_title "$USER_KEY_BACKUPMODULE(Zip)" "${USER_KEY_BACKUPMODULE} ($USER_CHOOSE_ZSTD)"
    if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
        echo "- $USER_START_ZIP"
        for DIR in "/data/adb/modules/"*/; do
            DIR_NAME=$(basename "$DIR")
            OUTPUT_FILE="$NOW_PATH/files/modules/${DIR_NAME}.zip"
            $zips "$OUTPUT_FILE" "$DIR"* >/dev/null 2>&1
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
    tar -cJf "$NOW_PATH/output.tar.xz" -C "$NOW_PATH/files" . >/dev/null 2>&1
    zip_if "output.tar.xz"
    cp "$NOW_PATH/output.tar.xz" "$MODPATH/output.tar.xz"
    rm -rf "$MODPATH/files/*"
    $zips "$MODPATH"/ARMIAS.zip "$MODPATH/"* >"/dev/null" 2>&1
    zip_if "ARMIAS.zip"
    rm "$NOW_PATH/output.tar.xz"
else
    echo "- $USER_START_COMPRESS"
    rm -rf "$MODPATH"/files/
    cp -r "$NOW_PATH/files" "$MODPATH/" >"/dev/null" 2>&1
    $zips "$MODPATH"/ARMIAS.zip "$MODPATH/"* >"/dev/null" 2>&1
    zip_if "ARMIAS.zip"
fi
cp -r "$NOW_PATH/files/" "$MODPATH/" >"/dev/null" 2>&1
echo "- $USER_END_COPY_FILE $MODPATH/files/"
print_KEY_title "$USER_CLEAN_REMAINING_EXIT" "$EXIT"
if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
    find "$MODPATH" -mindepth 1 ! -name "ARMIAS.zip" -exec rm -rf {} +
fi
rm -rf "$NOW_PATH"/files/
rm -rf "$NOW_PATH"/settings/
rm -rf "$NOW_PATH"/prebuilts.tar.xz
rm -rf "$NOW_PATH"/prebuilts/
echo -e "\033[32;49;1m [DONE] \033[39;49;0m"
exit 0
