//
//  QCUserOnlineResp.m
//  WuKongBase
//
//  Created by tt on 2023/1/3.
//

#import "QCUserOnlineResp.h"

@implementation QCUserOnlineResp

+ (QCModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCUserOnlineResp *resp = [QCUserOnlineResp new];
    resp.uid = dictory[@"uid"]?:@"";
    resp.deviceFlag = [dictory[@"device_flag"] integerValue];
    resp.lastOnline = [dictory[@"last_online"] integerValue];
    resp.lastOffline = [dictory[@"last_offline"] integerValue];
    resp.online = [dictory[@"online"] boolValue];
    
    return resp;
}

@end
