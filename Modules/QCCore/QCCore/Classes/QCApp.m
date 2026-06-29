//
//  QCApp.m
//  QCCore
//
//  Created by tt on 2019/12/1.
//
#import <UserNotifications/UserNotifications.h>
#import "QCApp.h"
#import "QCEndpointManager.h"
#import "QCModuleManager.h"
#import "QCConstant.h"
#import "QCConversationVC.h"
#import "QCNavigationManager.h"
#import <QCIM/QCIM.h>
#import "QCMessageRegistry.h"
#import "QCTextMessageCell.h"
#import "QCEmojiPanel.h"
#import "QCMorePanel2.h"
#import "QCUnkownMessageCell.h"
#import "QCMoreItemModel.h"
#import "QCResource.h"
#import "QCMoreItemClickEvent.h"
#import "QCImageMessageCell.h"
#import "QCConversationContext.h"
#import "QCVoicePanel.h"
#import "QCVoiceMessageCell.h"
#import "QCGroupManager.h"
#import "QCSystemMessageCell.h"
#import "QCConversationPersonSettingVC.h"
#import "QCConversationGroupSettingVC.h"
#import "QCContactsSelectVC.h"
#import "QCMessageManager.h"
#import "QCEmojiContentView.h"
#import "QCStickerGIFContentView.h"
#import "QCGIFMessageCell.h"
#import "QCGIFContent.h"
#import "QCConversationListSelectVC.h"
#import "QCSyncService.h"
#import "QCNavigationManager.h"
#import "QCPanelDefaultFuncItem.h"
#import "QCScanVC.h"
#import "QCWebViewVC.h"
#import "QCCardContent.h"
#import "QCCardCell.h"
#import "QCUserInfoVC.h"
#import "QCMeInfoVC.h"
#import "QCMeItem.h"
#import "QCMePushSettingVC.h"
#import "QCCommonSettingVC.h"
#import "QCNetworkListener.h"
#import "QCTypingMessageCell.h"
#import "QCTypingContent.h"
#import "QCOnlineStatusManager.h"
#import "QCHistorySplitTipCell.h"
#import "QCHistorySplitTipContent.h"
#import "QCMergeForwardContent.h"
#import "QCMergeForwardCell.h"
#import "QCScreenshotCell.h"
#import "QCScreenshotContent.h"
#import "QCConversationAddItem.h"
#import "QCConversationContext.h"
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import "QCScreenPasswordVC.h"
#import "QCScreenProtectionView.h"
#import "QCMySettingManager.h"
#import "QCConversationPosition.h"
#import "QCWebClientInfoVC.h"
#import "QCLottieStickerCell.h"
#import "QCLottieStickerContent.h"
#import <SDWebImageLottieCoder/SDWebImageLottieCoder.h>
#import "QCEndToEndEncryptHitContent.h"
#import "QCEndToEndEncryptHitCell.h"
#import "QCSignalErrorCell.h"
#import <QCIM/QCSignalErrorContent.h>
#import "QCEmojiStickerCell.h"
#import "QCEmojiStickerContent.h"
#import "QCSDImageLottieCoder.h"
#import "QCSecurityTipManager.h"
#import "QCConversationListVM.h"
#import <QCCore/QCCore-Swift.h>
#import "QCStickerCollectionVC.h"
#import "QCKeyboardService.h"
#import <ZLPhotoBrowser/ZLPhotoBrowser-Swift.h>
#import "QCSDWebImageDownloaderOperation.h"
#import <Bugly/Bugly.h>
#import "QCProhibitwordsService.h"
#import "QXTelemetry.h"

@import FPSCounter.Swift;
//#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
//#import <PINRemoteImage/PINRemoteImageCaching.h>
typedef void(^QCOnComplete)(id data,NSError *error);



@interface QCApp ()<QCNetworkListenerDelegate,QCConnectionManagerDelegate>

/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

@property(nonatomic,strong) NSMutableArray<NSString*> *allowForwards; // 允许转发的消息类型集合
@property(nonatomic,strong) NSMutableArray<NSString*> *allowCopys; // 允许复制的消息类型集合
@property(nonatomic,strong) NSMutableArray<NSString*> *allowFavorites; // 允许收藏的消息类型集合

@property(nonatomic,assign) BOOL isShowLockScreenProtect; // 是否显示了锁屏密码
@property(nonatomic,assign) BOOL isShowScreenProtect; // 是否显示屏幕保护
@property(nonatomic,strong) QCScreenProtectionView *screenProtectionView; // 屏幕保护view



@end

@implementation QCApp

static QCApp *_instance;


+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCApp *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
    });
    return _instance;
}

- (QCAppConfig *)config {
    if(!_config) {
        _config = [[QCAppConfig alloc] init];
    }
    return _config;
}

- (QCAppRemoteConfig *)remoteConfig {
    if(!_remoteConfig) {
        _remoteConfig = [[QCAppRemoteConfig alloc] init];
    }
    if(!_remoteConfig.requestSuccess || !_remoteConfig.requestAppModuleSuccess) {
        [_remoteConfig requestConfig:nil];
    }
    return _remoteConfig;
}

-(void) addNotifies {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    // 录屏
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenCapturedDidChange) name:UIScreenCapturedDidChangeNotification object:nil];
        
    }
    
}

- (void)dealloc { // 这里虽然不会执行，还是写上
    [[QCSDK shared].connectionManager removeDelegate:self];
    [[QCNetworkListener shared] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenCapturedDidChangeNotification object:nil];
    }
}

-(void) appDidReceiveMemoryWarning {
    QCLogWarn(@"内存警告------->");
    // 清空图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
}

-(void) configSDWebImage {
    
    // webp格式支持
    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webPCoder];
    
    // lottie支持
    [[SDImageCodersManager sharedManager] addCoder:QCSDImageLottieCoder.sharedCoder];
    
    [SDImageCacheConfig defaultCacheConfig].maxMemoryCost = 80 * 1024 * 1024; // 80M
    
    SDWebImageDownloader.sharedDownloader.config.operationClass = QCSDWebImageDownloaderOperation.class;
    
}

-(void) registerMessages {
    // 注册消息
    [self.messageRegitry registerCellClass:[QCTextMessageCell class] forMessageContentClass:[QCTextContent class]]; // 文本
    [self.messageRegitry registerCellClass:[QCUnkownMessageCell class] forMessageContentClass:[QCUnknownContent class]]; // 未知消息
    [self.messageRegitry registerCellClass:[QCImageMessageCell class] forMessageContentClass:[QCImageContent class]]; // 图片消息
    [self.messageRegitry registerCellClass:[QCVoiceMessageCell class] forMessageContentClass:[QCVoiceContent class]]; // 语音消息
//    [self.messageRegitry registerCellClass:[QCSystemMessageCell class] forMessageContentClass:[QCSystemContent class]]; // 系统消息
    [self.messageRegitry registerCellClass:[QCGIFMessageCell class] forMessageContentClass:[QCGIFContent class]]; // GIF消息
    [self.messageRegitry registerCellClass:[QCCardCell class] forMessageContentClass:[QCCardContent class]]; // 名片消息
     [self.messageRegitry registerCellClass:[QCTypingMessageCell class] forMessageContentClass:[QCTypingContent class]]; // 输入中...
    [self.messageRegitry registerCellClass:QCMergeForwardCell.class forMessageContentClass:QCMergeForwardContent.class];
    // 历史消息分割线
    [self.messageRegitry registerCellClass:[QCHistorySplitTipCell class] forMessageContentClass:[QCHistorySplitTipContent class]];
    [self.messageRegitry registerCellClass:[QCEndToEndEncryptHitCell class] forMessageContentClass:[QCEndToEndEncryptHitContent class]]; // 端对端加密提示
    [self.messageRegitry registerCellClass:[QCSignalErrorCell class] forMessageContentClass:[QCSignalErrorContent class]]; // 解密失败
    [self.messageRegitry registerCellClass:QCScreenshotCell.class forMessageContentClass:QCScreenshotContent.class]; // 截屏通知
    [self.messageRegitry registerCellClass:QCLottieStickerCell.class forMessageContentClass:QCLottieStickerContent.class]; // lottie格式的贴图
    [self.messageRegitry registerCellClass:QCEmojiStickerCell.class forMessageContentClass:QCEmojiStickerContent.class];
}

-(void) traceConfig {
    BuglyConfig *config = [[BuglyConfig alloc] init];
#ifndef __OPTIMIZE__ // DEBUG模式
    config.debugMode = false;
    config.blockMonitorEnable = false;
    config.reportLogLevel = BuglyLogLevelDebug;
#else
    config.reportLogLevel = BuglyLogLevelWarn;
#endif
    
    [Bugly startWithAppId:@"82f8dd98ff" config:config];
    if([QCApp shared].isLogined) {
        [Bugly setUserIdentifier: [QCApp shared].loginInfo.uid];
    }
}

