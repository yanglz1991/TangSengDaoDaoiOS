//
//  QCLoginVM.m
//  WuKongLogin
//
//  Created by tt on 2019/12/1.
//

#import "QCLoginVM.h"
#import <WuKongBase/WuKongBase.h>
@implementation QCLoginResp

+(QCModel*) fromMap:(NSDictionary*)dictory type:(ModelMapType)type{
    QCLoginResp *loginResp = [QCLoginResp new];
    loginResp.uid = dictory[@"uid"];
    loginResp.shortNo = dictory[@"short_no"]?:@"";
    loginResp.name = dictory[@"name"];
    loginResp.sex = dictory[@"sex"]?:@(0);
    loginResp.zone = dictory[@"zone"]?:@"";
    loginResp.phone = dictory[@"phone"]?:@"";
    loginResp.token = dictory[@"token"];
    loginResp.imToken = dictory[@"im_token"];
    loginResp.avatar = dictory[@"avatar"];
    loginResp.shortStatus = dictory[@"short_status"]?:@(0);
    loginResp.serverID = dictory[@"server_id"]?:@(1);
    loginResp.chatPwd = dictory[@"chat_pwd"]?:@"";
    loginResp.lockScreenPwd = dictory[@"lock_screen_pwd"]?:@"";
    loginResp.lockAfterMinute = dictory[@"lock_after_minute"]?:@(0);
    if(dictory[@"setting"]) {
        loginResp.setting = dictory[@"setting"];
    }
    loginResp.rsaPublicKey = dictory[@"rsa_public_key"];
    return loginResp;
}

//-(NSDictionary*) toMap:(ModelMapType)type{
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"uid"] = self.uid;
//    dic[@"name"] = self.name;
//    dic[@"token"] = self.token;
//    dic[@"avatar"] = self.avatar;
//    return dic;
//}

@end
@implementation QCLoginVM

-(AnyPromise*) login:(NSString*) username password:(NSString*)password {
    
    return  [[QCAPIClient sharedClient] POST:@"user/login" parameters:@{@"username":username,@"password":password,@"device":@{@"device_id":[UIDevice getUUID],@"device_name":[UIDevice getDeviceName],@"device_model":[UIDevice getDeviceModel]}} model:QCLoginResp.class];
   
}

+(void) handleLoginData:(QCLoginResp*)resp isSave:(BOOL)isSave{
    [QCApp shared].loginInfo.token = resp.token;
    if(resp.imToken) {
        [QCApp shared].loginInfo.imToken = resp.imToken;
    }else {
        [QCApp shared].loginInfo.imToken = resp.token;
    }
    [QCApp shared].loginInfo.uid = resp.uid;
    [QCApp shared].loginInfo.extra[@"name"] = resp.name;
    [QCApp shared].loginInfo.extra[@"zone"] = resp.zone;
    [QCApp shared].loginInfo.extra[@"phone"] = resp.phone;
    [QCApp shared].loginInfo.extra[@"short_no"] = resp.shortNo;
    [QCApp shared].loginInfo.extra[@"short_status"] = resp.shortStatus;
    [QCApp shared].loginInfo.extra[@"sex"] = resp.sex;
    [QCApp shared].loginInfo.extra[@"server_id"] = resp.serverID;
    [QCApp shared].loginInfo.extra[@"chat_pwd"] = resp.chatPwd;
    if(resp.lockScreenPwd && ![resp.lockScreenPwd isEqualToString:@""]) {
        [QCApp shared].loginInfo.extra[@"lock_screen_pwd"] = resp.lockScreenPwd;
        [QCApp shared].loginInfo.extra[@"lock_after_minute"] = resp.lockAfterMinute?:@(0);
    }else {
        [[QCApp shared].loginInfo.extra removeObjectForKey:@"lock_screen_pwd"];
        [[QCApp shared].loginInfo.extra removeObjectForKey:@"lock_after_minute"];
    }
    
    if(resp.rsaPublicKey) {
        [QCApp shared].loginInfo.extra[@"rsa_public_key"] = resp.rsaPublicKey;
    }
    
   
    if(resp.setting) {
        [QCApp shared].loginInfo.extra[@"setting"] = resp.setting;
    }
    if(resp.avatar && ![resp.avatar isEqualToString:@""]) {
        [QCApp shared].loginInfo.extra[@"avatar"] = resp.avatar;
    }else{
        NSString *avatarURL = [QCAvatarUtil getAvatar:resp.uid];
        [QCApp shared].loginInfo.extra[@"avatar"] = avatarURL;
    }
    if(isSave) {
        [[QCApp shared].loginInfo save];
    }
}
@end


