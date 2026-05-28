//
//  AppDelegate.m
//  QX
//
//  Created by tt on 2019/11/30.
//  Copyright © 2025 QX. All rights reserved.
//

#import "AppDelegate.h"
#import <QCCore/QCCore.h>
#import "QCMainTabController.h"
@import QCContacts;
#import <QCCore/QCSyncService.h>
#import "QCMeVC.h"

#import "SELUpdateAlert.h"


#define SERVER_IP @"qx.qhfhasina.com/api" // xxx.xxx.xx.xx:8090
#define HTTPS_ON true // https开关


#define BASE_URL [NSString stringWithFormat:@"%@://%@/v1/",HTTPS_ON?@"https":@"http",SERVER_IP]
#define WEB_URL [NSString stringWithFormat:@"%@://%@/web/",HTTPS_ON?@"https":@"http",SERVER_IP]
// api基地址
#define API_BASE_URL  BASE_URL
// 文件基地址
#define FILE_BASE_URL BASE_URL
// 文件预览地址
#define FILE_BROWSE_URL BASE_URL
// 图片预览地址
#define IMAGE_BROWSE_URL BASE_URL

// 举报地址
#define REPORT_URL  [NSString stringWithFormat:@"%@://%@/web/report.html",HTTPS_ON?@"https":@"http",SERVER_IP]




@interface AppDelegate ()<UITabBarControllerDelegate>

@property(nonatomic,strong) QCConversationListVC *conversationList;
//@property(nonatomic,strong)  QCContactsVC *contactVC;
@property(nonatomic,strong) QCMeVC *meVC;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 启动喜聊品牌运行时（身份、主题、遥测、隐私面板、阅读偏好等模块的初始化入口）
    [[QXBootstrapper sharedBootstrapper] bootstrap];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor grayColor];
    [self.window makeKeyAndVisible];

    // 加载登录信息
    [[QCApp shared].loginInfo load];

    // app配置
    QCAppConfig *config = [QCAppConfig new];
    config.apiBaseUrl = API_BASE_URL; // api地址
    config.fileBaseUrl = FILE_BASE_URL; // 文件上传地址
    config.fileBrowseUrl = FILE_BROWSE_URL; // 文件预览地址
    config.imageBrowseUrl = IMAGE_BROWSE_URL; // 图片预览地址
    config.reportUrl = [NSString stringWithFormat:@"%@report/html",API_BASE_URL]; //举报地址
    config.privacyAgreementUrl = [NSString stringWithFormat:@"%@privacy_policy.html",WEB_URL]; //隐私协议
    config.userAgreementUrl = [NSString stringWithFormat:@"%@user_agreement.html",WEB_URL]; //用户协议
    [QCApp shared].config = config;
    
    // app首页设置
    [QCApp shared].getHomeViewController = ^UIViewController * _Nonnull{
        QCMainTabController *homeViewController =  [QCMainTabController new];
        return homeViewController;
    };

   
    // app初始化
    [[QCApp shared] appInit];
    
    if (@available(iOS 13.0, *)) {
        if([QCApp shared].config.style == QCSystemStyleDark) {
            self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        }else{
            self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
    }
   
    return YES;
}

-(void) applicationWillEnterForeground:(UIApplication *)application {
    NSInteger lastCheckUpdateTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastCheckUpdateTime"];
    if(lastCheckUpdateTime == 0) {
        [self checkAppVersionOrUpdate];
    }else if ([[NSDate date] timeIntervalSince1970] - lastCheckUpdateTime > 60.0f * 30.0f){
        [self checkAppVersionOrUpdate];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[QXBootstrapper sharedBootstrapper] applicationDidBecomeActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[QXBootstrapper sharedBootstrapper] applicationDidEnterBackground];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"内存警告");
    [[QXTelemetry sharedTelemetry] recordName:@"app.memoryWarning"
                                     category:@"lifecycle"
                                     severity:QXTelemetrySeverityWarning];
}

-(void) checkAppVersionOrUpdate {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [[QCAPIClient sharedClient] GET:[NSString stringWithFormat:@"common/appversion/iOS/%@",appVersion] parameters:nil].then(^(NSDictionary *resultDict){
        [[NSUserDefaults standardUserDefaults] setInteger:[[NSDate date] timeIntervalSince1970] forKey:@"lastCheckUpdateTime"];
        NSString *version = resultDict[@"app_version"];
        if(!version||[version isEqualToString:@""]) {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastAlertUpdateTime"];
            return;
        }
        
        if([self versionStrToInt:version]>[self versionStrToInt:appVersion]) {
            NSString  *updateDesc = resultDict[@"update_desc"];
            BOOL isForce = resultDict[@"is_force"]?[resultDict[@"is_force"] boolValue]:false;
            NSString *downloadURL = resultDict[@"download_url"];
            
            [SELUpdateAlert showUpdateAlertWithVersion:resultDict[@"app_version"] Description:updateDesc downloadURL:downloadURL forceUpdate:isForce];
        }
      
    });
}

-(NSInteger) versionStrToInt:(NSString*)versionStr {
    return [[versionStr stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (!deviceToken || ![deviceToken isKindOfClass:[NSData class]] || deviceToken.length==0) {
        return;
    }
    NSString *(^getDeviceToken)(void) = ^() {
            if (@available(iOS 13.0, *)) {
                const unsigned char *dataBuffer = (const unsigned char *)deviceToken.bytes;
                NSMutableString *myToken  = [NSMutableString stringWithCapacity:(deviceToken.length * 2)];
                for (int i = 0; i < deviceToken.length; i++) {
                    [myToken appendFormat:@"%02x", dataBuffer[i]];
                }
                return (NSString *)[myToken copy];
            } else {
                NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
                NSString *myToken = [[deviceToken description] stringByTrimmingCharactersInSet:characterSet];
                return [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
        };
    NSString *myToken = getDeviceToken();
    NSLog(@"myToken----------->%@",myToken);
    [QCApp shared].loginInfo.deviceToken = myToken;
    [[QCApp shared].loginInfo save];
   NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [[QCAPIClient sharedClient] POST:@"user/device_token" parameters:@{@"device_token":myToken,@"device_type":@"IOS",@"bundle_id":bundleID}].catch(^(NSError *error){
        QCLogError(@"上传设备token失败！-> %@",error);
    });
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"didReceiveRemoteNotification------>");
    [QCApp.shared application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    QCLogError(@"注册远程通知失败->%@",error);
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    return [[QCApp shared] appOpenURL:url options:options];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    return [[QCApp shared] appContinueUserActivity:userActivity restorationHandler:restorationHandler];
}

@end

