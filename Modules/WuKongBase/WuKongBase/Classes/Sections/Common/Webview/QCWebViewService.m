//
//  QCWebViewService.m
//  WuKongBase
//
//  Created by tt on 2023/9/11.
//

#import "QCWebViewService.h"
#import "WuKongBase.h"
#import "QCConversationListSelectVC.h"
#import "QCUserAuthView.h"
#import "QCWebViewJavascriptBridge.h"
@implementation QCWebViewService

- (void)registerHandlers {
    __weak typeof(self) weakSelf = self;
    
//    // 提交投诉
//    [self.bridge
//        registerHandler:@"commitReports"
//                handler:^(id data, WVJBResponseCallback responseCallback) {
//                    if ([data isKindOfClass:[NSDictionary class]]) {
//
//                    }
//     }];
    
    // 退出webview
    [self.bridge registerHandler:@"quit" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[QCNavigationManager shared] popViewControllerAnimated:YES];
    }];
    
    // 获取当前频道
    [self.bridge registerHandler:@"getChannel" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback([QCJsonUtil toJson:@{
            @"channel_id": weakSelf.channel && weakSelf.channel.channelId?weakSelf.channel.channelId:@"",
            @"channel_type":@(weakSelf.channel? weakSelf.channel.channelType:0)
        }]);
    }];
    
    // 选择最近会话
    [self.bridge registerHandler:@"chooseConversation" handler:^(id data, WVJBResponseCallback responseCallback) {
        QCConversationListSelectVC *vc = [QCConversationListSelectVC new];
        vc.title = LLangW(@"选择一个聊天", weakSelf);
        [vc setOnSelect:^(QCChannel * _Nonnull channel) {
            responseCallback([QCJsonUtil toJson:@{
                @"channel_id": channel && channel.channelId?channel.channelId:@"",
                @"channel_type":@(channel? channel.channelType:0)
            }]);
            
            [[QCNavigationManager shared] popViewControllerAnimated:YES];
            
            
        }];
        [[QCNavigationManager shared] pushViewController:vc animated:YES];
    }];
    
    // 显示最近会话
    [self.bridge registerHandler:@"showConversation" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(!data) {
            return;
        }
        
        QCConversationVC *conversationVC =  [QCConversationVC new];
        conversationVC.channel = [QCChannel channelID:data[@"channel_id"] channelType:[data[@"channel_type"] intValue]];
        if(data[@"forward"] && [data[@"forward"] isEqualToString:@"replace"]) {
            [[QCNavigationManager shared] replacePushViewController:conversationVC animated:YES];
        }else{
            [[QCNavigationManager shared] pushViewController:conversationVC animated:YES];
        }
    }];
    
    [self.bridge registerHandler:@"auth" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"auth......");
        
        NSString *appID = data[@"app_id"];
        if(!appID || [appID isEqualToString:@""]) {
            [QCNavigationManager.shared.topViewController.view showHUDWithHide:LLang(@"app_id不能为空！")];
            return;
        }
        UIView *topView = QCNavigationManager.shared.topViewController.view;
        [topView showHUD];
        [QCAPIClient.sharedClient GET:[NSString stringWithFormat:@"apps/%@",appID] parameters:nil].then(^(NSDictionary *resultDict){
            [topView hideHud];
            QCUserAuthView *authView = [weakSelf showUserAuth:resultDict];
            __weak typeof(authView) authViewWeak = authView;
            [authView setOnAllow:^{
                [weakSelf getAuthCode:appID].then(^(NSString*authcode){
                    responseCallback([QCJsonUtil toJson:@{@"code":authcode}]);
                    [weakSelf hideUserAuth:authViewWeak];
                    
                }).catch(^(NSError *error){
                    responseCallback([QCJsonUtil toJson:@{@"error":error.domain?:@""}]);
                });
            }];
        }).catch(^(NSError *error){
            [topView switchHUDError:error.domain];
        });
        
    
    }];
}

-(AnyPromise*) getAuthCode:(NSString*)appID{
    
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
        [QCAPIClient.sharedClient GET:@"openapi/authcode" parameters:@{@"app_id":appID}].then(^(NSDictionary *resultDic){
            NSString *authcode = resultDic[@"authcode"];
            resolver(authcode);
        }).catch(^(NSError *error){
            resolver(error);
        });
    }];
    
}

-(QCUserAuthView*) showUserAuth:(NSDictionary*)resultDict {
    NSString *appName = resultDict[@"app_name"]?:@"";
    NSString *appLogo = resultDict[@"app_logo"]?:@"";
    __weak typeof(self) weakSelf = self;
    QCUserAuthView *authView = [[QCUserAuthView alloc] init];
    authView.appName = appName;
    authView.appLogo = appLogo;
    authView.alpha = 0.0f;
    __weak typeof(authView) authViewWeak = authView;
    authView.onClose = ^{
        [weakSelf hideUserAuth:authViewWeak];
    };
   
    UIWindow *wd = [QCApp.shared findWindow];
    [wd addSubview:authView];
    [UIView animateWithDuration:0.25f animations:^{
        authView.show = true;
        authView.alpha = 1.0f;
        [authView layoutSubviews];
    }];
    
    return authView;
    
}

-(void) hideUserAuth:(QCUserAuthView*)authView {
    authView.alpha = 1.0f;
    [UIView animateWithDuration:0.25f animations:^{
        authView.show = false;
        authView.alpha = 0.0f;
        [authView layoutSubviews];
    } completion:^(BOOL finished) {
        [authView removeFromSuperview];
    }];
}

@end
