#!/system/bin/sh
# shellcheck disable=SC2034
# shellcheck disable=SC2154
# shellcheck disable=SC3043
# shellcheck disable=SC2155
# shellcheck disable=SC2046
# shellcheck disable=SC3045
main() {
    mkdir -p "$MODPATH/TEMP"
    tempdir="$MODPATH/TEMP"
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
    if [ ! -f "$MODPATH/$script_path" ]; then
        abort "Notfound File!!!($script_path)"
    else
        # shellcheck disable=SC1090
        . "$MODPATH/$script_path"
    fi
    if [ -f "$MODPATH/prebuilts.tar.xz" ]; then
        mkdir -p "$MODPATH/prebuilts"
        tar -xJf "$MODPATH/prebuilts.tar.xz" -C "$MODPATH/"
    fi
    set_permissions_755 "$zips"
    version_check
    sclect_settings_install_on_main
    patches_install
    CustomShell
    ClearEnv
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
    MODIDBACKUP="$MODID"
    MODPATHBACKUP=$MODPATH
    for ZIPFILE in $1; do
        if [ "$Installer_Log" = "false" ]; then
            install_module >/dev/null 2>&1
        elif [ "$Installer_Log" = "true" ]; then
            install_module
        fi
    done
    MODPATH=$MODPATHBACKUP
    MODID="$MODIDBACKUP"
}

Installer() {
    Aurora_test_input "Installer" "1" "$1"
    if [ "$Installer_Log" != "false" ] && [ "$Installer_Log" != "true" ]; then
        Aurora_abort "Installer_Log$ERROR_INVALID_LOCAL_VALUE" 4
    fi
    #test code
    if [ "$2" = "KSU" ]; then
        if [ "$KSU" != true ]; then
            echo "KSU is not true, returning"
            return
        fi
    elif [ "$2" = "APATCH" ]; then
        if [ "$APATCH" != true ]; then
            echo "APATCH is not true, returning"
            return
        fi
    elif [ "$2" = "MAGISK" ]; then
        if [ -z "$APATCH" ] && [ -z "$KSU" ] && [ -n "$MAGISK_VER_CODE" ]; then
            echo "MAGISK condition met, returning"
            return
        fi
    fi
    #end test code
    Aurora_ui_print "$MODULE_INTRO"
    if [ "$Installer_Compatibility" = "true" ]; then
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
    elif [ "$Installer_Compatibility" = "false" ]; then
        Installer_Compatibility_mode "$1"
    else
        Aurora_abort "Installer_Compatibility$ERROR_INVALID_LOCAL_VALUE" 4
    fi
    if [ "$fix_ksu_install" = "true" ] && [ "$KSU" = true ] && [ -z "$KSU_step_skip" ]; then
        temp_dir="$tempdir/KSU"
        mkdir -p "$temp_dir"
        unzip -d "$temp_dir" "$1" >/dev/null 2>&1
        KSU_Installer_TEMP_ID=$(awk -F= '/^id=/ {print $2}' "$temp_dir/module.prop")
        $zips "$tempdir/KSU/temp.zip" "$SECURE_DIR/modules_update/$KSU_Installer_TEMP_ID"/* >/dev/null 2>&1
        KSU_step_skip=true
        Installer "$tempdir/KSU/temp.zip" KSU
        rm -rf "$temp_dir"
        KSU_step_skip=""
    fi
    Aurora_ui_print "$MODULE_FINNSH"
}
initialize_install() {
    local dir="$1"
    local temp_all_files="$tempdir/listTMP"

    if [ ! -d "$dir" ]; then
        Aurora_ui_print "$WARN_ZIPPATH_NOT_FOUND $dir"
        return
    fi
    find "$dir" -mindepth 1 -maxdepth 1 -type d | while read -r entry; do
        local dirname=$(basename "$entry")
        local zip_file="$dir/$dirname.zip"
        $zips "$zip_file" "$entry/*" >/dev/null 2>&1
        rm -rf "$entry"
    done
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
        for apk_file in "$MODPATH/$PATCHAPK"/*; do
            if [ -f "$apk_file" ] && echo "$apk_file" | grep -iqE '\.apk$'; then
                install_output=$(pm install "$apk_file")
                if echo "$install_output" | grep -iq "Success"; then
                    Aurora_ui_print "$apk_file $INSTALL_SUCCESS"
                    apk_found=1
                else
                    Aurora_ui_print "$WARN_APK_INSTALLATION_FAILED $apk_file"
                    Aurora_ui_print "$install_output"
                fi
            fi
        done
        if [ $apk_found -eq 0 ]; then
            Aurora_ui_print "$WARN_PATCH_NOT_FOUND_IN $PATCHAPK"
        fi
    else
        Aurora_ui_print "$PATCHAPK $WARN_PATCHPATH_NOT_FOUND_IN_DIRECTORY"
    fi
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

##############
sclect_settings_install_on_main() {
    local network_counter=1
    if [ "$Installer_Compatibility" = "true" ]; then
        if [ "$KSU" = true ]; then
            if [ "$KSU_VER_CODE" -le "$ksu_min_normal_version" ]; then
                Installer_Compatibility=false
                Aurora_ui_print "KernelSU: $WARN_FORCED_COMPATIBILITY_MODE"
            fi
        elif [ "$APATCH" = true ]; then
            if [ "$APATCH_VER_CODE" -le "$apatch_min_normal_version" ]; then
                Installer_Compatibility=false
                Aurora_ui_print "APatch: $WARN_FORCED_COMPATIBILITY_MODE"
            fi
        fi
    fi
    if [ -f "$MODPATH"/output.tar.xz ]; then
        mkdir -p "$MODPATH/files/"
        tar -xJf "$MODPATH/output.tar.xz" -C "$MODPATH/"
        rm "$MODPATH/output.tar.xz"
    fi
    if [ "$install" = "true" ]; then
        initialize_install "$MODPATH/$ZIPLIST"
    fi
    if [ "$Download_before_install" = "false" ]; then
        return
    elif [ "$Download_before_install" = "true" ]; then
        check_network
        if [ -z "$Internet_CONN" ]; then
            Aurora_ui_print "$CHECK_NETWORK"
            return
        fi
    else
        Aurora_abort "Download_before_install$ERROR_INVALID_LOCAL_VALUE" 4
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
    if [ "$delete_download_files" = "true" ]; then
        rm -rf "$download_destination"
    elif [ "$delete_download_files" != "false" ] && [ "$delete_download_files" != "true" ]; then
        Aurora_abort "delete_download_files$ERROR_INVALID_LOCAL_VALUE" 4
    fi
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
    FILE1="/data/adb/modules_update/${MODID}/service.sh"
    echo "sleep 3" >"$FILE1"
    echo "rm -rf /data/adb/modules/$MODID/" >>"$FILE1"
    chmod +x "$FILE1"
}
##########################################################
if [ -n "$MODID" ]; then
    main
fi
Aurora_ui_print "$END"
