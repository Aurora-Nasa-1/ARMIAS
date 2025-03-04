#!/system/bin/sh
# shellcheck disable=SC2034
# shellcheck disable=SC2154
# shellcheck disable=SC3043
# shellcheck disable=SC2155
# shellcheck disable=SC2046
# shellcheck disable=SC3045
zstd="$MODPATH"/prebuilts/zstd
zips="$MODPATH"/prebuilts/zip
key_select() {
    key_pressed=""
    while true; do
        local output=$(/system/bin/getevent -qlc 1)
        local key_event=$(echo "$output" | awk '{ print $3 }' | grep 'KEY_')
        local key_status=$(echo "$output" | awk '{ print $4 }')
        if echo "$key_event" | grep -q 'KEY_' && [ "$key_status" = "DOWN" ]; then
            key_pressed="$key_event"
            break
        fi
    done
    while true; do
        local output=$(/system/bin/getevent -qlc 1)
        local key_event=$(echo "$output" | awk '{ print $3 }' | grep 'KEY_')
        local key_status=$(echo "$output" | awk '{ print $4 }')
        if [ "$key_event" = "$key_pressed" ] && [ "$key_status" = "UP" ]; then
            break
        fi
    done
}
Aurora_ui_print() {
    sleep 0.02
    echo "[${OUTPUT}] $1"
}

