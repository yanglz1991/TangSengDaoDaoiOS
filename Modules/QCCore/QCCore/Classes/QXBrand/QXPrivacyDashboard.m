//
//  QXPrivacyDashboard.m
//  QCCore
//

#import "QXPrivacyDashboard.h"

@implementation QXPrivacyEntry
@end

@implementation QXPrivacyThirdParty
@end

@interface QXPrivacyDashboard ()
@property (nonatomic, copy) NSArray<QXPrivacyEntry *>      *cachedEntries;
@property (nonatomic, copy) NSArray<QXPrivacyThirdParty *> *cachedThirdParties;
@end

@implementation QXPrivacyDashboard

+ (instancetype)sharedDashboard {
    static QXPrivacyDashboard *d = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        d = [QXPrivacyDashboard new];
    });
    return d;
}

- (NSArray<QXPrivacyEntry *> *)entries {
    if (self.cachedEntries) {
        return self.cachedEntries;
    }
    NSMutableArray *list = [NSMutableArray array];

    [list addObject:[self entryTitle:@"账号信息"
                              summary:@"用于注册、登录、找回密码与多端同步。手机号在客户端展示时默认脱敏。"
                             category:QXPrivacyDataCategoryAccount
                             purposes:@[@(QXPrivacyDataPurposeAppFunctionality), @(QXPrivacyDataPurposeAccountSecurity)]
                         leavesDevice:YES
                         linkedToUser:YES
                            retention:@"账号注销后 30 天内删除"
                          userControl:@"在「我 - 设置 - 账号与安全」中可注销账号"]];

    [list addObject:[self entryTitle:@"通讯录"
                              summary:@"仅在你主动开启「手机号添加好友」时上传哈希值，用于匹配已注册用户；原始号码不离开设备。"
                             category:QXPrivacyDataCategoryContact
                             purposes:@[@(QXPrivacyDataPurposeAppFunctionality)]
                         leavesDevice:YES
                         linkedToUser:NO
                            retention:@"匹配完成后立即丢弃，不持久化"
                          userControl:@"在「我 - 设置 - 隐私 - 通讯录匹配」中可关闭"]];

    [list addObject:[self entryTitle:@"聊天消息"
                              summary:@"消息正文使用端到端加密在服务端透传；本地以 SQLCipher 加密存储。"
                             category:QXPrivacyDataCategoryMessages
                             purposes:@[@(QXPrivacyDataPurposeAppFunctionality)]
                         leavesDevice:YES
                         linkedToUser:YES
                            retention:@"服务端不留存正文；本地由用户控制"
                          userControl:@"长按消息可删除；在设置中可清空所有聊天记录"]];

    [list addObject:[self entryTitle:@"图片与视频"
                              summary:@"用于发送多媒体消息。仅当你主动选择文件后才会上传。"
                             category:QXPrivacyDataCategoryMedia
                             purposes:@[@(QXPrivacyDataPurposeAppFunctionality)]
                         leavesDevice:YES
                         linkedToUser:YES
                            retention:@"会话内保留，可随时删除"
                          userControl:@"在每条消息上长按删除"]];

    [list addObject:[self entryTitle:@"设备信息"
                              summary:@"用于多端会话管理与异常登录检测。包括机型、系统版本与匿名安装指纹。"
                             category:QXPrivacyDataCategoryDevice
                             purposes:@[@(QXPrivacyDataPurposeAccountSecurity)]
                         leavesDevice:YES
                         linkedToUser:YES
                            retention:@"账号下设备列表保留至账号注销"
                          userControl:@"在「设置 - 账号 - 设备管理」中可移除设备"]];

    [list addObject:[self entryTitle:@"诊断数据"
                              summary:@"启动时间、卡顿等性能指标，仅在你主动选择「上报问题」时上传。"
                             category:QXPrivacyDataCategoryDiagnostics
                             purposes:@[@(QXPrivacyDataPurposeAnalytics)]
                         leavesDevice:NO
                         linkedToUser:NO
                            retention:@"本地循环缓冲，最多保留最近 512 条事件"
                          userControl:@"默认仅本地存储，可在设置中关闭"]];

    [list addObject:[self entryTitle:@"位置信息"
                              summary:@"仅当你发送位置消息时使用。禧语不会在后台采集你的地理位置。"
                             category:QXPrivacyDataCategoryLocation
                             purposes:@[@(QXPrivacyDataPurposeAppFunctionality)]
                         leavesDevice:YES
                         linkedToUser:YES
                            retention:@"作为消息内容随会话保留"
                          userControl:@"在系统「设置 - 隐私 - 定位服务」可整体关闭"]];

    self.cachedEntries = [list copy];
    return self.cachedEntries;
}

