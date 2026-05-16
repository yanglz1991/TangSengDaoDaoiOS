//
//  QCConversationPasswordVM.m
//  WuKongBase
//
//  Created by tt on 2020/10/30.
//

#import "QCConversationPasswordVM.h"
#import "QCMD5Util.h"
@interface QCConversationPasswordVM ()

@property(nonatomic,copy) NSString *loginPwd;
@property(nonatomic,copy) NSString *chatPwd;
@property(nonatomic,copy) NSString *rechatPwd;
@end

@implementation QCConversationPasswordVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    __weak typeof(self) weakSelf = self;
    return @[
        @{
            @"height":@(15.0f),
            @"items":@[
                    @{
                        @"class":QCLabelModel.class,
                        @"text":LLang(@"验证您的登录密码"),
                        @"textColor": [QCApp shared].config.defaultTextColor,
                        @"font": [[QCApp shared].config appFontOfSize:24.0f],
                        @"center":@(true),
                    },
            ],
        },
        @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":QCLabelModel.class,
                        @"text":LLang(@"请确认您的登录密码后，再设定6位数字的聊天密码"),
                        @"textColor": [QCApp shared].config.defaultTextColor,
                        @"font": [[QCApp shared].config appFontOfSize:12.0f],
                        @"center":@(true),
                    },
            ],
        },
        @{
            @"height":@(60.0f),
            @"items":@[
                    @{
                        @"class":QCTextFieldItemModel.class,
                        @"placeholder":[NSString stringWithFormat:LLang(@"请输入%@登录密码"),[QCApp shared].config.appName],
                        @"showBottomLine":@(true),
                        @"password":@(true),
                        @"onChange": ^(NSString *value) {
                            weakSelf.loginPwd = value;
                        }
                    },
            ],
        },
        @{
            @"height":@(0.01f),
            @"items":@[
                    @{
                        @"class":QCTextFieldItemModel.class,
                        @"placeholder":LLang(@"请输入6位数字聊天密码"),
                        @"showBottomLine":@(true),
                        @"maxLen":@(6),
                        @"password":@(true),
                        @"keyboardType": @(UIKeyboardTypeNumberPad),
                        @"onChange": ^(NSString *value) {
                            weakSelf.chatPwd = value;
                        }
                    },
            ],
        },
        @{
            @"height":@(0.01f),
            @"items":@[
                    @{
                        @"class":QCTextFieldItemModel.class,
                        @"placeholder":LLang(@"请输入6位数字聊天密码"),
                        @"showBottomLine":@(true),
                        @"maxLen":@(6),
                        @"password":@(true),
                        @"keyboardType": @(UIKeyboardTypeNumberPad),
                        @"onChange": ^(NSString *value) {
                            weakSelf.rechatPwd = value;
                        }
                    },
            ],
        },
        @{
            @"height":@(40.0f),
            @"items":@[
                    @{
                        @"class":QCButtonItemModel2.class,
                        @"title": LLang(@"确认"),
                        @"onPressed":^{
                            [weakSelf setChatPwd];
                        }
                    },
            ],
        },
    ];
}

-(void) setChatPwd {
    
    if(!self.loginPwd || [self.loginPwd isEqualToString:@""]) {
        [[QCNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"登录密码不能为空！")];
        return;
    }
    if(!self.chatPwd || [self.chatPwd isEqualToString:@""]) {
        [[QCNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"聊天密码不能为空！")];
        return;
    }
    if(![self.chatPwd isEqualToString:self.rechatPwd]) {
        [[QCNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"两次密码输入不一致！")];
        return;
    }
    
    [[QCNavigationManager shared].topViewController.view showHUD];
    
    __weak typeof(self) weakSelf = self;
    [[QCAPIClient sharedClient] POST:@"user/chatpwd" parameters:@{
        @"login_pwd":self.loginPwd?:@"",
        @"chat_pwd": [self digestPwd:self.chatPwd]?:@"",
    }].then(^{
        [QCApp shared].loginInfo.extra[@"chat_pwd"] = [weakSelf digestPwd:weakSelf.chatPwd];
        [[QCApp shared].loginInfo save];
        
        [[QCNavigationManager shared].topViewController.view hideHud];
        [[QCNavigationManager shared] popViewControllerAnimated:YES];
        
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(conversationPasswordVMFinished:)]) {
            [weakSelf.delegate conversationPasswordVMFinished:weakSelf];
        }
        
    }).catch(^(NSError *error){
        [[QCNavigationManager shared].topViewController.view switchHUDError:error.domain];
    });
}

-(NSString*) digestPwd:(NSString*)pwd {
    return [QCMD5Util md5HexDigest:[NSString stringWithFormat:@"%@%@",pwd,[QCApp shared].loginInfo.uid]];
}

@end
