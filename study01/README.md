# 手动编译 一个 iOS application
一个iOS应用的生成详细过程.
不使用 Xcode, 用最原始的方法编译一个 iOS ipa包. 越精简越好,用最少的配置和最少的代码 把一个 具有所有内容的 iOS 工程编译成一个 ipa 包.
entitlements.plist 权限文件只要最少的东西,能编译就行
工程的配置Info.plist 文件中的配置项只要能支撑一个 ipa 包在设备上运行就行
整个过程配置 和 代码越少,越能理解一个 iOS app 的生成过程

clang 编译参数
-fmodules      自动寻找到需要的系统库
-fobjc-arc     由ARC编译
-isysroot      指定系统SDK路径

## 步骤
1. 使用 clang 编译所有的 Objective-C 和  C/C++ 源文件   
   生成的文件放到 Payload/appname.app 文件里

2. 使用　ibtool　编译 .storyboard 文件为 .storyboardc    
   生成的文件放到 Payload/appname.app
   
3. 使用　ibtool　编译 .xib 文件为 .nib    
   生成的文件放到 Payload/appname.app

4. 自己构造Info.plist文件，并配置项目的相关信息      
   Info.plist 在 Payload/appname.app 文件里      
   使用 write 往 Info.plist 里写数据    

5. 将项目里的所有图片资源复制到 Payload 里的 appname.app 文件里    
   不需要顺序直接往里面放就可以了

6. 使用 codesign 签名 第一步生成的可执行文件或库文件      
   这里需要用到描述文件　embedded.mobileprovision（可以用苹果开发者账号登录苹果官网下载，但要注意描述文件里要添加测试设备的uuid，当然也有其他方式我就不列举）
   
7. 将 Payload 文件压缩成 ipa 安装包
