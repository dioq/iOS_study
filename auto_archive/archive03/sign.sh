#!/bin/bash
<<!
重签名
传入参数描述:
$1          待签名app路径
$2          签名所需的描述文件
!

# 待签名 app 包路径
app_path=$1
# 描述文件路径
mobileprovision=$2

# 签名时用的证书
# certificate="Apple Distribution: Lin Sheng (5YBWG2X244)"
certificate="Apple Development: Lin Sheng (3AHP8847PU)"
# certificate="Apple Development: Zhendong Li (27Z9PVM2UT)"
# certificate="Apple Distribution: Zhendong Li (38D3676P2T)"

# 描述文件先复制一份,名字也改成需要的格式
cp $mobileprovision ./embedded.mobileprovision

# 描述文件 生成权限文件
# Entitlements 是应用功能和授权相关的文档，涉及到 iCloud、推送等功能的配置信息。可以通过描述文件生成也可以自己手动生成,后面签名要用到
security cms -D -i ./embedded.mobileprovision > ./profile.plist
# 上面会生成一个完整的 plist，我们只需要里面的Entitlements字段，执行命令行:
entitlements=entitlements.plist
/usr/libexec/PlistBuddy -x -c 'Print :Entitlements' ./profile.plist > ./${entitlements}

# 把描述文件添加到包里(如果设备里已经有了描述文件,这里也可以不添加)
cp ./embedded.mobileprovision ${app_path}


# 保持 bundle id 一致
APPID=$(/usr/libexec/PlistBuddy -c "Print :application-identifier" ${entitlements})
bundle_id=${APPID:11}
if [ "${bundle_id}" != "*" ]
then
	/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $bundle_id" "${app_path}/Info.plist"
fi


# 签名
# 可以删掉个人证书签名不方便的文件,而不影响正常使用
# rm -rf ${app_path}/Watch ${app_path}/PlugIns
# 签名动态库
if [ -d "${app_path}/Frameworks" ]; then
        /usr/bin/codesign --force --sign "$certificate" --entitlements ${entitlements} ${app_path}/Frameworks/*
fi
# 签名插件
if [ -d "${app_path}/PlugIns" ]; then
        /usr/bin/codesign --force --sign "$certificate" --entitlements ${entitlements} ${app_path}/PlugIns/*
fi
# 签名 Watch
if [ -d "${app_path}/Watch" ]; then
        /usr/bin/codesign --force --sign "$certificate" --entitlements ${entitlements} ${app_path}/Watch/*
fi
# 获取 Mach-O 可执行文件名
exec_file=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "${app_path}/Info.plist")
# 签名Mach-O可执行文件
if [ -f "${app_path}/${exec_file}" ]; then
        /usr/bin/codesign --force --sign "$certificate" --entitlements ${entitlements} ${app_path}/${exec_file}
else
        echo "${app_path}/${exec_file} not exist!"
        exit -1
fi


# 生成ipa包
mkdir Payload
cp -r ${app_path} Payload
zip -rq "${exec_file}_signed.ipa" Payload

# 清理现场
rm -rf embedded.mobileprovision profile.plist ${entitlements} ./Payload
