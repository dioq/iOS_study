#include <stdio.h>
#include <getopt.h>
#import <Foundation/Foundation.h>
#import "sqlite3.h"

struct option longopts[] = {
    {"show", no_argument, NULL, 0x100},
    {"agrp", required_argument, NULL, 0x101},
    {"query", no_argument, NULL, 0x102},
    {"clear", no_argument, NULL, 0x103},
    {"wx_token", required_argument, NULL, 0x104},
    {0, 0, 0, 0},
};


static NSString *databasePath = @"/var/Keychains/keychain-2.db";
// 显示所有 agrp
void dumpKeychainEntitlements()
{
    const char *dbpath = [databasePath UTF8String];
    sqlite3 *keychainDB;
    sqlite3_stmt *statement;
    NSMutableString *entitlementXML = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                                                                         "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
                                                                         "<plist version=\"1.0\">\n"
                                                                         "\t<dict>\n"
                                                                         "\t\t<key>keychain-access-groups</key>\n"
                                                                         "\t\t<array>\n"];
    if (sqlite3_open(dbpath, &keychainDB) == SQLITE_OK)
    {
        const char *query_stmt = "select distinct agrp from genp union select distinct agrp from inet union select distinct agrp from cert union select distinct agrp from keys;";

        if (sqlite3_prepare_v2(keychainDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *group = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];

                [entitlementXML appendFormat:@"\t\t\t<string>%@</string>\n", group];
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Unknown error querying keychain database\n");
        }

        [entitlementXML appendString:@"\t\t</array>\n"
                                      "\t</dict>\n"
                                      "</plist>\n"];
        sqlite3_close(keychainDB);
        NSLog(@"%@", entitlementXML);
    }
    else
    {
        NSLog(@"Unknown error opening keychain database\n");
    }
}

// 查询指定 agrp 的表
void query_by_argp(const char *agrp)
{
    if(!(agrp)) {
        printf("参数不能为空");
        return;
    }
    // 生成一个查询用的 可变字典(SecItemCopyMatching的查询是模糊匹配,给的条件越少查询结果越多)
    NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
    // 返回结果包含 属性
    [queryDic setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    // 返回结果包含 数据
    [queryDic setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    // 返回所有数据(不限制条数)
    [queryDic setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];

    // group keychain 钥匙串所在组
    NSString *agrp_oc = [NSString stringWithUTF8String:agrp];
    [queryDic setObject:agrp_oc forKey:(__bridge id)kSecAttrAccessGroup];

    NSArray *secItemClasses = [NSArray arrayWithObjects:
                                           (__bridge id)kSecClassGenericPassword,
                                           (__bridge id)kSecClassInternetPassword,
                                           (__bridge id)kSecClassCertificate,
                                           (__bridge id)kSecClassKey,
                                           (__bridge id)kSecClassIdentity,
                                           nil];

    for (id secItemClass in secItemClasses)
    {
        [queryDic setObject:secItemClass forKey:(__bridge id)kSecClass];
        // 查询
        OSStatus status = -1;
        CFTypeRef result = NULL;
        status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDic, &result); // 核心API 查找是否匹配 和返回密码！
        switch (status)
        {
        case errSecSuccess:
            NSLog(@"%@:\n%@", secItemClass, result);
            break;
        case errSecItemNotFound:
            NSLog(@"%@: 没有数据", secItemClass);
            break;
        default:
            NSLog(@"%@: 其他情况. status = %d", secItemClass, status);
            break;
        }
        // 查询结果需要释放
        if (result)
        {
            CFRelease(result);
        }
    }
}

// 清空指定 agrp 的表
void clear_by_argp(const char *agrp)
{
    if(!(agrp)) {
        printf("参数不能为空");
        return;
    }
    NSArray *secItemClasses = [NSArray arrayWithObjects:
                                           (__bridge id)kSecClassGenericPassword,
                                           (__bridge id)kSecClassInternetPassword,
                                           (__bridge id)kSecClassCertificate,
                                           (__bridge id)kSecClassKey,
                                           (__bridge id)kSecClassIdentity,
                                           nil];
    for (id secItemClass in secItemClasses)
    {
        NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
        [queryDic setObject:secItemClass forKey:(__bridge id)kSecClass];
        // group keychain 钥匙串所在组
        NSString *agrp_oc = [NSString stringWithUTF8String:agrp];
        [queryDic setObject:agrp_oc forKey:(__bridge id)kSecAttrAccessGroup];
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)queryDic);
        if (status == errSecSuccess)
        {
            NSLog(@"%@ 表删除成功", secItemClass);
        }
        else if (status == errSecItemNotFound)
        {
            NSLog(@"%@ 表里没有数据", secItemClass);
        }
        else
        {
            NSLog(@"%@ 表删除失败,status = %d", secItemClass, status);
        }
    }
}

