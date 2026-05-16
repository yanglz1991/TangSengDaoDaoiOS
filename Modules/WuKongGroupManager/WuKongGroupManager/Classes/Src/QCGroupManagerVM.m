//
//  QCGroupManagerVM.m
//  WuKongBase
//
//  Created by tt on 2020/3/1.
//

#import "QCGroupManagerVM.h"
#import "QCTableSectionUtil.h"
#import "QCLabelItemCell.h"
#import "QCSwitchItemCell.h"
#import "QCManagerCell.h"
#import "QCAvatarUtil.h"
#import "QCModelConvert.h"
#import "QCGroupBlacklistVC.h"
#import "QCGroupApprovalListVC.h"
#import "QCNavigationManager.h"
@interface QCGroupManagerVM ()

@property(nonatomic,strong) NSArray<QCChannelMember*> *managerAndCreators; // 群里的管理员和创建者


// 频道信息
@property(nonatomic,strong) QCChannelInfo *channelInfo;

/**
 我在群里的信息
 */
@property(nullable,nonatomic,strong) QCChannelMember *memberOfMe;

@end

@implementation QCGroupManagerVM


- (NSArray<QCFormSection *> *)tableSections {
    NSMutableArray *sections = [NSMutableArray array];
    [sections addObjectsFromArray:self.getSectionMap];
    if(self.memberOfMe.role != QCMemberRoleCreator) {
        return [QCTableSectionUtil toSections:sections];
    }
    NSMutableArray *members = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    if(self.managerAndCreators) {
        int index = 0;
        for (QCChannelMember *member in self.managerAndCreators) {
            [members addObject:@{
                        @"class":QCManagerModel.class,
                        @"showBottomLine":@(NO),
                        @"showTopLine":@(NO),
                        @"showSub": member.role == QCMemberRoleCreator?@(NO):@(YES),
                        @"title":member.memberName?:@"",
                        @"onSub": ^{
                             [weakSelf deleteManager:member];
                        },
                        @"icon": member.memberAvatar && ![member.memberAvatar isEqualToString:@""] ?[QCAvatarUtil getFullAvatarWIthPath:member.memberAvatar]: [QCAvatarUtil getAvatar:member.memberUid],
                   }];
            index++;
        }
    }
    [members addObject:@{
                           @"class":QCManagerAddModel.class,
                           @"title":LLang(@"添加管理员"),
                           @"showBottomLine":@(NO),
                            @"bottomLeftSpace":@(0.0f),
                           @"showArrow":@(NO),
                           @"onClick":^{
                                [weakSelf toSelectManager];
                           }
                      }];
    [sections addObject:@{
         @"height":@(10.0f),
         @"title":LLang(@"群主、管理员"),
         @"items": members,
    }];
    return [QCTableSectionUtil toSections:sections];
}


-(void) deleteManager:(QCChannelMember*)member {
    if(_delegate && [_delegate respondsToSelector:@selector(didDeleteManager:manager:)]) {
        [_delegate didDeleteManager:self manager:member];
    }
}

// 去选择管理员
-(void) toSelectManager {
    NSMutableArray<QCContactsSelect*> *contactsSelects = [NSMutableArray array];
    for (QCChannelMember *member in self.members) {
        BOOL isManager = false;
        for (QCChannelMember *manager in self.managerAndCreators) {
            if([member.memberUid isEqualToString:manager.memberUid]) {
                isManager = true;
                continue;
            }
        }
        if(!isManager) {
            [contactsSelects addObject:[QCModelConvert toContactsSelect:member]];
        }
    }
    [[QCApp shared] invoke:QCPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*uids){
        [[QCGroupManager shared] groupNo:self.channel.channelId membersToManager:uids complete:^(NSError * _Nonnull error) {
            if(error) {
                [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
                return;
            }
            [[QCNavigationManager shared] popViewControllerAnimated:YES];
        }];
    },@"data":contactsSelects,@"title":LLang(@"选择管理员")}];
}

// 获取管理员数据
- (NSArray<QCChannelMember *> *)managerAndCreators {
    if(!_managerAndCreators) {
        _managerAndCreators = [[QCChannelMemberDB shared] getManagerAndCreator:self.channel];
    }
    return _managerAndCreators;
}

// 重新加载管理员数据
-(void) reloadManagerAndCreators {
    _managerAndCreators = [[QCChannelMemberDB shared] getManagerAndCreator:self.channel];
}

