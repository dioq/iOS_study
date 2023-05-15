cc = clang

# 架构
arch=arm64
# -isysroot指定系统SDK路径
SDK_path=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk

# 开发者证书
certificate="Apple Development: Zhendong Li (27Z9PVM2UT)"

source = main.m
outfile = main

program:
	@${cc} -fobjc-arc -arch ${arch} -fmodules -isysroot ${SDK_path} ${source} -o ${outfile}
	@mv ${outfile} ./Payload/Test.app/

sign: program
	@/usr/bin/codesign --force --sign ${certificate} --entitlements entitlements.plist ./Payload/Test.app/${outfile}

debug:
	@ios-deploy -b Payload/Test.app --debug -W

all: program sign debug

clean:
	@-rm -rf ./Payload/Test.app/${outfile} ./Payload/Test.app/_CodeSignature