Aurora_abort() {
    echo "[${ERROR_TEXT}] $1"
    abort "$ERROR_CODE_TEXT: $2"
}
Aurora_test_input() {
    if [ -z "$3" ]; then
        Aurora_ui_print "$1 ( $2 ) $WARN_MISSING_PARAMETERS"
    fi
}
print_title() {
    if [ -n "$2" ]; then
        Aurora_ui_print "$1 $2"
    fi
}
ui_print() {
    if [ "$1" = "- Setting permissions" ]; then
        return
    fi
    if [ "$1" = "- Extracting module files" ]; then
        return
    fi
    if [ "$1" = "- Current boot slot: $SLOT" ]; then
        return
    fi
    if [ "$1" = "- Device is system-as-root" ]; then
        return
    fi
    if [ "$(echo "$1" | grep -c '^ - Mounting ')" -gt 0 ]; then
        return
    fi
    if [ "$1" = "- Done" ]; then
        return
    fi
    echo "$1"
}
#About_the_custom_script
###############
App_data_patch_set_permissions() {
    Aurora_test_input "App_data_patch_set_permissions" "1" "$1"
    Aurora_test_input "App_data_patch_set_permissions" "2" "$2"
    patch_default "$MODPATH" "$2" "$SDCARD/Android/data/$1/"
    uid=$(pm dump "$1" | grep 'userId=' | awk -F'=' '{print $2}')
    chown -R "$uid":1078 "$SDCARD/Android/data/$1/"
}
mv_adb() {
    Aurora_test_input "mv_adb" "1" "$1"
    su -c mv "$MODPATH/$1"/* "/data/adb/"
}
un_zstd_tar() {
    Aurora_test_input "un_zstd_tar" "1" "$1"
    Aurora_test_input "un_zstd_tar" "2" "$2"
    $zstd -d "$1" -o "$2/temp.tar"
    tar -xf "$2/temp.tar" -C "$2"
    rm "$2/temp.tar"
    if [ $? -eq 0 ]; then
        Aurora_ui_print "$UNZIP_FINNSH"
    else
        Aurora_ui_print "$UNZIP_ERROR"
    fi
}
aurora_flash_boot() {
    Aurora_test_input "aurora_flash_boot" "1" "$1"
    get_flags
    find_boot_image
    flash_image "$1" "$BOOTIMAGE"
}
magisk_denylist_add() {
    Aurora_test_input "magisk_denylist_add" "1" "$1"
    if [ -z "$KSU" ] && [ -z "$APATCH" ] && [ -n "$MAGISK_VER_CODE" ]; then
        magisk --denylist add "$1" >/dev/null 2>&1
    fi
}
set_permissions_755() {
    Aurora_test_input "set_permissions_755" "1" "$1"
    set_perm "$1" 0 0 0755
}
check_network() {
    ping -c 1 www.baidu.com >/dev/null 2>&1
    local baidu_status=$?
    ping -c 1 github.com >/dev/null 2>&1
    local github_status=$?
    ping -c 1 google.com >/dev/null 2>&1
    local google_status=$?
    if [ $google_status -eq 0 ]; then
        Aurora_ui_print "$INTERNET_CONNET (Google)"
        Internet_CONN=3
    elif [ $github_status -eq 0 ]; then
        Aurora_ui_print "$INTERNET_CONNET (GitHub)"
        Internet_CONN=2
    elif [ $baidu_status -eq 0 ]; then
        Aurora_ui_print "$INTERNET_CONNET (Baidu.com)"
        Internet_CONN=1
    else
        Internet_CONN=
    fi
}
github_get_url() {
    Aurora_test_input "github_get_url" "1" "$1"
    Aurora_test_input "github_get_url" "2" "$2"
    local owner_repo="$1"
    local SEARCH_CHAR="$2"
    local API_URL="https://api.github.com/repos/${owner_repo}/releases/latest"
    local wget_response_file="$tempdir/github_get_url_response"

    wget -S --output-document="$wget_response_file" "$API_URL"

    local TEMP_FILE="$tempdir/github_get_url"

    cat "$wget_response_file" | tr -d '\n' | \
    sed 's/.*"assets":\[//' | sed 's/\].*//' | \
    tr '}' '\n' | \
    grep "$SEARCH_CHAR" | \
    awk -F'"browser_download_url":"' '{print $2}' | \
    sed 's/".*//' > "$TEMP_FILE"

    # 检查是否成功提取
    if [ ! -s "$TEMP_FILE" ]; then
        rm -f "$wget_response_file" "$TEMP_FILE"
        Aurora_ui_print "$NOTFOUND_URL"
        return 1
    fi

    DESIRED_DOWNLOAD_URL=$(cat "$TEMP_FILE")
    if [ -z "$DESIRED_DOWNLOAD_URL" ]; then
        rm -f "$wget_response_file" "$TEMP_FILE"
        Aurora_ui_print "$NOTFOUND_URL"
        return 1
    fi

    Aurora_ui_print "$DESIRED_DOWNLOAD_URL"
    rm -f "$wget_response_file" "$TEMP_FILE"
    return 0
}
download_file() {
    Aurora_test_input "download_file" "1" "$1"
    local link="$1"
    local filename=$(wget --spider -S "$link" 2>&1 | grep -o -E 'filename="[^"]*"' | sed -e 's/^filename="//' -e 's/"$//')
    local local_path="$download_destination/$filename"
    local retry_count=0
    local wget_file="$tempdir/wget_file"
    mkdir -p "$download_destination"

    wget -S --spider "$link" 2>&1 | grep 'Content-Length:' | awk '{print $2}' >"$wget_file"
    file_size_bytes=$(cat "$wget_file")
    if [ -z "$file_size_bytes" ]; then
        Aurora_ui_print "$FAILED_TO_GET_FILE_SIZE $link"
    fi
    local file_size_mb=$(echo "scale=2; $file_size_bytes / 1048576" | bc)
    Aurora_ui_print "$DOWNLOADING $filename $file_size_mb MB"
    while [ $retry_count -lt "$max_retries" ]; do
        wget --output-document="$local_path.tmp" "$link"
        if [ -s "$local_path.tmp" ]; then
            mv "$local_path.tmp" "$local_path"
            Aurora_ui_print "$DOWNLOAD_SUCCEEDED $local_path"
            return 0
        else
            retry_count=$((retry_count + 1))
            rm -f "$local_path.tmp"
            Aurora_ui_print "$RETRY_DOWNLOAD $retry_count/$max_retries... $DOWNLOAD_FAILED $filename"
        fi
    done

    Aurora_ui_print "$DOWNLOAD_FAILED $link"
    Aurora_ui_print "${KEY_VOLUME}+${PRESS_VOLUME_RETRY}"
    Aurora_ui_print "${KEY_VOLUME}-${PRESS_VOLUME_SKIP}"
    key_select
    if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
        download_file "$link"
    fi
    return 1
}
