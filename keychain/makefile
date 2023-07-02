cc = clang

# 架构
arch=arm64
# -isysroot指定系统SDK路径
SDK_path=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk

# 开发者证书
certificate="Apple Development: Lin Sheng (3AHP8847PU)"
# certificate="Apple Distribution: Lin Sheng (5YBWG2X244)"
# certificate="Apple Development: Chen Weijia (2YPNXV52GT)"
# certificate="Apple Distribution: Chen Weijia (DZ4RUFAG9F)"
# certificate="Apple Development: Chen Weijia (6PCX683297)"
# certificate="Apple Distribution: Chen Weijia (G2BVY4NT73)"

source = main.m
outfile = keychain_analyze

program:
	@${cc} -fobjc-arc -arch ${arch} -fmodules -isysroot ${SDK_path} ${source} -o ${outfile}

sign: program
	@/usr/bin/codesign --force --sign ${certificate} --entitlements entitlements.plist ${outfile}

push:
	@scp -r -P 2222 keychain_analyze root@localhost:/Applications/

all: program sign push

clean:
	@-rm -rf ${outfile}