-(void) debugSetting {
#ifndef __OPTIMIZE__ // DEBUG模式
    [FPSCounter showInStatusBarWithApplication:[UIApplication sharedApplication] runloop:NSRunLoop.mainRunLoop mode:NSRunLoopCommonModes];
#else
    
#endif
}

-(BOOL) appOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[QCSwiftModuleManager shared] didOpen:url options:options];
}

-(BOOL) appContinueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    return [[QCSwiftModuleManager shared] didContinue:userActivity restorationHandler:restorationHandler];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [QCSwiftModuleManager.shared moduleDidReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    
    
}

-(void) appInit {
    
    // 配置api
    [self configApi];
    
    if([self.config.langue isEqualToString:@"zh-Hans"]) {
        [ZLPhotoUIConfiguration default].languageType = ZLLanguageTypeChineseSimplified;
    }else{
        [ZLPhotoUIConfiguration default].languageType = ZLLanguageTypeEnglish;
    }
    
    [QCKeyboardService.shared setup];
    [QCSwiftModuleManager.shared didModuleInit];
//    [QCModuleManager.shared didModuleInit]; // 模块初始化
    
//    [self debugSetting];
    
    [self traceConfig];
  
    [self configSDWebImage];

    [self addNotifies];
    
   
    [[QCNetworkListener shared] addDelegate:self];
    // 开启网络监听
    [[QCNetworkListener shared] start];
    // 初始化日志
    [QCLogsManager setup:nil];
    
    // 加载登录信息
    [[QCApp shared].loginInfo load];
    
    
    // 开始处理系统消息
    [[QCSystemMessageHandler shared] handle];
    
    // 初始化系统的point
    [self initPointMethods];
    // 注册自定义消息
    [self registerMessages];
    
    // 配置IM SDK
    [QCSDK shared].connectURL =self.config.connectURL;
    
    QCSDK.shared.options.syncChannelMessageLimit = [QCApp shared].config.eachPageMsgLimit;
    
    // 设置IM连接信息回调（当IM需要取连接信息时会调用此方法）
    __weak typeof(self) weakSelf = self;
    [[QCSDK shared].options setConnectInfoCallback:^QCConnectInfo * _Nonnull{
        QCConnectInfo *connectInfo = [QCConnectInfo new];
        connectInfo.uid = weakSelf.loginInfo.uid;
        connectInfo.token = weakSelf.loginInfo.imToken;
        return  connectInfo;
    }];

    [[QCSDK shared].connectionManager addDelegate:self];
    // 设置连接地址
    if([QCApp shared].config.clusterOn) {
       [[QCSDK shared].connectionManager setGetConnectAddr:^(void (^ _Nonnull complete)(NSString * __nullable)) {
           [[QCAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%@/im",weakSelf.loginInfo.uid] parameters:nil].then(^(NSDictionary *addrDict){
               if(addrDict && addrDict[@"tcp_addr"]) {
                    complete(addrDict[@"tcp_addr"]);
               }else{
                   complete(nil);
               }
              
           }).catch(^(NSError *error){
               complete(nil);
               QCLogError(@"获取IM连接地址失败！-> %@",error);
           });
       }];
    }
   
    // 设置登录成功回调
    [self setMethod:QCPOINT_LOGIN_SUCCESS handler:^id _Nullable(id  _Nonnull param) {
        [[QXTelemetry sharedTelemetry] recordName:@"account.login.success"
                                         category:@"account"
                                         severity:QXTelemetrySeverityInfo];
        // 切换数据库
        [[QCKitDB shared] switchDB:[QCApp shared].loginInfo.uid];
        
        // 重新加载最近会话保持的位置
        [[QCConversationPositionManager shared] reload];
        
        // 显示首页
        if(weakSelf.getHomeViewController) {
            [[QCNavigationManager shared] resetRootViewController:weakSelf.getHomeViewController()];
        }
        // 同步联系人
        [[QCSyncService shared] sync:^(NSError * _Nonnull error) {
            // 更新频道在线状态，如果需要
            [QCOnlineStatusManager shared].needUpdate = YES;
            [[QCOnlineStatusManager shared] requestUpdateChannelOnlineStatusIfNeed];
            // 连接到IM
            [[[QCSDK shared] connectionManager] connect];
        }];
        // 注册远程通知
       [weakSelf registerForNotification];
        
        // 调用登录成功的委托
        [weakSelf callAppLoginSuccessDelegate];
        
        // 同步安全提醒敏感词
        [[QCSecurityTipManager shared] syncIfNeed];
        
        [weakSelf enterApp];
        
        return nil;
    }];
    
    
    // 设置登出回调
    [[QCApp shared] setMethod:QCPOINT_LOGIN_LOGOUT handler:^id _Nullable(id  _Nonnull param) {
        [[QXTelemetry sharedTelemetry] recordName:@"account.logout"
                                         category:@"account"
                                         severity:QXTelemetrySeverityInfo];
        // 断开IM连接
        [[QCSDK shared].connectionManager logout];
        // 显示登录页面
        [[QCApp shared] invoke:QCPOINT_LOGIN_SHOW param:nil];
        
        weakSelf.isShowScreenProtect = false;
        weakSelf.isShowLockScreenProtect = false;
        
        // 调用登出的委托
        [self callAppLogoutDelegate];
        return nil;
    }];
    
    if([QCApp shared].isLogined) {
        // 切换数据库
        [[QCKitDB shared] switchDB:[QCApp shared].loginInfo.uid];
        if(weakSelf.getHomeViewController) {
            [[QCNavigationManager shared] resetRootViewController:weakSelf.getHomeViewController()];
        }
//        // 同步联系人
        [[QCSyncService shared] sync];
        
        [self enterApp];
    }else {
        [[QCApp shared] invoke:QCPOINT_LOGIN_SHOW param:nil];
    }
    
    // 模块启动...
    [[QCSwiftModuleManager shared] didFinishLaunching];
    QCLogDebug(@"=====> 程序启动！<=====");
    
    // 如果已登录 则连接IM
    if([QCApp shared].isLogined){
        // 注册远程通知
        [self registerForNotification];
        [[[QCSDK shared] connectionManager] connect];
        
        // 同步安全提醒敏感词
        [[QCSecurityTipManager shared] syncIfNeed];
        
    }
    if(![AFNetworkReachabilityManager sharedManager].reachable) {
        [self showScreenProtectIfNeed]; // 显示断网屏幕保护
    }
   
    [self showLockScreenProtectIfNeed];
    
    [self remoteConfig]; // 获取下远程配置
    
    // 收藏的表情加载
    [self loadCollectStickersIfNeed];
    
    // 图片换成key设置
//    [[SDWebImageManager sharedManager] setCacheKeyFilter:[[SDWebImageCacheKeyFilter alloc] initWithBlock:^NSString * _Nullable(NSURL * _Nonnull url) {
//        return [url absoluteString];
//    }]];
}

// 进入app
-(void) enterApp {
    [QCAPIClient.sharedClient GET:[NSString stringWithFormat:@"user/devices/%@",[UIDevice getUUID]] parameters:nil].then(^(NSDictionary *result){
        NSLog(@"result---->%@",result);
        if(result && result[@"id"]) {
            [QCSDK.shared.options setClientMsgDeviceId: [result[@"id"] integerValue]];
        }
    });
    // 冷启动 / 登录成功进入 APP 时兜底检查一次封禁状态
    // 延迟 2s，等首页和导航控制器准备好，避免在 LaunchScreen 期间弹窗
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkBanStatusAndHandle];
    });
}

// 上一次的 IM 连接状态，用于检测 断开→连接成功 的边沿，触发封禁状态兜底检查
static QCConnectStatus _wkLastConnectStatus = QCDisconnected;

-(void) checkBanStatusAndHandle {
    if(![self isLogined]) return;
    if(self.banDialogShowing) return;
    NSString *deviceID = [UIDevice getUUID] ?: @"";
    NSDictionary *params = deviceID.length > 0 ? @{@"device_id": deviceID} : @{};
    [[QCAPIClient sharedClient] GET:@"user/checkstatus" parameters:params].then(^(NSDictionary *result) {
        if(!result) return;
        if(![result[@"banned"] boolValue]) return;
        if(self.banDialogShowing) return;
        self.banDialogShowing = YES;
        NSString *reason = result[@"reason"] ?: @"您的账号已被管理员封禁";
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:LLang(@"账号已下线")
                                                                          message:reason
                                                                   preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:LLang(@"我知道了")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [[QCApp shared] immediatelyLogout];
            }]];
            UIViewController *top = [QCNavigationManager shared].topViewController;
            if(top) {
                [top presentViewController:alert animated:YES completion:nil];
            } else {
                // 拿不到顶层 VC，直接退出兜底
                [[QCApp shared] immediatelyLogout];
            }
        });
    }).catch(^(NSError *error){
        // 静默：失败不影响业务，下次前台切换时会再次检查
        QCLogWarn(@"checkBanStatus 失败: %@", error.domain);
    });
}

