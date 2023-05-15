# 在iOS中启动进程

## 越狱设备上操作
Mach-O可执行文件需要用个人开发者证书签名
### 1. 在容器中运行
iOS所有第三方应用按Apple规定都需要在容器中运行,需把可执行文件放到 xxx/containers/xxx 特定目录中,可执行文件在特定目录中启动会绑定容器,在容器中运行的进程被限制在沙盒中
如:
scp -r -P 2222 ./Payload/Test.app/main root@localhost:/private/var/containers/Bundle
把生成的 Mach-O 可执行文件放到 /private/var/containers/Bundle 目录下
./main
运行可执行文件时就会自动绑定容器.如果在其他目录下运行会报 kill -9
### 2. 不在容器中运行
如果启动进程不进行容器化,该进程不受沙盒限制可以对系统进行不受限制的访问
scp -r -P 2222 ./Payload/Test.app/main root@localhost:/Applications
./main

## 在非越狱上调试
非越狱手机上只能打包成 ipa,装在手机上执行
可以用
ios-deploy -b Payload/Test.app --debug -W
调试可执行文件,能看到运行效果
