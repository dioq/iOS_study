cc = clang

# 当前目录的绝对路径
CurrentDir = "$(shell pwd)"

# 开发者证书
certificate="Apple Development: Zhendong Li (27Z9PVM2UT)"

# 待编译的 Objective-C 源文件
source = main.m AppDelegate.m ViewController.m NextViewController.m
# Objective-C 源文件 编译后的 Mach-O 可执行文件名
exec_file = MyTest

# clang 编译的一些参数
# -isysroot指定系统SDK路径
SDK_path=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk

# app 的 bundle id
BundleIdentifier=cn.jobs8
# xxx.app 路径
app_path=./Payload/"${exec_file}.app"

# 生成Payload 相关包
app_pkg:
	@mkdir Payload
	@mkdir Payload/"${exec_file}.app"
	

# 编译Mach-O 可执行文件
exec:
	@${cc} -fobjc-arc -arch arm64 -fmodules -isysroot ${SDK_path} ${source} -o ${app_path}/${exec_file}

# 编译 .storyboard .xib 可视化文件
nib:
	@ibtool --compilation-directory ${app_path} LaunchScreen.storyboard
	@ibtool --compilation-directory ${app_path} NextViewController.xib

# 生成 Info.plist
plist:
	@defaults write $(CurrentDir)/${app_path}/Info CFBundleExecutable -string ${exec_file}
	@defaults write $(CurrentDir)/${app_path}/Info CFBundleIdentifier -string ${BundleIdentifier}
	@defaults write $(CurrentDir)/${app_path}/Info UILaunchStoryboardName -string LaunchScreen

# 对可执行文件进行签名
sign:
	@/usr/bin/codesign --force --sign ${certificate} --entitlements entitlements.plist ${app_path}/${exec_file}

# 生成 ipa 包
ipa:
	@zip -rq "${exec_file}.ipa" Payload

# 安装 ipa 包
install:
	@ideviceinstaller -i "${exec_file}.ipa"

# lldb 调用程序
debug:
	@ios-deploy -b ${app_path} --debug -W

all: app_pkg exec nib plist sign ipa

clean:
	@-rm -rf Payload
	@-rm -rf "${exec_file}.ipa"
