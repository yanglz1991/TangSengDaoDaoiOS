//
//  QCRegisterVM.m
//  WuKongLogin
//
//  Created by tt on 2020/6/18.
//

#import "QCRegisterVM.h"

@implementation QCRegisterVM

- (AnyPromise *)sendCode:(NSString*)zone phone:(NSString*)phone {
    return [[QCAPIClient sharedClient] POST:@"user/sms/registercode" parameters:@{@"zone":zone?:@"",@"phone":phone}];
}

- (AnyPromise *)registerByPhone:(NSString *)zone phone:(NSString *)phone code:(NSString *)code inviteCode:(NSString*)inviteCode password:(NSString *)password {
    return [[QCAPIClient sharedClient] POST:@"user/register" parameters:@{@"zone":zone?:@"",@"phone":phone?:@"",@"code":code?:@"",@"invite_code":inviteCode?:@"",@"password":password?:@"",@"device":@{@"device_id":[UIDevice getUUID],@"device_name":[UIDevice getDeviceName],@"device_model":[UIDevice getDeviceModel]}} model:QCLoginResp.class];
}

-(AnyPromise*) updateName:(NSString*)name {
    return [[QCAPIClient sharedClient] PUT:@"user/current" parameters:@{@"name":name?:@""}];
}

@end
