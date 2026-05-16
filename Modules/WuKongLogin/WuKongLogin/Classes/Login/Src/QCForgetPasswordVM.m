//
//  QCForgetPasswordVM.m
//  WuKongLogin
//
//  Created by tt on 2020/10/27.
//

#import "QCForgetPasswordVM.h"

@implementation QCForgetPasswordVM


- (AnyPromise *)sendCode:(NSString*)zone phone:(NSString*)phone {
    return [[QCAPIClient sharedClient] POST:@"user/sms/forgetpwd" parameters:@{@"zone":zone?:@"",@"phone":phone}];
}

- (AnyPromise *)setNewPwd:(NSString *)zone phone:(NSString *)phone code:(NSString *)code pwd:(NSString *)pwd {
    return [[QCAPIClient sharedClient] POST:@"user/pwdforget" parameters:@{@"zone":zone?:@"",@"phone":phone,@"code":code,@"pwd":pwd}];
}
@end
