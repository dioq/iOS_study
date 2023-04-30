cc=clang

# 架构
arch=arm64
# -isysroot指定系统SDK路径
SDK_path=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk

# 开发者证书
certificate="Apple Development: Zhendong Li (27Z9PVM2UT)"

source=main.m
outfile=main
dylib_source=caculate.c
out_dylib=libmymath.dylib

program:
	@${cc} -fobjc-arc -arch ${arch} -fmodules -isysroot ${SDK_path} ${source} -o ${outfile}
	@mv ${outfile} ./Payload/Test.app/

# 编译一个动态库
dylib:
	@${cc} -fobjc-arc -arch ${arch} -fmodules -isysroot ${SDK_path} -shared -fPIC ${dylib_source} -o ${out_dylib}
	@mv ${out_dylib} ./Payload/Test.app/

sign:
	@/usr/bin/codesign --force --sign ${certificate} --entitlements entitlements.plist ./Payload/Test.app/${out_dylib}
	@/usr/bin/codesign --force --sign ${certificate} --entitlements entitlements.plist ./Payload/Test.app/${outfile}

debug:
	@ios-deploy -b Payload/Test.app --debug -W

all: dylib program sign debug

clean:
	@-rm -rf ./Payload/Test.app/${out_dylib}
	@-rm -rf ./Payload/Test.app/${outfile}
	@-rm -rf ./Payload/Test.app/target
	@-rm -rf ./Payload/Test.app/_CodeSignature