// 当前频道成员
-(NSArray<QCChannelMember*>*) members {
    if(!_members) {
        _members = [[QCChannelMemberDB shared] getMembersWithChannel:self.channel];
    }
    return _members;
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

// 当前频道信息
- (QCChannelInfo *)channelInfo {
    if(!_channelInfo) {
        _channelInfo = [[QCSDK shared].channelManager getChannelInfo:self.channel];
    }
    return _channelInfo;
}

-(void) reloadChannelInfo {
     _channelInfo = [[QCSDK shared].channelManager getChannelInfo:self.channel];
}

-(AnyPromise*) requestTransferGrouper:(NSString*)toUID {
   return [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/transfer/%@",self.channel.channelId,toUID] parameters:nil];
}


-(NSArray<NSDictionary*>*) getSectionMap {
    __weak typeof(self) weakSelf = self;
    return @[
        @{
             @"height":@(0.1f),
             @"remark":LLang( @"启用后，群成员需要群主或管理员确认才能邀请朋友进群。扫描二维码进群将同时停用。"),
             @"items":@[
                     @{
                          @"class":QCSwitchItemModel.class,
                          @"label":LLang(@"群聊邀请确认"),
                          @"on":@(self.channelInfo.invite),
                          @"bottomLeftSpace":@(0.0f),
                          @"showBottomLine":@(NO),
                          @"showTopLine":@(NO),
                          @"onSwitch":^(BOOL on){
                              [[QCGroupManager shared] groupSetting:weakSelf.channel.channelId settingKey:QCGroupSettingKeyInvite on:on];
                          }
                         
                     }
             ],
        },
        @{
             @"height":@(10.0f),
             @"remark":LLang(@"仅显示尚未审批的入群邀请，已拒绝的不再展示。点击进入可通过或拒绝。"),
             @"items":@[
                     @{
                          @"class":QCLabelItemModel.class,
                          @"label":LLang(@"审批记录"),
                          @"bottomLeftSpace":@(0.0f),
                          @"showBottomLine":@(NO),
                          @"showTopLine":@(NO),
                          @"onClick":^(QCFormItemModel *model, NSIndexPath *indexPath){
                              QCGroupApprovalListVC *vc = [QCGroupApprovalListVC new];
                              vc.channel = weakSelf.channel;
                              [[QCNavigationManager shared] pushViewController:vc animated:YES];
                          }
                     }
             ],
        },
        @{
             @"height":@(10.0f),
             @"items":@[
                     @{
                          @"class":QCLabelItemModel.class,
                          @"label":LLang(@"群主管理权转让"),
                          @"hidden": @(![self isCreatorForMe]),
                          @"showBottomLine":@(NO),
                          @"bottomLeftSpace":@(0.0f),
                          @"showTopLine":@(NO),
                          @"onClick":^{
                              [weakSelf transferGrouper];
                          }
                         
                     },
             ],
        },
        @{
                    @"height":@(10.0f),
                    @"title":LLang(@"成员设置"),
                    @"remark": LLang(@"全员禁言启用后，只允许群主和管理员发言。"),
                    @"items":@[
                            @{
                                 @"class":QCSwitchItemModel.class,
                                 @"label":LLang(@"全员禁言"),
                                  @"showTopLine":@(NO),
                                 @"showBottomLine":@(NO),
                                  @"on":@(self.channelInfo.forbidden),
                                 @"bottomLeftSpace":@(0.0f),
                                 @"onSwitch":^(BOOL on){
                                     [[QCGroupManager shared] groupSetting:self.channel.channelId settingKey:QCGroupSettingKeyForbidden on:on];
                                 }
                                
                            },
                    ],
            },
            @{
                    @"height":@(10.0f),
                    @"remark": LLang(@"开启后，群成员无法通过该群添加好友。"),
                    @"items":@[
                            @{
                                 @"class":QCSwitchItemModel.class,
                                 @"label":LLang(@"禁止群成员互加好友"),
                                  @"showTopLine":@(NO),
                                 @"showBottomLine":@(NO),
                                 @"on":self.channelInfo.extra[QCChannelExtraKeyForbiddenAddFriend]?:@(false),
                                 @"bottomLeftSpace":@(0.0f),
                                 @"onSwitch":^(BOOL on){
                                     [[QCGroupManager shared] groupSetting:self.channel.channelId settingKey:QCGroupSettingKeyForbiddenAddFriend on:on];
                                 }
                                
                            },
                    ],
            },
            @{
                @"height":@(10.0f),
                @"remark": LLang(@"开启后，新加入聊天的成员能看见以前的聊天记录。"),
                @"items":@[
                        @{
                             @"class":QCSwitchItemModel.class,
                             @"label":LLang(@"允许新成员查看历史消息"),
                              @"showTopLine":@(NO),
                             @"showBottomLine":@(NO),
                             @"on":self.channelInfo.extra[QCChannelExtraKeyAllowViewHistoryMsg]?:@(false),
                             @"bottomLeftSpace":@(0.0f),
                             @"onSwitch":^(BOOL on){
                                 [[QCGroupManager shared] groupSetting:self.channel.channelId settingKey:QCGroupSettingKeyAllowViewHistoryMsg on:on];
                             }
                            
                        },
                ],
            },
            @{
                    @"height":@(20.0f),
                    @"items":@[
                            @{
                                 @"class":QCLabelItemModel.class,
                                 @"label":LLang(@"群黑名单"),
                                 @"onClick":^{
                                     QCGroupBlacklistVC *vc = [QCGroupBlacklistVC new];
                                     vc.channel = weakSelf.channel;
                                     [[QCNavigationManager shared] pushViewController:vc animated:YES];
                                 }
                                
                            },
                    ],
            },
    ];
}


/// 转让群主
-(void) transferGrouper {
   if(_delegate && [_delegate respondsToSelector:@selector(didTransferGrouper:)]) {
         [_delegate didTransferGrouper:self];
     }
}
@end
