# 编译可在iOS设备上运行的Mach-O可执行文件

## 在越狱设备上
scp -r -P 2222 ./Payload/Test.app/main root@localhost:/private/var/containers/Bundle
把生成的 Mach-O 可执行文件放到 /private/var/containers/Bundle 目录下
./main
就可执行.如果在其他目录下运行会报 kill -9
只要用个人开发者证书签名的Mach-O文件可在任意iOS设备上执行

## 在非越狱上运行
非越狱手机上只能打包成 ipa,装在手机上执行
可以用
ios-deploy -b Payload/Test.app --debug -W
调试可执行文件,能看到运行效果
