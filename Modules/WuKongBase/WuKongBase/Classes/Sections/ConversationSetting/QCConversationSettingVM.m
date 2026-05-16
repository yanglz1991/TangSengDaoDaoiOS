//
//  QCConversationSettingVM.m
//  WuKongBase
//
//  Created by tt on 2020/1/21.
//

#import "QCConversationSettingVM.h"
#import "WuKongBase.h"
#import "QCFormItemModel.h"
#import "QCFormSection.h"
#import "QCLabelItemCell.h"
#import "QCSwitchItemCell.h"
#import "QCIconItemCell.h"
#import "QCResource.h"
#import "QCGroupManager.h"
#import "QCButtonItemCell.h"
#import "QCMultiLabelItemCell.h"
#import "QCTableSectionUtil.h"
#import "QCGroupQRCodeVC.h"
#import "QCGlobalSearchResultController.h"

@interface QCConversationSettingVM ()<QCChannelManagerDelegate>

@property(nonatomic,strong) QCChannelInfo *_channelInfo;

@end

@implementation QCConversationSettingVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[QCSDK shared].channelManager addDelegate:self];
        
    }
    return self;
}

- (void)dealloc {
    [[QCSDK shared].channelManager removeDelegate:self];
}

-(void) syncMembersIfNeed{
    if(self.channel.channelType == WK_GROUP) {
        [[QCGroupManager shared] syncMemebers:self.channel.channelId];
    }
    
}


- (NSArray<NSDictionary *> *)tableSectionMaps {
    BOOL isCreatorOrManager = [self isManagerOrCreatorForMe];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"channel"] = self.channel;
    param[@"is_creator_or_manager"] = @(isCreatorOrManager);
    if(self.channelInfo) {
        param[@"channel_info"] = self.channelInfo;
    }
    param[@"refresh"] = ^ {
        [self reloadData];
    };
    param[@"context"] = self.context;
    [self registerSections];
    NSArray *items = [QCApp.shared invokes:QCPOINT_CATEGORY_CHANNELSETTING param:param];
    return items;
}

//-(NSArray<QCFormSection*>*) settingSections {
//    if(!_settingSections) {
//        if(self.channel.channelType == WK_GROUP) {
//             _settingSections = [QCTableSectionUtil toSections:[self groupSettingItems]];
//        }else {
//             _settingSections = [QCTableSectionUtil toSections:[self personSettingItems]];
//        }
//       
//    }
//    return _settingSections;
//}

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


- (NSInteger)memberCount {
    if(self.groupType == QCGroupTypeSuper) {
        return [self memberCount:self.channelInfo];
    }else {
        return [[QCSDK shared].channelManager getMemberCount:self.channel];
    }
    return 0;
}

-(NSInteger) memberCount:(QCChannelInfo*)channelInfo {
    if(channelInfo && channelInfo.extra[@"member_count"]) {
        return [channelInfo.extra[@"member_count"] integerValue];
    }
    return 0;
}

- (QCMemberRole)memberRole {
    if(self.groupType == QCGroupTypeSuper) {
        if(self.channelInfo && self.channelInfo.extra[@"role"]) {
            return [self.channelInfo.extra[@"role"] integerValue];
        }
    }else {
        QCChannelMember *memberOfMe = self.memberOfMe;
        if(memberOfMe) {
            return  memberOfMe.role;
        }
    }
    return QCMemberRoleCommon;
}

-(QCGroupType) groupType {
    
    return [self groupType:self.channelInfo];
}

-(QCGroupType) groupType:(QCChannelInfo*)channelInfo {
    return [QCChannelUtil groupType:channelInfo];
}

