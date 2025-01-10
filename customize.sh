#!/system/bin/sh
# shellcheck disable=SC2034
# shellcheck disable=SC2154
# shellcheck disable=SC3043
# shellcheck disable=SC2155
# shellcheck disable=SC2046
# shellcheck disable=SC3045
main() {
    INSTALLER_MODPATH="$MODPATH"
    if [ ! -f "$MODPATH/settings/settings.sh" ]; then
        abort "Notfound File!!!(settings.sh)"
    else
        # shellcheck source=/dev/null
        . "$MODPATH/settings/settings.sh"
    fi
    if [ ! -f "$MODPATH/$langpath" ]; then
        abort "Notfound File!!!($langpath)"
    else
        # shellcheck disable=SC1090
        . "$MODPATH/$langpath"
        eval "lang_$print_languages"
    fi
    version_check
    sclect_settings_install_on_main
    patches_install
    CustomShell
    ClearEnv
}
#######################################################
Aurora_ui_print() {
    sleep 0.02
    ui_print "[${OUTPUT}] $1"
}

Aurora_abort() {
    ui_print "[${ERROR_TEXT}] $1"
    abort "$ERROR_CODE_TEXT: $2"
}
Aurora_test_input() {
    if [ -z "$3" ]; then
        Aurora_ui_print "$1 ( $2 ) $WARN_MISSING_PARAMETERS"
    fi
}
#######################################################
version_check() {
    if [ -n "$KSU_VER_CODE" ] && [ "$KSU_VER_CODE" -lt "$ksu_min_version" ] || [ "$KSU_KERNEL_VER_CODE" -lt "$ksu_min_kernel_version" ]; then
        Aurora_abort "KernelSU: $ERROR_UNSUPPORTED_VERSION $KSU_VER_CODE ($ERROR_VERSION_NUMBER >= $ksu_min_version or kernelVersionCode >= $ksu_min_kernel_version)" 1
    elif [ -z "$APATCH" ] && [ -z "$KSU" ] && [ -n "$MAGISK_VER_CODE" ] && [ "$MAGISK_VER_CODE" -le "$magisk_min_version" ]; then
        Aurora_abort "Magisk: $ERROR_UNSUPPORTED_VERSION $MAGISK_VER_CODE ($ERROR_VERSION_NUMBER > $magisk_min_version)" 1
    elif [ -n "$APATCH_VER_CODE" ] && [ "$APATCH_VER_CODE" -lt "$apatch_min_version" ]; then
        Aurora_abort "APatch: $ERROR_UNSUPPORTED_VERSION $APATCH_VER_CODE ($ERROR_VERSION_NUMBER >= $apatch_min_version)" 1
    elif [ "$API" -lt "$ANDROID_API" ]; then
        Aurora_abort "Android API: $ERROR_UNSUPPORTED_VERSION $API ($ERROR_VERSION_NUMBER >= $ANDROID_API)" 2
    fi
}

Installer_Compatibility_mode() {
    MODPATHBACKUP=$MODPATH
    for ZIPFILE in $1; do
        if [ "$Installer_Log" = "false" ]; then
            install_module >/dev/null 2>&1
        elif [ "$Installer_Log" = "true" ]; then
            install_module
        fi
    done
    MODPATH=$MODPATHBACKUP
}