- (QXPrivacyEntry *)entryTitle:(NSString *)title
                       summary:(NSString *)summary
                      category:(QXPrivacyDataCategory)category
                      purposes:(NSArray *)purposes
                  leavesDevice:(BOOL)leavesDevice
                  linkedToUser:(BOOL)linked
                     retention:(NSString *)retention
                   userControl:(NSString *)control {
    QXPrivacyEntry *e = [QXPrivacyEntry new];
    e.title         = title;
    e.summary       = summary;
    e.category      = category;
    e.purposes      = purposes ?: @[];
    e.leavesDevice  = leavesDevice;
    e.linkedToUser  = linked;
    e.retention     = retention;
    e.userControl   = control;
    return e;
}

- (NSArray<QXPrivacyThirdParty *> *)thirdParties {
    if (self.cachedThirdParties) {
        return self.cachedThirdParties;
    }
    NSMutableArray *list = [NSMutableArray array];

    QXPrivacyThirdParty *bugly = [QXPrivacyThirdParty new];
    bugly.name        = @"Bugly";
    bugly.purpose     = @"崩溃与卡顿监控";
    bugly.privacyURL  = @"https://bugly.qq.com/v2/privacy";
    bugly.dataItems   = @[@"崩溃堆栈", @"设备机型", @"系统版本"];
    [list addObject:bugly];

    QXPrivacyThirdParty *afn = [QXPrivacyThirdParty new];
    afn.name       = @"AFNetworking";
    afn.purpose    = @"HTTPS 网络请求";
    afn.privacyURL = @"https://github.com/AFNetworking/AFNetworking";
    afn.dataItems  = @[];
    [list addObject:afn];

    QXPrivacyThirdParty *sd = [QXPrivacyThirdParty new];
    sd.name       = @"SDWebImage";
    sd.purpose    = @"图片缓存与显示";
    sd.privacyURL = @"https://github.com/SDWebImage/SDWebImage";
    sd.dataItems  = @[];
    [list addObject:sd];

    QXPrivacyThirdParty *fmdb = [QXPrivacyThirdParty new];
    fmdb.name       = @"FMDB / SQLCipher";
    fmdb.purpose    = @"本地加密存储";
    fmdb.privacyURL = @"https://www.zetetic.net/sqlcipher/";
    fmdb.dataItems  = @[];
    [list addObject:fmdb];

    self.cachedThirdParties = [list copy];
    return self.cachedThirdParties;
}

- (NSString *)userVisibleSummary {
    NSArray<QXPrivacyEntry *> *list = [self entries];
    NSMutableString *out = [NSMutableString string];
    [out appendString:@"禧语数据使用透明度声明\n\n"];
    for (QXPrivacyEntry *e in list) {
        [out appendFormat:@"• %@\n  %@\n  保留：%@\n  你可以：%@\n\n",
         e.title, e.summary, e.retention, e.userControl];
    }
    return [out copy];
}

- (NSData *)serializeJSON {
    NSMutableArray *eArr = [NSMutableArray array];
    for (QXPrivacyEntry *e in [self entries]) {
        [eArr addObject:@{
            @"title":         e.title         ?: @"",
            @"summary":       e.summary       ?: @"",
            @"category":      @(e.category),
            @"purposes":      e.purposes      ?: @[],
            @"leavesDevice":  @(e.leavesDevice),
            @"linkedToUser":  @(e.linkedToUser),
            @"retention":     e.retention     ?: @"",
            @"userControl":   e.userControl   ?: @"",
        }];
    }
    NSMutableArray *tArr = [NSMutableArray array];
    for (QXPrivacyThirdParty *t in [self thirdParties]) {
        [tArr addObject:@{
            @"name":       t.name       ?: @"",
            @"purpose":    t.purpose    ?: @"",
            @"privacyURL": t.privacyURL ?: @"",
            @"dataItems":  t.dataItems  ?: @[],
        }];
    }
    NSDictionary *root = @{ @"entries": eArr, @"thirdParties": tArr };
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:&err];
    return err ? [NSData data] : (data ?: [NSData data]);
}

@end