-(void) registerSections {
    __weak typeof(self) weakSelf = self;
    
    // 是否有公告
    BOOL hasNotice  = self.channelInfo && self.channelInfo.notice && ![self.channelInfo.notice isEqualToString:@""];
    
    

    
    // 在群内的名字
    NSString *nameInGroup = self.memberOfMe.memberName;
    if(self.memberOfMe.memberRemark && ![self.memberOfMe.memberRemark isEqualToString:@""]) {
        nameInGroup = self.memberOfMe.memberRemark;
    }
    
    [[QCApp shared] setMethod:@"channelsetting.groupname" handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        return @{
            @"height":QCSectionHeight,
            @"items": @[
                @{
                    @"class":QCLabelItemModel.class,
                    @"label":LLang(@"群聊名称"),
                    @"value":self.channelInfo&&self.channelInfo.name?self.channelInfo.name:@"",
                    @"showBottomLine":@(NO),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(settingOnGroupNameClick:)]) {
                            [weakSelf.delegate settingOnGroupNameClick:weakSelf];
                        }
                    }
                }
            ],
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:90000];
    
    
    [[QCApp shared] setMethod:@"channelsetting.groupqrcode" handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        return @{
            @"height": @(0.0f),
            @"items":@[
                @{
                    @"class":QCIconItemModel.class,
                    @"label":LLang(@"群二维码"),
                    @"icon":[self imageName:@"Conversation/Setting/IconQrcode"],
                    @"width":@(24.0f),@"height":@(24.0f),
                    @"showBottomLine":@(NO),
                    @"onClick":^{
                        QCGroupQRCodeVC *vc = [QCGroupQRCodeVC new];
                        vc.channel = weakSelf.channel;
                        [[QCNavigationManager shared] pushViewController:vc animated:YES];
                    }
                }
            ],
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:89800];
    
    [[QCApp shared] setMethod:@"channelsetting.groupintro" handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        BOOL isCreatorOrManager = [param[@"is_creator_or_manager"] boolValue];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        return @{
            @"height":@(0.0f),
            @"items": @[
                @{
                    @"class": hasNotice?QCMultiLabelItemModel.class:QCLabelItemModel.class,
                    @"label":LLang(@"群公告"),
                    @"value": hasNotice?self.channelInfo.notice:LLang(@"未设置"),
                    @"showBottomLine":@(NO),
                    @"bottomLeftSpace": isCreatorOrManager?[NSNull null]:@(0.0f),
                    @"onClick":^{
                        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(settingOnGroupNoticeClick:)]) {
                            [weakSelf.delegate settingOnGroupNoticeClick:weakSelf];
                        }
                    }
                }
            ]
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:89700];
    
    
    [[QCApp shared] setMethod:@"channelsetting.hsitory" handler:^id _Nullable(id  _Nonnull param) {
        return @{
            @"height":QCSectionHeight,
            @"items":@[
                @{
                    @"class":QCLabelItemModel.class,
                    @"label":LLang(@"查找聊天内容"),
                    @"showBottomLine":@(NO),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                        QCGlobalSearchResultController *vc = [QCGlobalSearchResultController new];
                        vc.channel = weakSelf.channel;
                        [[QCNavigationManager shared] pushViewController:vc animated:NO];
                    }
                }
            ]
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:89600];
    
    
    [[QCApp shared] setMethod:@"channelsetting.mute" handler:^id _Nullable(id  _Nonnull param) {
        return @{
            @"height":QCSectionHeight,
            @"items":@[
                @{
                    @"class":QCSwitchItemModel.class,
                    @"label":LLang(@"消息免打扰"),
                    @"on":@(self.channelInfo?self.channelInfo.mute:false),
                    @"showBottomLine":@(NO),
                    @"showTopLine":@(NO),
                    @"onSwitch":^(BOOL on){
                        [[QCChannelSettingManager shared] channel:self.channel mute:on];
                    }
                }
            ]
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:89500];
    
    [[QCApp shared] setMethod:@"channelsetting.top" handler:^id _Nullable(id  _Nonnull param) {
        return @{
            @"height":@(0.0f),
            @"items":@[
                @{
                    @"class":QCSwitchItemModel.class,
                    @"label":LLang(@"置顶聊天"),
                    @"on":@(self.channelInfo?self.channelInfo.stick:false),
                    @"showBottomLine":@(NO),
                    @"onSwitch":^(BOOL on){
                        [[QCChannelSettingManager shared] channel:self.channel stick:on];
                    }
                }
            ]
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:89400];
    
    [[QCApp shared] setMethod:@"channelsetting.groupsave" handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        return @{
            @"height":@(0.0f),
            @"items":@[
                @{
                    @"class":QCSwitchItemModel.class,
                    @"label":LLang(@"保存到通讯录"),
                    @"on":@(self.channelInfo?self.channelInfo.save:false),
                    @"showBottomLine":@(NO),
                    @"bottomLeftSpace":@(0.0f),
                    @"onSwitch":^(BOOL on){
                        [[QCChannelSettingManager shared] group:self.channel.channelId save:on];

                    }
                }
            ]
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:89300];
    
    
    
   
    
    // 去掉"我在本群的昵称"设置入口
    [[QCApp shared] setMethod:@"channelsetting.nameInGroup" handler:^id _Nullable(id  _Nonnull param) {
        return nil;
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:89100];
    
   
    
    [[QCApp shared] setMethod:@"channelsetting.report" handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        if(channel.channelType != WK_PERSON) {
            return nil;
        }
        return  @{
            @"height":QCSectionHeight,
            @"items":@[
                @{
                    @"class":QCLabelItemModel.class,
                    @"label":self.channelInfo && self.channelInfo.status == QCChannelStatusBlacklist?LLangW(@"拉出黑名单", weakSelf):LLangW(@"拉入黑名单", weakSelf),
                    @"value":@"",
                    @"showBottomLine":@(NO),
                    @"bottomLeftSpace":@(0.0f),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(settingOnBlacklist:action:)]) {
                           [weakSelf.delegate settingOnBlacklist:weakSelf action:self.channelInfo && self.channelInfo.status != QCChannelStatusBlacklist];
                       }
                    }},
               ]

        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:88800];
    
    [[QCApp shared] setMethod:@"channelsetting.report" handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        CGFloat sectionHeight = 0.0f;
        if(channel.channelType == WK_GROUP) {
            sectionHeight = QCSectionHeight.floatValue;
        }
        return  @{
            @"height":@(sectionHeight),
            @"items":@[
                @{
                    @"class":QCLabelItemModel.class,
                    @"label":LLang(@"投诉"),
                    @"value":@"",
                    @"showBottomLine":@(NO),
                    @"bottomLeftSpace":@(0.0f),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                       if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(settingOnReport:)]) {
                           [weakSelf.delegate settingOnReport:weakSelf];
                       }
                    }
                },
               ]

        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:88900];
    
    [[QCApp shared] setMethod:@"channelsetting.clearchat" handler:^id _Nullable(id  _Nonnull param) {
        return  @{
            @"height":QCSectionHeight,
            @"items":@[
                @{
                    @"class":QCButtonItemModel.class,
                    @"title":LLang(@"清空聊天记录"),
                    @"showBottomLine":@(NO),
                    @"bottomLeftSpace":@(0.0f),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(settingOnClearMessages:)]) {
                            [weakSelf.delegate settingOnClearMessages:weakSelf];
                        }
                    }
                },
               ]

        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:88800];
    
    [[QCApp shared] setMethod:@"channelsetting.groupexit" handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        return  @{
            @"height":@(0.0f),
            @"items":@[
                @{
                    @"class":QCButtonItemModel.class,
                    @"title":LLang(@"删除并退出"),
                    @"showBottomLine":@(NO),
                    @"bottomLeftSpace":@(0.0f),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                           if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(settingOnGroupExit:)]) {
                               [weakSelf.delegate settingOnGroupExit:weakSelf];
                           }
                    }
                },
               ]
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:88700];
}