- (void)registerForNotification {
    UIUserNotificationType types =
    (UIUserNotificationTypeAlert | UIUserNotificationTypeSound |
     UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    if (@available(iOS 11.0, *)) {
        UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge |
                                                 UNAuthorizationOptionSound |
                                                 UNAuthorizationOptionAlert)
                              completionHandler:^(BOOL granted,
                                                  NSError *_Nullable error) {
                                  if (!granted) {
                                      //                [[UIApplication
                                      //                sharedApplication].keyWindow
                                      //                makeToast:@"请开启推送功能否则无法收到推送通知"
                                      //                duration:0.5
                                      //                position:CSToastPositionCenter];
                                  }
                              }];
    } else if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 10) {
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center =
            [UNUserNotificationCenter currentNotificationCenter];
            [center requestAuthorizationWithOptions:UNAuthorizationOptionCarPlay |
            UNAuthorizationOptionSound |
            UNAuthorizationOptionBadge |
            UNAuthorizationOptionAlert
                                 completionHandler:^(BOOL granted,
                                                     NSError *_Nullable error) {
                                     if (granted) {
                                         QCLogDebug(@" iOS 10 request notification success");
                                     } else {
                                         QCLogDebug(@" iOS 10 request notification fail");
                                     }
                                 }];
        } else {
            // Fallback on earlier versions
        }
        
    } else if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 7.99) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:UIUserNotificationTypeSound |
                                                UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeAlert
                                                categories:nil];
        [[UIApplication sharedApplication]
         registerUserNotificationSettings:settings];
        //        UIUserNotificationSettings* notificationSettings =
        //        [UIUserNotificationSettings
        //        settingsForTypes:UIUserNotificationTypeAlert |
        //        UIUserNotificationTypeBadge | UIUserNotificationTypeSound
        //        categories:nil];
        //        [[UIApplication sharedApplication]
        //        registerUserNotificationSettings:notificationSettings];
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:UIUserNotificationTypeSound |
                                                UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeAlert
                                                categories:nil];
        [[UIApplication sharedApplication]
         registerUserNotificationSettings:settings];
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}


// api 配置
-(void) configApi{
    QCAPIClientConfig *config = [[QCAPIClientConfig alloc] init];
    [config setBaseUrl:self.config.apiBaseUrl];
    // http公用头部
    [config setPublicHeaderBLock:^NSDictionary *{
        NSMutableDictionary *header = [NSMutableDictionary dictionary];
        [header setObject:[self config].bundleID forKey:@"bundle_id"];
        if([QCApp shared].isLogined) {
            [header setObject:[QCApp shared].loginInfo.token forKey:@"token"];
            return header;
        }
        return  header;
        
    }];
    // 路径替换
    [config setRequestPathReplace:^NSString *(NSString *requestPath) {
        if([QCApp shared].isLogined) {
            return [requestPath stringByReplacingOccurrencesOfString:@"{uid}" withString:[QCApp shared].loginInfo.uid];
        }
        return requestPath;
        
    }];
    // 统一错误处理
    [config setErrorHandler:^NSError *(id respObj, NSError *error) {
        if(error) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            if(response && response.statusCode == 401 && [QCApp shared].isLogined) { // 401表示token失效，跳转到登录页面
                QCLogWarn(@"401token失效，跳转到登录页面");
                [[QCApp shared] immediatelyLogout];

            }else {
                NSData *errorData =  error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                if(errorData) {
                    QCLogError(@"error->%@",[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]);
                }
                
                if(response.statusCode == 400) {
                    if(errorData) {
                        NSDictionary *errorDic = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingMutableLeaves error:nil];
                        if(errorDic) {
                            return [NSError errorWithDomain:errorDic[@"msg"] code:[errorDic[@"status"] integerValue] userInfo:errorDic];
                        }
                    }else {
                        return [NSError errorWithDomain:error.localizedDescription code:error.code userInfo:error.userInfo];
                    }
                }else {
                    return [NSError errorWithDomain:[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding] code:error.code userInfo:error.userInfo];
                }
                
            }
        }
        return nil;
    }];
    [[QCAPIClient sharedClient] setConfig:config];
    
}

- (QCEndpointManager *)endpointManager {
    if(!_endpointManager) {
        _endpointManager = [QCEndpointManager new];
    }
    return _endpointManager;
}

- (SDImageCache *)imageCache {
    if(!_imageCache) {
        SDImageCacheConfig *config = SDImageCacheConfig.defaultCacheConfig;
        
        _imageCache = [[SDImageCache alloc] initWithNamespace:@"" diskCacheDirectory:self.config.imageCacheDir config:config];
    }
    return _imageCache;
}

/**
 是否已登录

 @return <#return value description#>
 */
-(BOOL) isLogined {

    return [QCLoginInfo shared].token && ![[QCLoginInfo shared].token isEqualToString:@""];
}

-(void) logout {
    [[QCAPIClient sharedClient] DELETE:@"user/device_token" parameters:nil].then(^{
        [self immediatelyLogout];
    }).catch(^(NSError *error){
        QCLogError(@"注销设备token失败！-> %@",error);
        // 退出登录
        [self immediatelyLogout];
    });
   
}

-(void) immediatelyLogout {
    // 退出登录时清空封禁弹窗标志，允许重新登录后再次进入兜底链路
    self.banDialogShowing = NO;
    _wkLastConnectStatus = QCDisconnected;
    // 清楚登录信息
    [[QCLoginInfo shared] clearMainData];
    // 调用登出
    [self invoke:QCPOINT_LOGIN_LOGOUT param:nil];
}

static  UIBackgroundTaskIdentifier _bgTaskToken;

- (void)appDidEnterBackground:(NSNotification *)notification   {
    UIApplication *application = (UIApplication*)notification.object;
    if([QCApp shared].isLogined) {
        NSInteger unreadCount = [[QCConversationListVM shared] getAllUnreadCount];
           [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
           [[QCAPIClient sharedClient] POST:@"user/device_badge" parameters:@{@"badge":@(unreadCount)}].catch(^(NSError *error){
               QCLogError(@"上传红点数量失败！-> %@",error);
           });
    }else {
          [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }

    // 申请后台任务，给 IM SDK 一段宽限时间把红点上报、断开 socket 等收尾操作做完。
    // 系统在临近过期时调用 expirationHandler，这时仍可继续短暂跑代码。
    _bgTaskToken = [application beginBackgroundTaskWithExpirationHandler:^{
        if(_bgTaskToken != UIBackgroundTaskInvalid) {
            [application endBackgroundTask:_bgTaskToken];
            _bgTaskToken = UIBackgroundTaskInvalid;
        }
    }];

    // 进入后台时立即主动断开 IM 长连接：
    // 1) 让 IM 服务器尽快把本设备标记为离线，从下一条消息起走 APNs 离线推送 webhook，
    //    避免“消息直推 socket 但 socket 已被系统冻结”导致的消息黑洞；
    // 2) 不依赖系统在 expirationHandler 里再去执行 disconnect —— 那时进程随时可能被 suspend，
    //    TCP FIN 不一定能成功送到，长时间挂机后客户端就一直收不到推送。
    if([QCApp shared].isLogined) {
        [[[QCSDK shared] connectionManager] disconnect:YES];
    }

    [QCApp shared].loginInfo.extra[@"enter_background_time"] = @([[NSDate date] timeIntervalSince1970]);
    
//
//    self.myTimer =[NSTimer scheduledTimerWithTimeInterval:1.0f
//                            target:self
//                           selector:@selector(timerMethod:)     userInfo:nil
//                           repeats:YES];
}



-(void) appWillEnterForeground:(NSNotification*) notification {
    QCLogDebug(@"appWillEnterForeground--->");
    [self showLockScreenProtectIfNeed];
    
    [self showScreenProtectIfNeed];
    // 从后台回到前台时兜底检查封禁状态（防止后台时漏收 forceLogout CMD）
    [self checkBanStatusAndHandle];
}

-(void) appWillResignActive:(NSNotification*) notification  {
    QCLogDebug(@"appWillResignActive---->");
}

-(void) appWillTerminate:(NSNotification*)notification {
    QCLogDebug(@"appWillTerminate---------------------------->");
}

- (void)appDidBecomeActive:(NSNotification *)notification  {
    QCLogDebug(@"appDidBecomeActive--->");
    UIApplication *application = (UIApplication*)notification.object;
    if(_bgTaskToken) {
        [application endBackgroundTask:_bgTaskToken];
        _bgTaskToken = UIBackgroundTaskInvalid;
    }
    if([self isLogined]) {
        // 更新频道在线状态，如果需要
        [[QCOnlineStatusManager shared] requestUpdateChannelOnlineStatusIfNeed];
    }
    // 连接
    if([[QCSDK shared] connectionManager].connectStatus == QCDisconnected  && [QCApp shared].isLogined) {
        [[[QCSDK shared] connectionManager] connect];
    }
    
    if([QCApp shared].config.darkModeWithSystem) {
        if (@available(iOS 13.0, *)) {
            // 延迟一点执行模式切换（TODO: 延迟为了解决有时候UI界面模式没有切换成功的问题）
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    [QCApp shared].config.style = QCSystemStyleDark;
                }else{
                    [QCApp shared].config.style = QCSystemStyleLight;
                }
            });
        }
    }else{
        [QCApp shared].config.style =  [QCApp shared].config.style; // 这里重新设置下 触发setStyle方法里的逻辑
    }
}

