#!/system/bin/sh

# 自定义脚本
# -----------------
# 此脚本在默认脚本和设置脚本的基础上进行了扩展，可以直接使用其中的变量和函数。

# 二进制文件路径
# $zips7z = 7z
# $zips = zstd
# $jq = jq

# 未标注$MODPATH的默认调用时会自动在前方加入$MODPATH，因此无需手动添加。
# $MODPATH可以换成任意路径，但请确保路径的正确性。

# 自定义功能概览
# --------------
# 1. 美观打印：使用 Aurora_ui_print "要打印的内容" 进行美观的内容展示。
# 2. 模块安装：通过 initialize_install "$MODPATH/文件夹路径" 函数，可以自动安装目标目录下的所有模块。
# 3. 补丁安装：patches_install 函数会遍历并安装所有补丁。

# 示例：安装单个模块
# -----------------
# Installer "$MODPATH/模块路径.zip" # 来安装指定的模块。
# 针对特定root方案，使用 Installer "$MODPATH/模块路径.zip" "KSU或者APATCH或者magisk" 会在检测到目标环境时自动执行安装，否则不会执行安装。

# 示例：兼容模式安装
# ----------------
# 若需要在兼容模式下安装模块，请使用 Installer_Compatibility_mode "$MODPATH/模块路径.zip"。

# 示例：解压单个文件
# ----------------
# un7z "需要解压的文件名"  "目标文件夹" # 来解压指定文件。

# 示例：音量键选择安装模块
# ---------------------
# 使用 key_installer "$MODPATH/上键模块路径.zip" "$MODPATH/下键模块路径.zip" "需要打印的上键模块名" "需要打印的下键模块名" # 来通过音量键选择安装的模块。
# 如果不填写模块名称，安装时不会显示相关提示。

# 示例：音量键选择是否安装模块
# -----------------
# key_installer_once "$MODPATH/模块路径.zip" "需要打印的模块名" # 来通过音量键选择是否安装模块。

# 示例：从Github仓库中获取最新release文件链接
# github_get_url "仓库作者/仓库名称" "需要release中包含的文件名"
# 输出链接地址在 $DESIRED_DOWNLOAD_URL 变量中

# 示例：下载单个文件
# download_file "文件链接"

# 示例：检测音量键选择
# ------------------
# key_select # 调用后，可以通过 $key_pressed 变量获取用户通过音量键的选择结果。

# 任意补丁
# patch_default "$MODPATH" "原先的路径" "补丁路径"
# 当然你可以将$MODPATH替换为任意路径，以便调用模块外路径

# 示例：补丁已安装模块
# -----------------
# 若需将补丁应用于已安装的模块，可以使用如下命令：
# cp -r "$MODPATH/$PATCHMOD"/* "$SECURE_DIR/modules/"

# 示例：移动多个文件至/data/adb/
# -----------------
# mv_adb "文件夹路径"

# 示例：添加到magisk的denylist
# -----------------
# magisk_denylist_add "软件包名" # 仅magisk支持

# 示例：修补app的安卓数据目录
# -----------------
# App_data_patch_set_permissions "软件包名" "文件夹路径"

# 示例：刷写boot分区
# -----------------
# aurora_flash_boot "文件路径"

# 注意事项
# ------
# 请勿在此脚本中使用 exit 和 abort 函数，以避免意外中断脚本执行。