-(AnyPromise*) addBlacklist {
    return [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"user/blacklist/%@",self.channelInfo.channel.channelId?:@""] parameters:nil];
}
-(AnyPromise*) deleteBlacklist {
    return [[QCAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"user/blacklist/%@",self.channelInfo.channel.channelId?:@""] parameters:nil];
}


-(AnyPromise*) onlineMembers:(NSArray<NSString*>*)users {
    __weak typeof(self) weakSelf = self;
  return  [QCAPIClient.sharedClient POST:@"user/online" parameters:users model:QCUserOnlineResp.class].then(^(NSArray<QCUserOnlineResp*>*onlines){
      weakSelf.onlineMembers = onlines;
      return onlines;
    });
}

-(QCUserOnlineResp*) memberOnline:(NSString*)uid {
    if(!self.onlineMembers || self.onlineMembers.count == 0) {
        return nil;
    }
    for (QCUserOnlineResp *onlineResp in self.onlineMembers) {
        if([onlineResp.uid isEqualToString:uid]) {
            return onlineResp;
        }
    }
    return nil;
}


-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
}

- (QCChannelInfo *)channelInfo {
    if(!self._channelInfo) {
        self._channelInfo = [[QCSDK shared].channelManager getChannelInfo:self.channel];
    }
    return self._channelInfo;
}

-(AnyPromise*) requestGroupMemberInvite:(NSArray<NSString*>*)uids remark:(NSString*)remark {
   return [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/member/invite",self.channel.channelId] parameters:@{@"uids":uids?:@[],@"remark":remark?:@""}];
}

#pragma mark - QCChannelManagerDelegate
- (void)channelInfoUpdate:(QCChannelInfo *)channelInfo oldChannelInfo:(QCChannelInfo * _Nullable)oldChannelInfo{
    if(![self.channel isEqual:channelInfo.channel]) {
        return;
    }
    self._channelInfo = [[QCSDK shared].channelManager getChannelInfo:self.channel];
    [self reloadData];
    if(_delegate && [_delegate respondsToSelector:@selector(settingOnChannelUpdate:)]) {
        [_delegate settingOnChannelUpdate:self];
    }
    QCGroupType groupType = [self groupType:channelInfo];
    if(groupType == QCGroupTypeSuper) {
        if(oldChannelInfo && [self memberCount:oldChannelInfo]!=[self memberCount:channelInfo]) {
            if(_delegate && [_delegate respondsToSelector:@selector(settingOnTopNMembersUpdate:)]) {
                [_delegate settingOnTopNMembersUpdate:self];
            }
        }
     
    }
}
@end