// 录屏
-(void) screenCapturedDidChange {
    if (@available(iOS 11.0, *)) {
        if([QCMySettingManager shared].offlineProtection) {
            [self showScreenProtect:[UIScreen mainScreen].isCaptured];
        }
    }
}


-(QCLoginInfo*) loginInfo {
    
    return [QCLoginInfo shared];
}

- (QCMessageRegistry *)messageRegitry {
    return [QCMessageRegistry shared];
}

-(void) registerEndpoint:(QCEndpoint*)endpoint {
    [self.endpointManager registerEndpoint:endpoint];
}

-(void) unregisterEndpointWithCategory:(NSString*)category {
    [self.endpointManager unregisterEndpointWithCategory:category];
}

-(QCEndpoint*) getEndpoint:(NSString*)sid {
    return [self.endpointManager getEndpointWithSid:sid];
}

-(id) invoke:(NSString*)endpointSID param:(id)param{
   QCEndpoint *endpoint = [self.endpointManager getEndpointWithSid:endpointSID];
    if(endpoint) {
       return  endpoint.handler(param);
    }
    return nil;
}

-(NSArray*) invokes:(NSString*)category param:(id)param{
    NSArray<QCEndpoint*> *endpoints = [self.endpointManager getEndpointsWithCategory:category];
    if(endpoints) {
        NSMutableArray *items = [NSMutableArray array];
        for (QCEndpoint *endpoint in endpoints) {
            id obj = endpoint.handler(param);
            if(obj) {
                [items addObject:obj];
            }
            
        }
        return items;
    }
    return nil;
}

-(NSArray<QCEndpoint*>*) getEndpointsWithCategory:(NSString*)category {
    return  [self.endpointManager getEndpointsWithCategory:category];
}

-(void) setMethod:(NSString*)sid handler:(QCHandler) handler{
    [self setMethod:sid handler:handler category:nil];
}

-(BOOL) hasMethod:(NSString*)sid {
    return  [self.endpointManager getEndpointWithSid:sid]!=nil;
}

-(void) setMethod:(NSString*)sid handler:(QCHandler) handler category:(NSString*)category{
    [self registerEndpoint:[QCEndpoint initWithSid:sid handler:handler category:category]];
}
-(void) setMethod:(NSString*)sid handler:(QCHandler) handler category:(NSString* __nullable)category sort:(int)sort {
     [self registerEndpoint:[QCEndpoint initWithSid:sid handler:handler category:category sort:@(sort)]];
}

-(void) registerCellClass:(Class)cellClass forMessageContntClass:(Class)messageContentClass {
    [[QCMessageRegistry shared] registerCellClass:cellClass forMessageContentClass:messageContentClass];
}
-(void) registerCellClass:(Class)cellClass contentType:(NSInteger)contentType {
    [[QCMessageRegistry shared] registerCellClass:cellClass forContentType:contentType];
}

-(Class) getMessageCell:(NSInteger)contentType {
    return [[QCMessageRegistry shared] getMessageCell:contentType];
}

-(UIImage*) loadImage:(NSString*)name moduleID:(NSString*)moduleID{
   return  [[[QCSwiftModuleManager shared] getModuleWithId:moduleID] ImageForResource:name];
}

-(NSBundle*) resourceBundle:(NSString*)moduleID {
    return [[[QCSwiftModuleManager shared] getModuleWithId:moduleID] resourceBundle];
}

-(NSBundle*) resourceBundleWithClass:(Class)cls {
    NSBundle *bundle = [NSBundle bundleForClass:cls];
    NSString *moduleName = bundle.infoDictionary[@"CFBundleExecutable"];
    return [self resourceBundle:moduleName];
}

-(NSURL*) getImageFullUrl:(NSString*)path{
    NSString *encodePath = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    if(encodePath) {
        if([encodePath hasPrefix:@"http"]) {
            return [NSURL URLWithString:path];
        }else {
            NSString *newPath = [encodePath copy];
            if([newPath hasPrefix:@"/"]) {
                newPath = [newPath substringFromIndex:1];
            }
            NSString *urlStr =[NSString stringWithFormat:@"%@%@",[QCApp shared].config.imageBrowseUrl,newPath];
          
            return [NSURL URLWithString:urlStr];
        }
    }
    return nil;
}
-(NSURL*) getFileFullUrl:(NSString*)path{
    if([path hasPrefix:@"http"]) {
        return [NSURL URLWithString:path];
    }
    NSString *encodePath = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    if(encodePath) {
        NSString *newPath = [encodePath copy];
        if([newPath hasPrefix:@"/"]) {
            newPath = [newPath substringFromIndex:1];
        }
        NSString *urlStr =[NSString stringWithFormat:@"%@%@",[QCApp shared].config.fileBrowseUrl,newPath];
        return [NSURL URLWithString:urlStr];
    }
    return nil;
}

-(void) addMessageAllowForward:(NSInteger)contentType {
    [self.allowForwards addObject:[NSString stringWithFormat:@"%ld",(long)contentType]];
}

- (void)addMessageAllowCopy:(NSInteger)contentType {
    [self.allowCopys addObject:[NSString stringWithFormat:@"%ld",(long)contentType]];
}

- (void)addMessageAllowFavorite:(NSInteger)contentType {
    [self.allowFavorites addObject:[NSString stringWithFormat:@"%ld",(long)contentType]];
}

- (BOOL)allowMessageCopy:(NSInteger)contentType {
    return [self.allowCopys containsObject:[NSString stringWithFormat:@"%ld",(long)contentType]];
}

- (BOOL)allowMessageForward:(NSInteger)contentType {
    return [self.allowForwards containsObject:[NSString stringWithFormat:@"%ld",(long)contentType]];
}

- (BOOL)allowMessageFavorite:(NSInteger)contentType {
    return [self.allowFavorites containsObject:[NSString stringWithFormat:@"%ld",(long)contentType]];
}

- (NSMutableArray<NSString *> *)allowForwards {
    if(!_allowForwards) {
        _allowForwards = [NSMutableArray array];
    }
    return _allowForwards;
}

- (NSMutableArray<NSString *> *)allowCopys {
    if(!_allowCopys) {
        _allowCopys = [NSMutableArray array];
    }
    return _allowCopys;
}

- (NSMutableArray<NSString *> *)allowFavorites {
    if(!_allowFavorites) {
        _allowFavorites = [NSMutableArray array];
    }
    return _allowFavorites;
}


- (unsigned long long)calculateVideoCachedSizeWithError:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDirectory = [self.config videoCacheDir];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:cacheDirectory error:error];
    unsigned long long size = 0;
    if (files) {
        for (NSString *path in files) {
            NSString *filePath = [cacheDirectory stringByAppendingPathComponent:path];
            NSDictionary<NSFileAttributeKey, id> *attribute = [fileManager attributesOfItemAtPath:filePath error:error];
            if (!attribute) {
                size = -1;
                break;
            }
            
            size += [attribute fileSize];
        }
    }
    return size;
}

-(void) cleanVideoCache {
    NSString *cacheDirectory = [self.config videoCacheDir];
    [QCFileUtil removeFileOfPath:cacheDirectory];
    [QCFileUtil createDirectoryIfNotExist:cacheDirectory];
}


// 跳到聊天页面
-(void) pushConversation:(QCChannel*)channel {
   NSArray<QCEndpoint*> *endpoints = [self.endpointManager getEndpointsWithCategory:QCPOINT_CATEGORY_CONVERSATION_SHOW];
    if(endpoints && endpoints.count>0) {
        for (QCEndpoint *endpoint in endpoints) {
           id value = endpoint.handler(@{@"channel":channel});
            if(value && [value boolValue]) {
                break;
            }
        }
    }
}

