//
//  QCGroupBlacklistVM.m
//  WuKongBase
//
//  Created by tt on 2020/10/19.
//

#import "QCGroupBlacklistVM.h"
#import "QCManagerCell.h"


@interface QCGroupBlacklistVM ()
/**
 我在群里的信息
 */
@property(nullable,nonatomic,strong) QCChannelMember *memberOfMe;

@end
@implementation QCGroupBlacklistVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
   NSArray<QCChannelMember*> *members = [[QCChannelMemberDB shared] getBlacklistMembersWithChannel:self.channel];
    __weak typeof(self) weakSelf = self;
    NSMutableArray *items = [NSMutableArray array];
    if(members && members.count>0) {
        for (QCChannelMember *member in members) {
            
            BOOL showSub = false;
            if([self isManagerOrCreatorForMe]) {
                showSub =  true;
            }
            [items addObject:@{
                @"class": QCManagerModel.class,
                @"title":member.memberName?:@"",
                @"icon": member.memberAvatar && ![member.memberAvatar isEqualToString:@""] ?[QCAvatarUtil getFullAvatarWIthPath:member.memberAvatar]: [QCAvatarUtil getAvatar:member.memberUid],
                @"onSub": ^{
                    if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(groupBlacklistVMRemoveBlacklist:member:)]) {
                        [weakSelf.delegate groupBlacklistVMRemoveBlacklist:weakSelf member:member];
                    }
                },
                @"showSub": @(showSub),
            }];
        }
    }
    if([self isManagerOrCreatorForMe]) {
        [items addObject:@{
            @"class":QCManagerAddModel.class,
            @"title":LLang(@"添加黑名单成员"),
            @"onClick":^{
                [weakSelf toSelectMembers];
            }
        }];
    }
   
    return @[
        @{
            @"height":@(10.0f),
            @"items":items,
        }
    ];
}

// 去选择拉入黑名单的成员
-(void) toSelectMembers {
   NSArray<QCChannelMember*> *members = [[QCChannelMemberDB shared] getMembersWithChannel:self.channel role:QCMemberRoleCommon];
    NSMutableArray<QCContactsSelect*> *contactsSelects = [NSMutableArray array];
    for (QCChannelMember *member in members) {
        [contactsSelects addObject:[QCModelConvert toContactsSelect:member]];
    }
    __weak typeof(self) weakSelf = self;
    [[QCApp shared] invoke:QCPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*uids){
        [[QCNavigationManager shared] popViewControllerAnimated:YES];
        [weakSelf addOrRemoveBlacklist:@"add" uids:uids];
    },@"data":contactsSelects,@"title":LLang(@"选择成员")}];
}

// 添加或移除黑名单
-(void) addOrRemoveBlacklist:(NSString*)action uids:(NSArray<NSString*>*)uids{
    __weak typeof(self) weakSelf = self;
    [[QCNavigationManager shared].topViewController.view showHUD];
    [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/blacklist/%@",self.channel.channelId,action] parameters:@{
        @"uids": uids?:@[],
    }].then(^{
        [[QCNavigationManager shared].topViewController.view hideHud];
        QCMemberStatus memberStatus;
        if(action && [action isEqualToString:@"remove"]) {
            memberStatus = QCMemberStatusNormal;
        }else {
            memberStatus = QCMemberStatusBlacklist;
        }
        [QCChannelMemberDB.shared updateMemberStatus:memberStatus channel:weakSelf.channel uids:uids];
        [weakSelf reloadData]; // 先刷新 让黑名单消失
        [[QCGroupManager shared] syncMemebers:weakSelf.channel.channelId complete:^(NSInteger syncMemberCount, NSError * _Nullable error) {
            if(error) {
                [[QCNavigationManager shared].topViewController.view switchHUDError:error.domain];
                return;
            }
            [weakSelf reloadData];
        }];
    }).catch(^(NSError *error){
        [[QCNavigationManager shared].topViewController.view switchHUDError:error.domain];
    });
}

- (QCChannelMember *)memberOfMe {
    if(!_memberOfMe) {
        _memberOfMe = [[QCSDK shared].channelManager getMember:self.channel uid:[QCApp shared].loginInfo.uid];
    }
    return _memberOfMe;
}
-(BOOL) isManagerForMe {
    return self.memberOfMe && self.memberOfMe.role == QCMemberRoleManager;
}

-(BOOL) isCreatorForMe {
    return self.memberOfMe && self.memberOfMe.role == QCMemberRoleCreator;
}

-(BOOL) isManagerOrCreatorForMe {
    return [self isManagerForMe] || [self isCreatorForMe];
}

@end