// 更新微信的62数据
void update_wx_token(const char *agrp,const char *token) {
    if(!(agrp || token)) {
        printf("参数不能为空");
        return;
    }

    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    [queryDict setObject:@"wx.dat" forKey:(__bridge id)kSecAttrAccount];
    [queryDict setObject:@"wx.dat" forKey:(__bridge id)kSecAttrService];
    // group keychain 钥匙串所在组
    NSString *agrp_oc = [NSString stringWithUTF8String:agrp];
    [queryDict setObject:agrp_oc forKey:(__bridge id)kSecAttrAccessGroup];
    // 查询时这个条件必不可少
    [queryDict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    //Keychain Accessibility Values
    [queryDict setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];

    // 更新数据的字典
    NSMutableDictionary *updateDict = [NSMutableDictionary dictionaryWithDictionary:queryDict];
    NSString *token_oc = [NSString stringWithUTF8String:token];
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token_oc requiringSecureCoding:YES error:&error];
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return;
    }
    [updateDict setObject:data forKey:(__bridge id)kSecValueData];
   
    
    NSLog(@"待更新的字典 queryDic:\n%@",updateDict);
    
    OSStatus status;
    status = SecItemAdd((__bridge CFDictionaryRef)updateDict, NULL);
    switch (status) {
        case errSecSuccess:
            NSLog(@"添加成功!");
            break;
        case errSecDuplicateItem:
        {
            [updateDict removeObjectForKey:(__bridge id)kSecClass];// 删除 table 这一项
            status = SecItemUpdate((__bridge CFDictionaryRef)queryDict, (__bridge CFDictionaryRef)updateDict);
            if (status == errSecSuccess){
                NSLog(@"修改成功!");
            }else {
                NSLog(@"修改失败,status = %d ...",status);
            }
        }
            break;
        case errSecNoSuchAttr:
            NSLog(@"有不存在的属性");
            break;
        default:
            NSLog(@"status = %d ...",status);
            break;
    }
}

int main(int argc, const char *argv[])
{
    @autoreleasepool
    {
        int c;
        char *agrp;
        // char *token;
        // printf("optind:%d,opterr:%d,optopt:%d\n", optind, opterr, optopt);
        while ((c = getopt_long(argc, argv, "h", longopts, NULL)) != -1)
        {
            // printf("optind:%d,opterr:%d,optopt:%d\n", optind, opterr, optopt);
            switch (c)
            {
            case 'h':
            {
                printf("如果你需要帮助,请联系软件作者\n");
            }
            break;
            case 0x100:
            {
                printf("have option: --show\n");
                dumpKeychainEntitlements();
            }
            break;
            case 0x101:
            {
                printf("have option: --argp %s\n", optarg);
                agrp = optarg;
            }
            break;
            case 0x102:
            {
                printf("have option: --query\n");
                query_by_argp(agrp);
            }
            break;
            case 0x103:
            {
                printf("have option: --clear\n");
                clear_by_argp(agrp);
            }
            break;
            case 0x104:
            {
                printf("have option: --wx_token %s\n", optarg);
                update_wx_token(agrp,optarg);
            }
            break;
            case '?':
                printf("Unknown option: %c\n", (char)optopt);
                break;
            default:
                printf("default:%d\n", c);
                break;
            }
        }
    }
    return 0;
}