// 初始化Point方法
-(void) initPointMethods {
    
    __weak typeof(self) weakSelf = self;
    
    [self setMethod:QCPOINT_SYNC_PROHIBITWORDS handler:^id _Nullable(id  _Nonnull param) {
        return QCProhibitwordsService.shared;
    } category:QCPOINT_CATEGORY_SYNC];
    
    // 显示聊天UI
    [self setMethod:QCPOINT_CONVERSATION_SHOW handler:^id _Nullable(id  _Nonnull param) {
         QCConversationVC *conversationVC =  [QCConversationVC new];
        conversationVC.channel = param;
        [[QCNavigationManager shared] pushViewController:conversationVC animated:YES];
        return nil;
    }];
    
    [self setMethod:QCPOINT_CONVERSATION_SHOW_DEFAULT handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = (QCChannel*)param[@"channel"];
        if(channel.channelType == WK_GROUP || channel.channelType == WK_PERSON) {
            QCConversationVC *conversationVC =  [QCConversationVC new];
           conversationVC.channel = channel;
           [[QCNavigationManager shared] pushViewController:conversationVC animated:YES];
            return @(true);
        }
        return @(false);
    } category:QCPOINT_CATEGORY_CONVERSATION_SHOW];
    
    // 联系人选择
    [self setMethod:QCPOINT_CONTACTS_SELECT handler:^id _Nullable(id  _Nonnull param) {
        QCContactsMode mode = QCContactsModeMulti;
        if(param[@"mode"]&&[param[@"mode"] isEqualToString:@"single"]) {
            mode = QCContactsModeSingle;
        }
        QCContactsSelectVC *vc = [QCContactsSelectVC new];
        NSString *title = param[@"title"];
        if(!title) {
            title = LLangW(@"联系人选择", weakSelf);
        }
        vc.mode = mode;
        vc.title = title;
        NSArray *selecteds = param[@"selecteds"];
        if(selecteds && selecteds.count>0) {
            vc.selecteds = [NSMutableArray arrayWithArray:selecteds];
        }
        vc.mentionAll = param[@"mention_all"];
        vc.onFinishedSelect = param[@"on_finished"];
        vc.disables = param[@"disables"];
        vc.data = param[@"data"];
        vc.hiddenUsers = param[@"hidden_users"];
        if(param[@"hidden_systemuser"]) {
            NSMutableArray *hiddenUsers = [NSMutableArray array];
            if(vc.hiddenUsers) {
                [hiddenUsers addObjectsFromArray:vc.hiddenUsers];
            }
            [hiddenUsers addObject:QCApp.shared.config.fileHelperUID];
            [hiddenUsers addObject:QCApp.shared.config.systemUID];
            
            vc.hiddenUsers = hiddenUsers;
            
        }
        if(param[@"on_cancel"]) {
            vc.onDealloc = param[@"on_cancel"];
        }
        if(!param[@"no_push"]) {
            [[QCNavigationManager shared] pushViewController:vc animated:YES];
        }
       
        return vc;
    }];
    
    // 开始聊天
    [self setMethod:QCPOINT_CONVERSATION_STARTCHAT handler:^id _Nullable(id  _Nonnull param) {
        QCOnComplete complete = param[@"on_complete"];
        [weakSelf invoke:QCPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*members){
            if(members.count==1) {
                if(complete) {
                     [[QCNavigationManager shared] popViewControllerAnimated:YES];
                     complete([[QCChannel alloc] initWith:members[0] channelType:WK_PERSON],nil);
                }else {
                     [[QCNavigationManager shared] popViewControllerAnimated:YES];
                    // 跳到聊天页面
                    [weakSelf pushConversation:[[QCChannel alloc] initWith:members[0] channelType:WK_PERSON]];
                }
                return;
            }
            
             UIView *topView = [QCNavigationManager shared].topViewController.view;
             [topView showHUD];
            [[QCGroupManager shared] createGroup:members object:nil complete:^(NSString *groupNo,NSError *error){
                 [topView hideHud];
                if(error) {
                    if(complete) {
                        complete(nil,error);
                    }else {
                         [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
                    }
                    return;
                }
                if(complete) {
                    complete([[QCChannel alloc] initWith:groupNo channelType:WK_GROUP],nil);
                    
                }else {
                    [[QCNavigationManager shared] popViewControllerAnimated:YES];
                    // 跳到聊天页面
                    [weakSelf pushConversation:[[QCChannel alloc] initWith:groupNo channelType:WK_GROUP]];
                }
               
            }];
        }}];
        return nil;
    }];
    // 扫一扫
    [self setMethod:QCPOINT_CONVERSATION_SCAN handler:^id _Nullable(id  _Nonnull param) {
        QCScanVC *scanVC = [QCScanVC new];
        [[QCNavigationManager shared] pushViewController:scanVC animated:YES];
        return nil;
    }];
    
    // 聊天页面设置
    [self setMethod:QCPOINT_CONVERSATION_SETTING handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        id<QCConversationContext> context = param[@"context"];
        if(channel.channelType == WK_GROUP) {
            QCConversationGroupSettingVC *vc = [QCConversationGroupSettingVC new];
            vc.channel = channel;
            vc.context = context;
            [[QCNavigationManager shared] pushViewController:vc animated:YES];
        } else {
            QCConversationPersonSettingVC *vc = [QCConversationPersonSettingVC new];
            vc.channel = channel;
            vc.context = context;
            [[QCNavigationManager shared] pushViewController:vc animated:YES];
        }
       
        return nil;
    }];
    
    // ---------- 消息面板相关 ----------
    
    // emoji面板
    [self setMethod:QCPOINT_PANEL_EMOJI handler:^id _Nullable(id  _Nonnull param) {
        id<QCConversationContext> context = param[@"context"];
        return [[QCEmojiPanel alloc] initWithContext:context];
    } category:QCPOINT_CATEGORY_PANEL];
    
    
    // emoji
    [self setMethod:QCPOINT_CATEGORY_PANELFUNCITEM_EMOJI handler:^id _Nullable(id  _Nonnull param) {
       
        QCPanelDefaultFuncItem *item = [[QCPanelEmojiFuncItem alloc] init];
        item.sort = 1000;
        return item;
    } category:QCPOINT_CATEGORY_PANELFUNCITEM];
    
    // voice
    [self setMethod:QCPOINT_CATEGORY_PANELFUNCITEM_VOICE handler:^id _Nullable(id  _Nonnull param) {
        QCPanelDefaultFuncItem *item = [[QCPanelVoiceFuncItem alloc] init];
        item.sort = 2000;
        return item;
    } category:QCPOINT_CATEGORY_PANELFUNCITEM];
    
    // image
    [self setMethod:QCPOINT_CATEGORY_PANELFUNCITEM_IMAGE handler:^id _Nullable(id  _Nonnull param) {
        QCPanelDefaultFuncItem *item = [[QCPanelImageFuncItem alloc] init];
        item.sort = 3000;
        return item;
    } category:QCPOINT_CATEGORY_PANELFUNCITEM];
    
    // @
    [self setMethod:QCPOINT_CATEGORY_PANELFUNCITEM_MENTION handler:^id _Nullable(id  _Nonnull param) {
        id<QCConversationContext> context = param[@"context"];
        if(context.channel.channelType != WK_GROUP) {
            return nil;
        }
        QCPanelDefaultFuncItem *item = [[QCPanelMentionFuncItem alloc] init];
        item.sort = 4000;
        item.channelType = WK_GROUP;
        return item;
    } category:QCPOINT_CATEGORY_PANELFUNCITEM];
    
    // card
    [self setMethod:QCPOINT_CATEGORY_PANELFUNCITEM_CARD handler:^id _Nullable(id  _Nonnull param) {
        QCPanelCardFuncItem *item = [[QCPanelCardFuncItem alloc] init];
        item.sort = 5000;
        return item;
    } category:QCPOINT_CATEGORY_PANELFUNCITEM];
    

    
    // more（已隐藏：聊天底部功能组右侧「更多」按钮不再显示）
//    [self setMethod:QCPOINT_CATEGORY_PANELFUNCITEM_MORE handler:^id _Nullable(id  _Nonnull param) {
//        return [[QCPanelMoreFuncItem alloc] init];
//    } category:QCPOINT_CATEGORY_PANELFUNCITEM];
    
    
    // emoji正文
    [self setMethod:QCPOINT_PANELCONTENT_EMOJI handler:^id _Nullable(id  _Nonnull param) {
        return [QCEmojiContentView new];
    } category:QCPOINT_CATEGORY_PANELCONTENT sort:4000];
   
    
