//
//  QCContactsFriendVM.m
//  WuKongContacts
//
//  Created by tt on 2021/9/22.
//

#import "QCContactsFriendVM.h"

@implementation QCContactsFriendVM


-(AnyPromise*) requestMaillist {
    
    return [[QCAPIClient sharedClient] GET:@"user/maillist" parameters:nil model:QCContactsFriendResp.class];
}

-(AnyPromise*) requestUpload:(NSArray<QCContactsFriendModel*>*)friends {
    NSMutableArray *items = [NSMutableArray array];
    if(friends && friends.count>0) {
        for (QCContactsFriendModel *friendModel in friends) {
            [items addObject:@{
                @"name": friendModel.name,
                @"phone": friendModel.phone,
            }];
        }
    }
    return [[QCAPIClient sharedClient] POST:@"user/maillist" parameters:items];
}

-(AnyPromise*) applyFriend:(NSString*)uid remark:(NSString*)remark vercode:(NSString*)vercode{
    return [[QCAPIClient sharedClient] POST:@"friend/apply" parameters:@{@"to_uid":uid?:@"",@"remark":remark?:@"",@"vercode":vercode?:@""}];
}

@end


@implementation QCContactsFriendResp

+ (QCModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCContactsFriendResp *resp = [QCContactsFriendResp new];
    resp.uid = dictory[@"uid"];
    resp.name = dictory[@"name"];
    resp.zone = dictory[@"zone"];
    resp.phone = dictory[@"phone"];
    resp.vercode = dictory[@"vercode"];
    resp.isFriend = [dictory[@"is_friend"] boolValue];
    return resp;
}

@end

