//
//  QCLoginPhoneCheckVM.m
//  WuKongLogin
//
//  Created by tt on 2020/10/26.
//

#import "QCLoginPhoneCheckVM.h"
#import "QCLoginVM.h"
@interface QCLoginPhoneCheckVM ()

@property(nonatomic,copy) NSString *code;

@end

@implementation QCLoginPhoneCheckVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    
    __weak typeof(self) weakSelf = self;
    return @[
        @{
            @"height":QCSectionHeight,
            @"items": @[
                    @{
                        @"class": QCLabelModel.class,
                        @"text": [NSString stringWithFormat:LLang(@"我们已给你的手机号码%@发送了一条验证码短信。"),self.phone],
                        @"font": [[QCApp shared].config appFontOfSize:16.0f],
                    }
            ]
        },
        @{
            @"height":QCSectionHeight,
            @"items": @[
                    @{
                        @"class": QCSMSCodeItemModel.class,
                        @"sendBtnTitle":self.sendBtnTitle?:@"",
                        @"disable": @(self.sendBtnDisable),
                        @"onChange":^(NSString*value){
                            weakSelf.code = value;
                        },
                        @"onSend":^{
                            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(loginPhoneCheckVMDidSend:)]) {
                                [weakSelf.delegate loginPhoneCheckVMDidSend:weakSelf];
                            }
                        }
                    }
            ]
        },
        @{
            @"height":@(40.0f),
            @"items": @[
                    @{
                        @"class": QCButtonItemModel2.class,
                        @"title":LLang(@"确认"),
                        @"onPressed":^{
                            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(loginPhoneCheckVMDidOk:)]) {
                                [weakSelf.delegate loginPhoneCheckVMDidOk:weakSelf];
                            }
                        }
                    }
            ]
        }
    ];
}


-(AnyPromise*) sendLoginCheckCode:(NSString*)uid {
    return [[QCAPIClient sharedClient] POST:@"user/sms/login_check_phone" parameters:@{
        @"uid":uid?:@"",
    }];
}


- (AnyPromise *)loginCheckPhone:(NSString *)uid code:(NSString *)code {
    return [[QCAPIClient sharedClient] POST:@"user/login/check_phone" parameters:@{
        @"uid": uid?:@"",
        @"code": code?:@"",
    } model:QCLoginResp.class];
}

- (NSString *)sendBtnTitle {
    if(!_sendBtnTitle) {
        return LLang(@"发送");
    }
    return _sendBtnTitle;
}

- (NSString *)getCode {
    return self.code;
}

@end