//    // 面板正文 - gif热图
//    [self setMethod:QCPOINT_PANELCONTENT_HOT handler:^id _Nullable(id  _Nonnull param) {
//        QCStickerGIFContentView *gifContentView = [[QCStickerGIFContentView alloc] initWithKeyword:LLangW(@"热图", weakSelf)];
//        gifContentView.tabIcon = [weakSelf imageName:@"icon_face_emoji"];
//        return gifContentView;
//    } category:QCPOINT_CATEGORY_PANELCONTENT sort:3000];
//    
//    // 面板正文 - gif热图
//    [self setMethod:@"gif002" handler:^id _Nullable(id  _Nonnull param) {
//        QCStickerGIFContentView *gifContentView =[[QCStickerGIFContentView alloc] initWithKeyword:LLangW(@"卖萌",weakSelf)];
//        gifContentView.tabIcon = [weakSelf imageName:@"icon_face_emoji"];
//        return gifContentView;
//    } category:QCPOINT_CATEGORY_PANELCONTENT sort:2000];
//    
//    // 面板正文 - gif热图
//    [self setMethod:@"gif003" handler:^id _Nullable(id  _Nonnull param) {
//        QCStickerGIFContentView *gifContentView = [[QCStickerGIFContentView alloc] initWithKeyword:LLangW(@"搞笑", weakSelf)];
//        gifContentView.tabIcon = [weakSelf imageName:@"icon_face_emoji"];
//        return gifContentView;
//    } category:QCPOINT_CATEGORY_PANELCONTENT sort:1000];
    
    // 跳到表情收藏
    [self setMethod:QCPOINT_TO_STICKER_COLLECTION handler:^id _Nullable(id  _Nonnull param) {
        QCStickerCollectionVC *vc = [QCStickerCollectionVC new];
        [vc setDataArray:param[@"data"]];
        [[QCNavigationManager shared] pushViewController:vc animated:YES];
        return nil;
    }];
    
    
    // 更多面板
    [self setMethod:QCPOINT_PANEL_MORE handler:^id _Nullable(id  _Nonnull param) {
        id<QCConversationContext> context = param[@"context"];
        return [[QCMorePanel2 alloc] initWithContext:context];
    } category:QCPOINT_CATEGORY_PANEL];
    
    // 录音
    [self setMethod:QCPOINT_PANEL_VOICE handler:^id _Nullable(id  _Nonnull param) {
        id<QCConversationContext> context = param[@"context"];
        return [[QCVoicePanel alloc] initWithContext:context];
    } category:QCPOINT_CATEGORY_PANEL];
    
    
    // 输入框输入emoji或删除emoji的响应 （删除字符时 emoji是一次删除好几个字符）
    [self setMethod:QCPOINT_EMOJI_INPUT_TEXT_RESPOND handler:^id _Nullable(id  _Nonnull param) {
        return [QCEmojiInputChangeTextRespond new];
    } category:QCPOINT_CATEGORY_CONVERSATION_INPUT_TEXT_RESPOND];
    
    // ---------- 消息长按菜单 ----------
    //收藏表情
    [self setMethod:QCPOINT_LONGMENUS_ADDEMOJI handler:^id _Nullable(id  _Nonnull param) {
        QCMessageModel *message = param[@"message"];
        NSString *path;
        if(message.message.contentType == WK_GIF) {
            QCGIFContent *gifContent = (QCGIFContent*)message.content;
            path = gifContent.url;
        }else if(message.message.contentType == WK_LOTTIE_STICKER) {
            QCLottieStickerContent *content = (QCLottieStickerContent *)message.content;
            path = content.url;
        }
        if(!path) {
            return nil;
        }
        
        // 判断此表情是否已收藏
       NSArray<QCSticker*> *stickers = QCApp.shared.collectStickers;
        if(stickers && stickers.count>0) {
            for (QCSticker *sticker in stickers) {
                if([sticker.path isEqualToString:path]) {
                    return nil;
                }
            }
        }

        UIImage *icon = [GenerateImageUtils generateTintedImgWithImage:[weakSelf imageName:@"Conversation/ContextMenu/Favorites"] color:weakSelf.config.contextMenu.primaryColor backgroundColor:nil];
        return [QCMessageLongMenusItem initWithTitle:LLangW(@"添加表情", weakSelf) icon:icon onTap:^(id<QCConversationContext> context){
            [[QCMessageManager shared] collectExpressions:message];
        }];
        return nil;
    } category:QCPOINT_CATEGORY_MESSAGE_LONGMENUS sort:5000];
    
    // 回复
    [self setMethod:QCPOINT_LONGMENUS_REPLY handler:^id _Nullable(id  _Nonnull param) {
        QCMessageModel *message = param[@"message"];
        if(message.status != WK_MESSAGE_SUCCESS) {
            return nil;
        }
        if(message.messageId == 0) {
            return nil;
        }
        UIImage *icon = [GenerateImageUtils generateTintedImgWithImage:[weakSelf imageName:@"Conversation/ContextMenu/Reply"] color:weakSelf.config.contextMenu.primaryColor backgroundColor:nil];
        return [QCMessageLongMenusItem initWithTitle:LLangW(@"回复", weakSelf) icon:icon onTap:^(id<QCConversationContext> context){
            [context replyTo:message.message];
        }];
    } category:QCPOINT_CATEGORY_MESSAGE_LONGMENUS sort:4000];
    
    
    // 复制
    [[QCApp shared] addMessageAllowCopy:WK_TEXT];
    [self setMethod:QCPOINT_LONGMENUS_COPY handler:^id _Nullable(id  _Nonnull param) {
        QCMessageModel *message = param[@"message"];

        if(![[QCApp shared] allowMessageCopy:message.contentType]) {
            return nil;
        }
        UIImage *icon = [GenerateImageUtils generateTintedImgWithImage:[weakSelf imageName:@"Conversation/ContextMenu/Copy"] color:weakSelf.config.contextMenu.primaryColor backgroundColor:nil];
        return [QCMessageLongMenusItem initWithTitle:LLangW(@"复制", weakSelf) icon:icon onTap:^(id<QCConversationContext> context){
            QCTextContent *textConent =  (QCTextContent*)message.content;
            NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n"
                                                    options:0
                                                     error:nil];
            NSString *newContent=[regularExpretion stringByReplacingMatchesInString:textConent.content options:NSMatchingReportProgress range:NSMakeRange(0, textConent.content.length) withTemplate:@""];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = newContent;
            UIView *topView = [QCNavigationManager shared].topViewController.view;
            [topView showHUDWithHide:LLangW(@"已复制", weakSelf)];
        }];
    } category:QCPOINT_CATEGORY_MESSAGE_LONGMENUS sort:3000];
    
    // 撤回
    [self setMethod:QCPOINT_LONGMENUS_REVOKE handler:^id _Nullable(id  _Nonnull param) {
        QCMessageModel *message = param[@"message"];
        
        if(message.status != WK_MESSAGE_SUCCESS) {
            return nil;
        }
        if(message.messageId == 0) { // 本地消息
            return nil;
        }
        
        BOOL isManager = false;
        if(message.channel.channelType == WK_GROUP) {
            isManager = [[QCSDK shared].channelManager isManager:message.channel memberUID:[QCApp shared].loginInfo.uid];
        }
        if(!isManager) {
            if(![message isSend]) {
                return nil;
            }
            NSInteger revokeSecond = 2*60;
            if(QCApp.shared.remoteConfig.revokeSecond == -1) {
                revokeSecond = -1;
            } else if(QCApp.shared.remoteConfig.revokeSecond>0) {
                revokeSecond = QCApp.shared.remoteConfig.revokeSecond;
            }
            
            if(revokeSecond>0) {
                if(  [[NSDate date] timeIntervalSince1970] - message.timestamp > revokeSecond) { // 超过两分钟则不显示撤回
                    return nil;
                }
            }
        }
        UIImage *icon = [GenerateImageUtils generateTintedImgWithImage:[weakSelf imageName:@"Conversation/ContextMenu/Revoke"] color:weakSelf.config.contextMenu.primaryColor backgroundColor:nil];
        return [QCMessageLongMenusItem initWithTitle:LLangW(@"撤回", weakSelf) icon:icon onTap:^(id<QCConversationContext> context){
            [[QCMessageManager shared] revokeMessage:message complete:^(NSError * _Nonnull error) {
                if(error) {
                    [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
                }
            }];
        }];
    } category:QCPOINT_CATEGORY_MESSAGE_LONGMENUS sort:3000];
    
    // 转发
    [[QCApp shared] addMessageAllowForward:WK_TEXT];
    [[QCApp shared] addMessageAllowForward:WK_IMAGE];
    [[QCApp shared] addMessageAllowForward:WK_GIF];
    [self setMethod:QCPOINT_LONGMENUS_FORWARD handler:^id _Nullable(id  _Nonnull param) {
        QCMessageModel *message = param[@"message"];
        
        if(![[QCApp shared] allowMessageForward:message.contentType]) {
            return nil;
        }
        UIImage *icon = [GenerateImageUtils generateTintedImgWithImage:[weakSelf imageName:@"Conversation/ContextMenu/Forward"] color:weakSelf.config.contextMenu.primaryColor backgroundColor:nil];
        return [QCMessageLongMenusItem initWithTitle:LLangW(@"转发", weakSelf) icon:icon onTap:^(id<QCConversationContext> context){
            QCConversationListSelectVC *vc = [QCConversationListSelectVC new];
            vc.title = LLangW(@"选择一个聊天", weakSelf);
            vc.viewModel.multiple = YES;
            [vc setOnSelectChannels:^(NSArray<QCChannel *> * _Nonnull channels) {
                [[QCNavigationManager shared] popToViewControllerClass:QCConversationVC.class animated:YES];
                for (QCChannel *channel in channels) {
                    if([channel isEqual:context.channel]) {
                        [context forwardMessage:message.content];
                    }else{
                        [[QCSDK shared].chatManager forwardMessage:message.content channel:channel];
                    }
                }
                [[QCNavigationManager shared].topViewController.view showHUDWithHide:LLangW(@"发送成功",weakSelf)];
            }];
            [[QCNavigationManager shared] pushViewController:vc animated:YES];
        }];
    } category:QCPOINT_CATEGORY_MESSAGE_LONGMENUS sort:2900];
    
    
   
    
    // 删除
    [self setMethod:QCPOINT_LONGMENUS_DELETE handler:^id _Nullable(id  _Nonnull param) {
        QCMessageModel *message = param[@"message"];
        if([message isSend] &&  [[NSDate date] timeIntervalSince1970] - message.timestamp < 2*60) { // 显示撤回就不显示删除
            return nil;
        }
        UIImage *icon = [GenerateImageUtils generateTintedImgWithImage:[weakSelf imageName:@"Conversation/ContextMenu/Delete"] color:weakSelf.config.contextMenu.primaryColor backgroundColor:nil];
        return [QCMessageLongMenusItem initWithTitle:LLangW(@"删除",weakSelf) icon:icon onTap:^(id<QCConversationContext> context){
            [[QCMessageManager shared] deleteMessages:@[message]];
        }];
    } category:QCPOINT_CATEGORY_MESSAGE_LONGMENUS sort:990];

    
    // 多选
    [self setMethod:QCPOINT_LONGMENUS_MULTIPLE handler:^id _Nullable(id  _Nonnull param) {
        QCMessageModel *message = param[@"message"];
        UIImage *icon = [GenerateImageUtils generateTintedImgWithImage:[weakSelf imageName:@"Conversation/ContextMenu/Select"] color:weakSelf.config.contextMenu.primaryColor backgroundColor:nil];
        return [QCMessageLongMenusItem initWithTitle:LLangW(@"多选", weakSelf) icon:icon onTap:^(id<QCConversationContext> context){
            [context setMultipleOn:YES selectedMessage:message];
        }];
    } category:QCPOINT_CATEGORY_MESSAGE_LONGMENUS sort:980];
    
    
  
    // 个人资料
    [self setMethod:QCPOINT_USER_INFO handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
//        if([uid isEqualToString:[QCApp shared].loginInfo.uid]) {
//            [[QCNavigationManager shared] pushViewController:[QCMeInfoVC new] animated:YES];
//            return nil;
//        }
        QCUserInfoVC *vc = [QCUserInfoVC new];
        vc.uid = uid;
        vc.vercode = param[@"vercode"]?:@"";
        vc.fromChannel = param[@"channel"];
        [[QCNavigationManager shared] pushViewController:vc animated:YES];
        return nil;
    }];
    
    // ---------- 扫一扫  ----------
    
    // 扫码进群
    [self setMethod:QCPOINT_SCAN_HANDLER_JOIN_GROUP handler:^id _Nullable(id  _Nonnull param) {
        return [QCScanHandler handle:^BOOL(QCScanResult * _Nonnull result, void (^ _Nonnull reScanBlock)(void)) {
            if(![result.type isEqualToString:@"group"]) {
                return false;
            }
            QCConversationVC *vc = [QCConversationVC new];
            vc.channel = [[QCChannel alloc] initWith:result.data[@"group_no"]?:@"" channelType:WK_GROUP];
            [[QCNavigationManager shared] replacePushViewController:vc animated:YES];
            return true;
        }];
    } category:QCPOINT_CATEGORY_SCAN_HANDLER];
    
    // 扫码加好友(跳到用户信息界面)
    [self setMethod:QCPOINT_SCAN_HANDLER_ADD_FRIEND handler:^id _Nullable(id  _Nonnull param) {
        return [QCScanHandler handle:^BOOL(QCScanResult * _Nonnull result, void (^ _Nonnull reScanBlock)(void)) {
            if(![result.type isEqualToString:@"userInfo"]) {
                return false;
            }
            if([result.data[@"uid"] isEqualToString:[QCApp shared].loginInfo.uid]) {
                [[QCNavigationManager shared] replacePushViewController:[QCMeInfoVC new] animated:YES];
                return true;
            }
            QCUserInfoVC *vc = [QCUserInfoVC new];
            vc.uid = result.data[@"uid"]?:@"";
            vc.vercode = result.data[@"vercode"]?:@"";
            [[QCNavigationManager shared] replacePushViewController:vc animated:YES];
            return true;
        }];
    } category:QCPOINT_CATEGORY_SCAN_HANDLER];
    
    // webview
    [self setMethod:QCPOINT_SCAN_HANDLER_WEBVIEW handler:^id _Nullable(id  _Nonnull param) {
        return [QCScanHandler handle:^BOOL(QCScanResult * _Nonnull result, void (^ _Nonnull reScanBlock)(void)) {
            if(![result.type isEqualToString:@"webview"]) {
                return false;
            }
            QCWebViewVC *vc = [QCWebViewVC new];
            vc.url = [NSURL URLWithString:result.data[@"url"]];
            [[QCNavigationManager shared] replacePushViewController:vc animated:YES];
            return true;
        }];
    } category:QCPOINT_CATEGORY_SCAN_HANDLER];
    
    // ---------- 最近会话列表的+  ----------
    
    [self setMethod:QCPOINT_CONVERSATION_ADD_STARTCHAT handler:^id _Nullable(id  _Nonnull param) {
        return [QCConversationAddItem title:LLangW(@"发起群聊", weakSelf) icon:[weakSelf imageName:@"ConversationList/Popmenus/StartChat"] onClick:^{
            [[QCApp shared] invoke:QCPOINT_CONVERSATION_STARTCHAT param:nil];
        }];
    } category:QCPOINT_CATEGORY_CONVERSATION_ADD sort:9000];
    
    [self setMethod:QCPOINT_CONVERSATION_ADD_ADDFRIEND handler:^id _Nullable(id  _Nonnull param) {
        return [QCConversationAddItem title:LLangW(@"添加朋友", weakSelf) icon:[weakSelf imageName:@"ConversationList/Popmenus/FriendAdd"] onClick:^{
            [[QCApp shared] invoke:QCPOINT_CONVERSATION_ADDCONTACTS param:nil];
        }];
    } category:QCPOINT_CATEGORY_CONVERSATION_ADD sort:8000];
    
    [self setMethod:QCPOINT_CONVERSATION_ADD_SCAN handler:^id _Nullable(id  _Nonnull param) {
        return [QCConversationAddItem title:LLangW(@"扫一扫", weakSelf) icon:[weakSelf imageName:@"ConversationList/Popmenus/Scan"] onClick:^{
            [[QCApp shared] invoke:QCPOINT_CONVERSATION_SCAN param:nil];
        }];
    } category:QCPOINT_CATEGORY_CONVERSATION_ADD sort:7000];
    
    
    // ---------- 我的  ----------
    // PC端
    [self setMethod:QCPOINT_ME_WEB handler:^id _Nullable(id  _Nonnull param) {
        // 隐藏「我的-网页端」入口（如需放开请删除下面这行 return nil）
        return nil;
        return [QCMeItem initWithTitle:LLangW(@"网页端",weakSelf) icon:[weakSelf imageName:@"Me/Index/IconPC"] nextSectionHeight:10.0f onClick:^{
            [[QCNavigationManager shared] pushViewController:[QCWebClientInfoVC new] animated:YES];
        }];
    } category:QCPOINT_CATEGORY_ME sort:18000];
    // 新消息通知
    [self setMethod:QCPOINT_ME_NEWMSGNOTICE handler:^id _Nullable(id  _Nonnull param) {
        return [QCMeItem initWithTitle:LLangW(@"新消息通知",weakSelf) icon:[weakSelf imageName:@"Me/Index/IconNotify"] onClick:^{
             [[QCNavigationManager shared] pushViewController:[QCMePushSettingVC new] animated:YES];
        }];
    } category:QCPOINT_CATEGORY_ME sort:8000];
    
    // 通用
    [self setMethod:QCPOINT_ME_COMMON handler:^id _Nullable(id  _Nonnull param) {
        return [QCMeItem initWithTitle:LLangW(@"通用",weakSelf) icon:[weakSelf imageName:@"Me/Index/IconSetting"] onClick:^{
             [[QCNavigationManager shared] pushViewController:[QCCommonSettingVC new] animated:YES];
        }];
    } category:QCPOINT_CATEGORY_ME sort:6000];
   
    
    // 截屏通知
    [[QCSDK shared].chatManager addMessageStoreBeforeIntercept:@"screent" intercept:^BOOL(QCMessage * _Nonnull message) {
        if(message.contentType == WK_SCREENSHOT) {
           QCChannelInfo *channelInfo =   [[QCSDK shared].channelManager getChannelInfo:message.channel];
            if(channelInfo) {
                if(![channelInfo settingForKey:QCChannelExtraKeyScreenshot defaultValue:YES]) {
                    return NO;
                }
            }
        }
        return YES;
    }];
   
}

