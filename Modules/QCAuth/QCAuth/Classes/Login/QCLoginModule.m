//
//  QCLoginModule.m
//  QCAuth
//
//  Created by tt on 2019/12/1.
//

#import "QCLoginModule.h"
#import "QCLoginVC.h"
#import "QCGrantLoginVC.h"
#import "QCThirdLoginVC.h"
#import "QCLoginSettingVC.h"
@QCModule(QCLoginModule)
@implementation QCLoginModule

-(NSString*) moduleId {
    return @"QCAuth";
}

- (void)moduleInit:(QCModuleContext*)context{
    NSLog(@"【QCAuth】模块初始化！");
    
    [QCLoginSettingVC setAppConfigIfNeed];
    
    // 显示登录页面
    [self setMethod:QCPOINT_LOGIN_SHOW handler:^id _Nullable(id  _Nonnull param) {
         QCLoginVC *loginVC = [QCLoginVC new]; // 手机号登录UI
//        QCThirdLoginVC *loginVC = [QCThirdLoginVC new]; // 第三方授权登录UI
        [[QCNavigationManager shared] resetRootViewController:loginVC];
        return nil;
    }];
    
    // 授权登录UI
    [self setMethod:QCPOINT_SCAN_HANDLER_GRANTLOGIN handler:^id _Nullable(id  _Nonnull param) {
           return [QCScanHandler handle:^BOOL(QCScanResult * _Nonnull result, void (^ _Nonnull reScanBlock)(void)) {
               if(![result.type isEqualToString:@"loginConfirm"]) {
                   return false;
               }
               QCGrantLoginVC *vc = [QCGrantLoginVC new];
               vc.authCode = result.data[@"auth_code"];
               vc.pubkeyBase64Enc = result.data[@"pub_key"];
               vc.modalPresentationStyle = UIModalPresentationFullScreen;
               [[QCNavigationManager shared] replacePresentViewController:vc animated:YES];
               return true;
           }];
       } category:QCPOINT_CATEGORY_SCAN_HANDLER];
}



@end
