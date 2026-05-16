//
//  QCContactsSync.m
//  QCContacts
//
//  Created by tt on 2019/12/7.
//

#import "QCContactsSync.h"
@implementation QCContactsSync

- (BOOL)needSync {
    return true;
}

- (void)sync:(void (^)(NSError *))callback {
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@",[QCApp shared].loginInfo.uid,@"friend_version"];
    NSString *friendMaxVersion = [[NSUserDefaults standardUserDefaults] stringForKey:cacheKey];
    NSInteger limit = 200;
    __weak typeof(self) weakSelf = self;
    __strong typeof(weakSelf) strongSelf = weakSelf;
    [[QCAPIClient sharedClient] GET:[NSString stringWithFormat:@"friend/sync"] parameters:@{@"version":friendMaxVersion?:@"",@"api_version":@"1",@"limit":@(limit)}].then(^(NSArray<NSDictionary*>* contacts){
        if(contacts && contacts.count>0) {
            NSMutableArray *channelInfos = [NSMutableArray array];
            for (NSDictionary *dict in contacts) {
                BOOL isDeleted = false;
                if(dict[@"is_deleted"]) {
                    isDeleted = [dict[@"is_deleted"] boolValue];
                }
                if(isDeleted) {
                    QCChannel *channel = [[QCChannel alloc] initWith:dict[@"uid"] channelType:WK_PERSON];
                    [[QCSDK shared].channelManager deleteChannelInfo:channel];
                }else{
                    [channelInfos addObject:[QCChannelUtil toChannelInfo:dict]];
                }
                // 下面代码还不能注释 需要修改完联系人选择等功能后才能注释掉
//                NSInteger count = [[QCDBContacts shared] queryCountWithUID:cont.uid];
//                if(count>0) {
//                    [[QCDBContacts shared] updateWithModel:cont];
//                }else {
//                    [[QCDBContacts shared] insert:cont];
//                }
            }
            long long version = [contacts.lastObject[@"version"] longLongValue];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lld",version] forKey:cacheKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
             [[QCSDK shared].channelManager addOrUpdateChannelInfos:channelInfos];
            
            if(contacts.count>=limit) {
                [strongSelf sync:callback];
                return;
            }
        }
        // 通知联系人更新
        [[NSNotificationCenter defaultCenter] postNotificationName:WK_NOTIFY_CONTACTS_UPDATE object:nil];
        if(callback) {
            callback(nil);
        }
       
    }).catch(^(NSError *error){
        if(callback) {
            callback(error);
        }
        QCLogError(@"同步联系人数据出错:%@",error);
    });
}


- (NSString *)title {
//    return nil;
    return LLang(@"同步联系人");
}


@end