#pragma mark - QCNetworkListenerDelegate

- (void)networkListenerStatusChange:(QCNetworkListener *)listener {
    if(![[QCApp shared] isLogined]) {
        return;
    }
    QCLogDebug(@"网络发生变化...");
    if(listener.hasNetwork) {
        [[QCSDK shared].connectionManager connect];
    }else {
        [[QCSDK shared].connectionManager disconnect:YES];
    }
}

#pragma mark -- QCConnectionManagerDelegate

- (void)onConnectStatus:(QCConnectStatus)status reasonCode:(QCReason)reasonCode{
    // socket 从「非连接」边沿切换到「已连接」时，兜底检查一次封禁状态。
    // 用于覆盖：APP 一直前台运行、网络抖动期间漏收 forceLogout CMD（CMD 是 NoPersist 一次性投递）。
    // 防止设备封禁 / IP 封禁场景下，服务端推 CMD 失败后客户端永远不知情。
    if(status == QCConnected && _wkLastConnectStatus != QCConnected && [self isLogined]) {
        // 延迟 1.5s：等首次同步会话 / 拉取离线消息的接口风暴过去，避免接口排队阻塞兜底请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkBanStatusAndHandle];
        });
    }
    _wkLastConnectStatus = status;

    if(![UIScreen mainScreen].isCaptured) {
        if(![QCApp shared].isLogined || ![QCMySettingManager shared].offlineProtection) {
            [self hiddenScreenProtect];
            return;
        }
    }
    
    if(status != QCConnected && reasonCode != WK_REASON_AUTHFAIL && reasonCode != WK_REASON_KICK) {
        [self performSelector:@selector(showScreenProtect) withObject:nil afterDelay:1.0f];
    }else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showScreenProtect) object:nil];
        if(![UIScreen mainScreen].isCaptured) {
            [self hiddenScreenProtect];
        }
        
    }
}


