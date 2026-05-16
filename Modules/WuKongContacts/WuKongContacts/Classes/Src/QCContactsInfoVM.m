//
//  QCContactsInfoVM.m
//  WuKongContacts
//
//  Created by tt on 2020/1/4.
//

#import "QCContactsInfoVM.h"

@implementation QCContactsInfoVM

-(AnyPromise*) getUserInfo:(NSString*)uid {
    return [[QCAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%@",uid] parameters:nil model:QCUserInfoResp.class];
}
-(AnyPromise*) applyFriend:(NSString*)uid remark:(NSString*)remark {
    return [[QCAPIClient sharedClient] POST:@"friend/apply" parameters:@{@"to_uid":uid?:@"",@"remark":remark?:@""}];
}
@end

@implementation QCUserInfoResp

+(QCUserInfoResp*) fromMap:(NSDictionary*)dictory type:(ModelMapType)type {
    QCUserInfoResp *resp = [QCUserInfoResp new];
    resp.uid = dictory[@"uid"];
    resp.name = dictory[@"name"];
    resp.avatar = dictory[@"avatar"];
    return resp;
}

@end
