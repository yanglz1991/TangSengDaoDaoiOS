//
//  WKGroupApprovalListVM.m
//  WuKongGroupManager
//

#import "WKGroupApprovalListVM.h"
#import "WKGroupApprovalCell.h"
#import "WKAPIClient.h"
#import "WKAvatarUtil.h"

@interface WKGroupApprovalListVM ()

@property(nonatomic, strong) NSArray<NSDictionary *> *invites;

@end

@implementation WKGroupApprovalListVM

- (void)requestData:(void (^)(NSError *_Nonnull))complete {
    __weak typeof(self) weakSelf = self;
    [[WKAPIClient sharedClient] GET:[NSString stringWithFormat:@"groups/%@/member/invites", self.channel.channelId] parameters:nil].then(^(id resultObject) {
        if ([resultObject isKindOfClass:[NSArray class]]) {
            weakSelf.invites = (NSArray *)resultObject;
        } else {
            weakSelf.invites = @[];
        }
        if (complete) complete(nil);
    }).catch(^(NSError *error) {
        weakSelf.invites = @[];
        if (complete) complete(error);
    });
}

- (NSArray<NSDictionary *> *)tableSectionMaps {
    if (!self.invites || self.invites.count == 0) {
        return @[];
    }
    __weak typeof(self) weakSelf = self;
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *invite in self.invites) {
        NSString *inviteNo = invite[@"invite_no"] ?: @"";
        NSString *inviter = invite[@"inviter"] ?: @"";
        NSString *inviterName = invite[@"inviter_name"] ?: @"";
        NSString *remark = invite[@"remark"] ?: @"";
        NSString *createdAt = invite[@"created_at"] ?: @"";
        NSArray *invitedItems = invite[@"items"];
        if (![invitedItems isKindOfClass:[NSArray class]]) {
            invitedItems = @[];
        }
        NSMutableArray<NSString *> *names = [NSMutableArray array];
        for (id obj in invitedItems) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)obj;
                NSString *n = dict[@"name"] ?: @"";
                [names addObject:n];
            }
        }
        NSString *content = [NSString stringWithFormat:LLang(@"邀请 %lu 位朋友进群：%@"), (unsigned long)invitedItems.count, [names componentsJoinedByString:@"、"]];
        [items addObject:@{
            @"class": WKGroupApprovalModel.class,
            @"inviteNo": inviteNo,
            @"avatarURL": [WKAvatarUtil getAvatar:inviter] ?: @"",
            @"inviterName": inviterName,
            @"createdAt": createdAt,
            @"content": content,
            @"remark": remark,
            @"onClick": ^(WKFormItemModel *model, NSIndexPath *indexPath) {
                if ([model isKindOfClass:[WKGroupApprovalModel class]]) {
                    WKGroupApprovalModel *m = (WKGroupApprovalModel *)model;
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(groupApprovalListVM:didSelectInviteNo:)]) {
                        [weakSelf.delegate groupApprovalListVM:weakSelf didSelectInviteNo:m.inviteNo];
                    }
                }
            }
        }];
    }
    return @[
        @{
            @"height": @(0.1f),
            @"items": items,
        }
    ];
}

@end