Installer() {
    Aurora_test_input "Installer" "1" "$1"
    if [ "$Installer_Log" != "false" ] && [ "$Installer_Log" != "true" ]; then
        Aurora_abort "Installer_Log$ERROR_INVALID_LOCAL_VALUE" 4
    fi
    if [ "$2" != "" ]; then
        if [ "$2" = "KSU" ] && [ "$KSU" != true ] || [ "$2" = "APATCH" ] && [ "$APATCH" != true ] || [ "$2" = "MAGISK" ] && [ -z "$APATCH" ] && [ -z "$KSU" ] && [ -n "$MAGISK_VER_CODE" ]; then
            return
        fi
    fi
    if [ "$KSU" = true ]; then
        if [ "$KSU_VER_CODE" -le "$ksu_min_normal_version" ]; then
            Installer_Compatibility=true
            Aurora_ui_print "KernelSU: $WARN_FORCED_COMPATIBILITY_MODE"
        fi
    elif [ "$APATCH" = true ]; then
        if [ "$APATCH_VER_CODE" -le "$apatch_min_normal_version" ]; then
            Installer_Compatibility=true
            Aurora_ui_print "APatch: $WARN_FORCED_COMPATIBILITY_MODE"
        fi
    fi
    if [ "$Installer_Compatibility" = "false" ]; then
        if [ "$Installer_Log" = "false" ]; then
            Aurora_ui_print "$INSTALLER_LOG_DISABLED"
            if [ "$KSU" = true ]; then
                ksud module install "$1" >/dev/null 2>&1
            elif [ "$APATCH" = true ]; then
                apd module install "$1" >/dev/null 2>&1
            elif [ -z "$KSU" ] && [ -z "$APATCH" ] && [ -n "$MAGISK_VER_CODE" ]; then
                magisk --install-module "$1" >/dev/null 2>&1
            else
                Aurora_abort "$ERROR_UPGRADE_ROOT_SCHEME" 3
            fi
        elif [ "$Installer_Log" = "true" ]; then
            if [ "$KSU" = true ]; then
                ksud module install "$1"
            elif [ "$APATCH" = true ]; then
                apd module install "$1"
            elif [ -z "$KSU" ] && [ -z "$APATCH" ] && [ -n "$MAGISK_VER_CODE" ]; then
                magisk --install-module "$1"
            else
                Aurora_abort "$ERROR_UPGRADE_ROOT_SCHEME" 3
            fi
        fi
    elif [ "$Installer_Compatibility" = "true" ]; then
        Installer_Compatibility_mode "$1"
    else
        Aurora_abort "Installer_Compatibility$ERROR_INVALID_LOCAL_VALUE" 4
    fi
    if [ "$fix_ksu_install" = "true" ] && [ "$KSU" = true ] && [ -z "$KSU_step_skip" ]; then
        temp_dir="$MODPATH/TEMP/KSU"
        mkdir -p "$temp_dir"
        unzip -d "$temp_dir" "$1" >/dev/null 2>&1
        KSU_Installer_TEMP_ID=$(awk -F= '/^id=/ {print $2}' "$temp_dir/module.prop")
        $zip7z a -r "$MODPATH/TEMP/KSU/temp.zip" "$SECURE_DIR/modules_update/$KSU_Installer_TEMP_ID"/* >/dev/null 2>&1
        KSU_step_skip=true
        Installer "$MODPATH/TEMP/KSU/temp.zip" KSU
        rm -rf "$temp_dir"
        KSU_step_skip=""
    fi
}
initialize_install() {
    local dir="$1"
    mkdir -p "$MODPATH/TEMP/TEMP"
    local temp_all_files="$MODPATH/TEMP/listTMP.txt"

    if [ ! -d "$dir" ]; then
        Aurora_ui_print "$WARN_ZIPPATH_NOT_FOUND $dir"
        return
    fi

    find "$dir" -maxdepth 1 -type f -print0 | sort -z >"$temp_all_files"

    zygiskmodule="/data/adb/modules/zygisksu/module.prop"
    if [ ! -f "$zygiskmodule" ]; then
        mkdir -p "/data/adb/modules/zygisksu"
        {
            echo "id=zygisksu"
            echo "name=Zygisk Placeholder"
            echo "version=1.0"
            echo "versionCode=462"
            echo "author=null"
            echo "description=[Please DO NOT enable] This module is used by the installer to disguise the Zygisk version number"
        } >"$zygiskmodule"
        touch "/data/adb/modules/zygisksu/remove"
    fi

    while IFS= read -r -d '' file; do
        if [ "$Confirm_installation" = "false" ]; then
            Installer "$file"
        elif [ "$Confirm_installation" = "true" ]; then
            local file_name=$(basename "$file")
            key_installer_once "$file" "$file_name"
        else
            Aurora_abort "Confirm_installation$ERROR_INVALID_LOCAL_VALUE" 4
        fi
    done <"$temp_all_files"

    if [ -z "$(cat "$temp_all_files")" ]; then
        Aurora_ui_print "$WARN_NO_MORE_FILES_TO_INSTALL"
    fi

    rm -f "$temp_all_files"
}

patch_default() {
    if [ -d "$1/$2" ]; then
        if [ -d "$1/$2" ] && [ "$(ls -A "$1"/"$2")" ]; then
            cp -r "$1/$2"/* "$3"/
        else
            Aurora_ui_print "$WARN_PATCH_NOT_FOUND_IN $2"
        fi
    else
        Aurora_ui_print "$2 $WARN_PATCHPATH_NOT_FOUND_IN_DIRECTORY"
    fi
}

patches_install() {
    patch_default "$MODPATH" "$PATCHDATA" "/data"
    patch_default "$MODPATH" "$PATCHSDCARD" "$SDCARD"
    patch_default "$MODPATH" "$PATCHMOD" "$SECURE_DIR/modules_update/"
    if [ -d "$MODPATH/$PATCHAPK" ]; then
        apk_found=0
        for suffix in APK Apk apks APKS Apks; do
            for apk_file in "$MODPATH"/"$PATCHAPK"/*."$suffix"; do
                if [ -f "$apk_file" ]; then
                    if pm install "$apk_file"; then
                        apk_found=1
                    else
                        Aurora_ui_print "$WARN_APK_INSTALLATION_FAILED $apk_file"
                    fi
                fi
            done
        done
        if [ $apk_found -eq 0 ]; then
            Aurora_ui_print "$WARN_PATCH_NOT_FOUND_IN $PATCHAPK"
        fi
    else
        Aurora_ui_print "$PATCHAPK $WARN_PATCHPATH_NOT_FOUND_IN_DIRECTORY"
    fi
}
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
key_installer() {
    Aurora_test_input "key_installer" "1" "$1"
    Aurora_test_input "key_installer" "2" "$2"
    if [ "$3" != "" ] && [ "$4" != "" ]; then
        Aurora_ui_print "${KEY_VOLUME}+${KEY_VOLUME_INSTALL_MODULE} $3"
        Aurora_ui_print "${KEY_VOLUME}-${KEY_VOLUME_INSTALL_MODULE} $4"
    fi
    key_select
    if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
        Installer "$1"
    else
        Installer "$2"
    fi
}
key_installer_once() {
    Aurora_test_input "key_installer_once" "1" "$1"
    Aurora_test_input "key_installer_once" "2" "$2"
    Aurora_ui_print "${KEY_VOLUME}+${KEY_VOLUME_INSTALL_MODULE} $2"
    Aurora_ui_print "${KEY_VOLUME}-${PRESS_VOLUME_SKIP}"
    key_select
    if [ "$key_pressed" = "KEY_VOLUMEUP" ]; then
        Installer "$1"
    fi
}
#Abort Internet Connection
##########
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
    local wget_response_file=$(mktemp)

    wget -S --output-document="$wget_response_file" "$API_URL"

    local TEMP_FILE=$(mktemp)

    $jq -r '.assets[] | select(.name | test("'"$SEARCH_CHAR"'")) | .browser_download_url' "$wget_response_file" >"$TEMP_FILE"
    if [ $? -ne 0 ]; then
        rm -f "$wget_response_file" "$TEMP_FILE"
        Aurora_abort "jq $COMMAND_FAILED"
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
    mkdir -p "$MODPATH/TEMP"
    local wget_file="$MODPATH/TEMP/wget_file"
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
##############
sclect_settings_install_on_main() {
    jq="$MODPATH"/prebuilts/jq
    zstd="$MODPATH"/prebuilts/zstd
    zips="$MODPATH"/prebuilts/7zzs
    set_permissions_755 "$jq"
    set_permissions_755 "$zips"
    set_permissions_755 "$zstd"
    local network_counter=1
    if [ -f "$MODPATH"/output.tar.zst ]; then
        un_zstd_tar "$MODPATH/output.tar.zst" "$MODPATH/files/"
        rm "$MODPATH/output.tar.zst"
    fi
    if [ "$install" = "false" ]; then
        return
    elif [ "$install" = "true" ]; then
        initialize_install "$MODPATH/$ZIPLIST"
    else
        Aurora_abort "install$ERROR_INVALID_LOCAL_VALUE" 4
    fi
    if [ "$Download_before_install" = "false" ]; then
        return
    elif [ "$Download_before_install" = "true" ]; then
        check_network
    elif [ -z "$Internet_CONN" ]; then
        Aurora_ui_print "$CHECK_NETWORK"
        return
    fi

    while [ $network_counter -le 20 ]; do
        var_name="LINKS_${network_counter}"
        eval "link=\$${var_name}"

        if [ -n "$link" ]; then
            download_file "$link"
        fi
        network_counter=$((network_counter + 1))
    done
    initialize_install "$download_destination/"
}
#About_the_custom_script
###############
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
CustomShell() {
    if [ "$CustomScript" = "false" ]; then
        Aurora_ui_print "$CUSTOM_SCRIPT_DISABLED"
    elif [ "$CustomScript" = "true" ]; then
        Aurora_ui_print "$CUSTOM_SCRIPT_ENABLED"
        # shellcheck disable=SC1090
        . "$MODPATH/$CustomScriptPath"
    else
        Aurora_abort "CustomScript$ERROR_INVALID_LOCAL_VALUE" 4
    fi
}
###############
ClearEnv() {
    if [ "$APATCH" != true ]; then
        rm -rf "$INSTALLER_MODPATH"
        cp "$INSTALLER_MODPATH/module.prop" "/data/adb/modules/AuroraNasaInstaller/module.prop"
    fi
    find "$INSTALLER_MODPATH" ! -name "module.prop" -exec rm -rf {} \;
}
##########################################################
main