// 显示锁屏保护 如果需要
-(void) showLockScreenProtectIfNeed {
    if(! [[QCApp shared] isLogined]) {
        return;
    }
    NSNumber *lockAfterMinute =  [QCApp shared].loginInfo.extra[@"lock_after_minute"]?:@(0);
    NSString *lockScreenPwd = [QCApp shared].loginInfo.extra[@"lock_screen_pwd"];
    BOOL lockScreenOn = false;
    if(lockScreenPwd && ![lockScreenPwd isEqualToString:@""]) {
        lockScreenOn = true;
    }
    if(lockScreenOn) {
        if(lockAfterMinute.integerValue>0) {
           NSNumber *enterBgTime = [QCApp shared].loginInfo.extra[@"enter_background_time"];
            if(enterBgTime && [[NSDate date] timeIntervalSince1970] - enterBgTime.integerValue>lockAfterMinute.integerValue*60) {
                [self showLockScreenProtect];
            }
        }else{
            [self showLockScreenProtect];
        }
    }
    [QCApp shared].loginInfo.extra[@"enter_background_time"] = @(0);
}
-(void) showLockScreenProtect {
    if(self.isShowLockScreenProtect) {
        return;
    }
    self.isShowLockScreenProtect = true;
    QCScreenPasswordVC *vc = [QCScreenPasswordVC new];
    vc.modalPresentationStyle  = UIModalPresentationFullScreen;
    __weak typeof(vc) weakVC = vc;
    __weak typeof(self) weakSelf = self;
    vc.onFinished = ^(NSString * _Nonnull pwd) {
        weakSelf.isShowLockScreenProtect = false;
        [weakVC dismissViewControllerAnimated:YES completion:nil];
    };
    [[QCNavigationManager shared].topViewController presentViewController:vc animated:NO completion:nil];
}

// ---------- 断网屏幕保护 ----------

- (QCScreenProtectionView *)screenProtectionView {
    if(!_screenProtectionView) {
        _screenProtectionView = [[QCScreenProtectionView alloc] init];
    }
    return _screenProtectionView;
}


-(void) showScreenProtectIfNeed {

    BOOL showProtect = false;
    if([QCMySettingManager shared].offlineProtection) {
        if( [UIScreen mainScreen].isCaptured) {
            showProtect = true;
        }else if([QCSDK shared].connectionManager.connectStatus != QCConnected) {
            showProtect = true;
        }
    }
    
    if(showProtect) {
        [self showScreenProtect];
    }
}

- (UIWindow*) findWindow {
    if(QCKeyboardService.shared.keyboardIsVisible) {
        for (UIWindow *win in [UIApplication sharedApplication].windows) {
            if([win isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
                return win;
            }
        }
    }
    
    
    return [UIApplication sharedApplication].keyWindow;
}
//
//- (UIView *)findKeyboard
//{
//    UIView *keyboardView = nil;
//    NSArray *windows = [[UIApplication sharedApplication] windows];
//    for (UIWindow *window in [windows reverseObjectEnumerator])//逆序效率更高，因为键盘总在上方
//    {
//        keyboardView = [self findKeyboardInView:window];
//        if (keyboardView)
//        {
//            return keyboardView;
//        }
//    }
//    return nil;
//}
//
//- (UIView *)findKeyboardInView:(UIView *)view
//{
//    for (UIView *subView in [view subviews])
//    {
//        NSLog(@" 打印信息:%s",object_getClassName(subView));
//        if (strstr(object_getClassName(subView), "UIInputSetHostView"))
//        {
//            return subView;
//        }
//        else
//        {
//            UIView *tempView = [self findKeyboardInView:subView];
//            if (tempView)
//            {
//                return tempView;
//            }
//        }
//    }
//    return nil;
//}

-(void) showScreenProtect {
    [self showScreenProtect:true];
}

-(void) hiddenScreenProtect {
    [self showScreenProtect:false];
}

-(void) showScreenProtect:(BOOL)show {
    if(show && self.isShowScreenProtect) {
        return;
    }
    self.isShowScreenProtect = show;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if(show) {
        [window addSubview:self.screenProtectionView];
    }else{
        [self.screenProtectionView removeFromSuperview];
    }
    if(show) {
        [window endEditing:true];
    }
   
    
}

- (NSLock *)delegateLock {
    if (_delegateLock == nil) {
        _delegateLock = [[NSLock alloc] init];
    }
    return _delegateLock;
}

-(NSHashTable*) delegates {
    if (_delegates == nil) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _delegates;
}

-(void) addDelegate:(id<QCAppDelegate>) delegate{
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}
- (void)removeDelegate:(id<QCAppDelegate>) delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}


- (void)callAppLogoutDelegate {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(appLogout)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate appLogout];
                });
            }else {
                 [delegate appLogout];
            }
        }
    }
}
- (void)callAppLoginSuccessDelegate {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(appLoginSuccess)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate appLoginSuccess];
                });
            }else {
                 [delegate appLoginSuccess];
            }
        }
    }
}

-(void) addChannelAvatarUpdateNotify:(id)observer selector:(SEL)sel{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:sel name:QCNOTIFY_CHANNEL_AVATAR_UPDATE object:nil];
}

-(void) removeChannelAvatarUpdateNotify:(id)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:QCNOTIFY_CHANNEL_AVATAR_UPDATE object:nil];
}

-(void) notifyChannelAvatarUpdate:(QCChannel*)channel {
    [[NSNotificationCenter defaultCenter] postNotificationName:QCNOTIFY_CHANNEL_AVATAR_UPDATE object:channel];
}

- (NSArray<QCSticker *> *)collectStickers {
    if(!_collectStickers) {
        _collectStickers = [NSArray array];
    }
    return _collectStickers;
}


// 根据需要加载收藏的表情
-(AnyPromise*) loadCollectStickersIfNeed {
    if(self.collectStickerRequested) {
        return [AnyPromise promiseWithValue:self.collectStickers];
    }
    __weak typeof(self) weakSelf = self;
   return [self loadCollectStickers].then(^(){
        weakSelf.collectStickerRequested = true;
   });
}

-(AnyPromise*) loadCollectStickers {
    __weak typeof(self) weakSelf = self;
   return [[QCAPIClient sharedClient] GET:@"sticker/user" parameters:nil model:QCSticker.class].then(^(NSArray *stickerArray) {
        weakSelf.collectStickers = stickerArray;
       return stickerArray;
    }).catch(^(NSError *error){
        NSLog(@"加载收藏的表情失败！");
    });
}

-(BOOL) isSystemAccount:(NSString*)uid {
    if([uid isEqualToString:self.config.fileHelperUID] || [uid isEqualToString:self.config.systemUID]) {
        return true;
    }
    return false;
}

-(UIImage*) imageName:(NSString*)name {
    return [self loadImage:name moduleID:@"QCCore"];
}


@end


// 扩展字段的key
NSString * const QCChannelExtraKeyScreenshot = @"screenshot"; // 截屏通知
NSString * const QCChannelExtraKeyShortNo = @"short_no"; // 短编码
NSString * const  QCChannelExtraKeyForbiddenAddFriend = @"forbidden_add_friend"; // 禁止互加好友
NSString * const QCChannelExtraKeyRevokeRemind = @"revoke_remind"; // 撤回通知
NSString * const QCChannelExtraKeyJoinGroupRemind = @"join_group_remind"; // 进群提醒
NSString * const QCChannelExtraKeyChatPwd = @"chat_pwd_on"; // 聊天密码
NSString * const QCChannelExtraKeySource = @"source"; // 来源
NSString * const QCChannelExtraKeyVercode = @"vercode"; // 加好友验证码
NSString * const QCChannelExtraKeyAllowViewHistoryMsg = @"allow_view_history_msg"; // 允许新成员查看群历史消息
NSString * const QCChannelExtraKeyRemark = @"remark"; // 备注
