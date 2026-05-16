//
//  QCMyGroupListVM.m
//  WuKongContacts
//
//  Created by tt on 2020/7/16.
//

#import "QCMyGroupListVM.h"
#import "QCMyGroupCell.h"
@interface QCMyGroupListVM ()<QCChannelManagerDelegate>



@end

@implementation QCMyGroupListVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        [QCSDK.shared.channelManager addDelegate:self];
    }
    return self;
}

- (NSArray<NSDictionary *> *)tableSectionMaps {
    if(!self.groups || self.groups.count<=0) {
        return nil;
    }
    NSMutableArray *items = [NSMutableArray array];
    for (QCMyGroupResp *model in self.groups) {
        [items addObject:@{
            @"class": QCMyGroupModel.class,
            @"groupNo": model.groupNo?:@"",
            @"name": model.displayName?:@"",
            @"showArrow":@(false),
            @"onClick":^{
                [[QCApp shared] pushConversation:[[QCChannel alloc] initWith:model.groupNo channelType:WK_GROUP]];
            },
        }];
    }
    return @[
        @{
            @"height":@(0.0f),
            @"items":items,
        }
    ];
}

- (void)requestData:(void (^)(NSError * _Nullable))complete {
    __weak typeof(self) weakSelf = self;
    [self myGroupList].then(^(NSArray<QCMyGroupResp*>* groups){
        weakSelf.groups = groups;
        complete(nil);
    }).catch(^(NSError *error){
        complete(error);
    });
}

-(AnyPromise*) myGroupList {
    return [[QCAPIClient sharedClient] GET:@"group/my" parameters:@{
        @"page_size": @(1000), // 应该没有人会保存1000个群
    } model:QCMyGroupResp.class];
}
- (void)dealloc {
    [QCSDK.shared.channelManager removeDelegate:self];
}

#pragma mark -- QCChannelManagerDelegate

- (void)channelInfoUpdate:(QCChannelInfo *)channelInfo {
    if(channelInfo.channel.channelType != WK_GROUP) {
        return;
    }
    BOOL exist = false;
    BOOL refreshRemoteData =false;
    for (QCMyGroupResp *resp in self.groups) {
        if([resp.groupNo isEqualToString:channelInfo.channel.channelId]) {
            resp.name = channelInfo.name;
            resp.remark = channelInfo.remark;
            exist = true;
            if(!channelInfo.save) {
                refreshRemoteData = true;
            }
            break;
        }
    }
    
    if(refreshRemoteData) {
        [self reloadRemoteData];
    } else if(exist) {
        [self reloadData];
    }else {
        if(channelInfo.save) {
            [self reloadRemoteData];
        }
    }
}


@end

@implementation QCMyGroupResp

+ (QCMyGroupResp *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCMyGroupResp *resp = [QCMyGroupResp new];
    resp.groupNo = dictory[@"group_no"];
    resp.name = dictory[@"name"];
    resp.remark = dictory[@"remark"]?:@"";
    return resp;
}

- (NSString *)displayName {
    if(self.remark && ![self.remark isEqualToString:@""]) {
        return self.remark;
    }
    return self.name?:@"";
}

@end
