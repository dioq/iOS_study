#!/bin/bash
<<!
打包Xcode项目
传入参数描述:
$1          项目路径
$2          项目名称
!

project_path=$1
app_name=$2

# bundleID
bundle_identifier="cn.jobs8.archive"
# 最低支持的系统
version=15.0
# 编译的架构
architecture=arm64
# -isysroot指定系统SDK路径
SDK_path=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk


# 创建 xx.app 文件夹
app_path="${app_name}.app"
mkdir ${app_path}


# 提取 Xcode 工程中的必需的文件到 app 目录
extract_file() {
        for file in `ls -a $1`
        do
                if [ -d $1/$file ]  # 判断是否是 Directory, 如果是 Directory 则进行递归
                then
                        if [[ $file != '.' && $file != '..' ]]
                        then
                                # xxx.lproj 目录里包含国际化 和 storyboad 文件
                                if test "${file##*.}" = "lproj"
                                then
                                        cp -r $1/$file ${app_path}
                                elif test "${file##*.}" = "xcassets"
                                then
                                        cp -r $1/$file ${app_path} 
                                else    # 其他文件则继续递归
                                        extract_file $1/$file
                                fi
                        fi
                else    # 如果是 file
                        if test "${file##*.}" = "m"
                        then
                                cp $1/$file ${app_path}
                        elif test "${file##*.}" = "h"
                        then
                                cp $1/$file ${app_path}
                        elif test "${file##*.}" = "c"
                        then
                                cp $1/$file ${app_path}
                        elif test "${file##*.}" = "storyboard"
                        then
                                cp $1/$file ${app_path}
                        elif test "${file##*.}" = "xib"
                        then
                                cp $1/$file ${app_path}
                        elif test "${file##*.}" = "plist"
                        then
                                cp $1/$file ${app_path}
                        elif test "${file##*.}" = "png"
                        then
                                cp $1/$file ${app_path}
                        elif test "${file##*.}" = "jpeg"
                        then
                                cp $1/$file ${app_path}
                        elif test "${file##*.}" = "json"
                        then
                                cp $1/$file ${app_path}
                        fi
                fi
        done
}

# 压缩 Assets.xcassets
archive_assets() {
        actool --output-format human-readable-text --notices --warnings --compress-pngs  --minimum-deployment-target ${version} --platform iphoneos --compile ${app_path} ${app_path}/Assets.xcassets
        cp ${app_path}/Assets.xcassets/AppIcon.appiconset/icon-60@2x.png ${app_path}/AppIcon60x60@2x.png
        rm -rf ${app_path}/Assets.xcassets
}

# 递归遍历,编译 Objective-C\C代码, 编译可视化文件 .xib .storyboard
compile_recurse() {
        for file in `ls -a $1`
        do
                if [ -d $1/$file ]  # 判断是否是 Directory, 如果是 Directory 则进行递归
                then
                        if [[ $file != '.' && $file != '..' ]]
                        then
                                compile_recurse $1/$file
                        fi
                else    # 如果是 file
                        if test "${file##*.}" = "m"
                        then
                                clang   -fmodules -fobjc-arc \
                                        -isysroot ${SDK_path} \
                                        -arch ${architecture} \
                                        -mios-version-min=${version} \
                                        -c $1/${file} \
                                        -o $1/"${file%%.*}.o"
                                # 删除编译过的文件
                                rm -rf $1/${file}
                        elif test "${file##*.}" = "c"
                        then
                                clang   -arch ${architecture} \
                                        -c $1/${file} \
                                        -o $1/"${file%%.*}.o"
                                rm -rf $1/${file}
                        elif test "${file##*.}" = "storyboard"
                        then
                                ibtool --compilation-directory $1 $1/$file
                                rm -rf $1/${file}
                        elif test "${file##*.}" = "xib"
                        then
                                ibtool --compilation-directory $1 $1/$file
                                rm -rf $1/${file}
                        fi
                fi
        done
}
# 最终编译成 Mach-O 并删除剩余源文件
compile() {
        compile_recurse ${app_path}

        clang   -fmodules -fobjc-arc \
                -isysroot ${SDK_path} \
                -arch ${architecture} \
                -mios-version-min=${version} \
                ${app_path}/*.o     \
                -o ${app_path}/${app_name}
        # 删除源文件
        rm -rf ${app_path}/*.h ${app_path}/*.o
}

# 配置 Info.plist
write_config() {
        ## 先删除 Info.plist 里己有的项
        /usr/libexec/PlistBuddy -c "Delete :CFBundleIdentifier" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Delete :CFBundleName" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Delete :CFBundleExecutable" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Delete :CFBundleDevelopmentRegion" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Delete :CFBundlePackageType" ${app_path}/Info.plist


        /usr/libexec/PlistBuddy -c "Add :CFBundleDevelopmentRegion string en" ${app_path}/Info.plist
        # plist文件结构的版本
	/usr/libexec/PlistBuddy -c "Add :CFBundleInfoDictionaryVersion string 6.0" ${app_path}/Info.plist
        # APPL: app，FMWK: frameworks，BND: loadable bundles
	/usr/libexec/PlistBuddy -c "Add :CFBundlePackageType string APPL" ${app_path}/Info.plist
	/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 1.0" ${app_path}/Info.plist
	/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string 1" ${app_path}/Info.plist
	/usr/libexec/PlistBuddy -c "Add :LSRequiresIPhoneOS bool YES" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Add :DTPlatformName string iphoneos" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Add :UILaunchStoryboardName string LaunchScreen" ${app_path}/Info.plist
        #/usr/libexec/PlistBuddy -c "Add :UIMainStoryboardFile string Main" ${app_path}/Info.plist
	/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string ${bundle_identifier}" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Add :CFBundleName string ${app_name}" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string ${app_name}" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Add :MinimumOSVersion string ${version}" ${app_path}/Info.plist
        # 配置 iOS icon
        /usr/libexec/PlistBuddy -c "Add :CFBundleIcons dict" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Add :CFBundleIcons:CFBundlePrimaryIcon dict" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Add :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconName string AppIcon" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Add :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles array" ${app_path}/Info.plist
        /usr/libexec/PlistBuddy -c "Add :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles:0 string AppIcon60x60" ${app_path}/Info.plist
}

main() {
        extract_file ${project_path}
        archive_assets
        compile
        write_config
}

main
