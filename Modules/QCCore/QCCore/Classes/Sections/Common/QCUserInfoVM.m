//
//  QCUserInfoVM.m
//  QCCore
//
//  Created by tt on 2020/6/19.
//

#import "QCUserInfoVM.h"
#import "QCLabelItemCell.h"
#import "QCTableSectionUtil.h"
#import "QCMultiLabelItemCell.h"
#import "QCForbiddenSpeakTimeSelectVC.h"
#import "QCCountdownFormItemCell.h"


@interface UserModel : QCModel

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *zone;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign) BOOL top;
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *shortNo;
@property (nonatomic, assign) BOOL chatPwdOn;
@property (nonatomic, assign) BOOL screenshot;
@property (nonatomic, assign) BOOL revokeRemind;
@property (nonatomic, assign) BOOL receipt;
@property (nonatomic, assign) BOOL online;
@property (nonatomic, assign) NSInteger lastOffline;
@property (nonatomic, assign) NSInteger deviceFlag;
@property (nonatomic, assign) BOOL follow;
@property (nonatomic, assign) BOOL beDeleted;
@property (nonatomic, assign) BOOL beBlacklist;
@property (nonatomic, strong) NSString *vercode;
@property (nonatomic, strong) NSString *sourceDesc;
@property (nonatomic, strong) NSString *remark;
@property (nonatomic, assign) NSInteger isUploadAvatar;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) BOOL robot;
@property (nonatomic, assign) BOOL isDestroy;
@property (nonatomic, assign) BOOL flame;
@property (nonatomic, assign) NSInteger flameSecond;

@end

@interface QCUserInfoVM ()<QCChannelManagerDelegate>

@property(nonatomic,strong) channelInfoCompletion completion;


@property(nonatomic,strong) NSMutableDictionary *contextDict;

@property(nonatomic,copy) NSString *introEndpointID;

@end

@implementation QCUserInfoVM

- (instancetype)init{
    self = [super init];
    if (self) {
        self.introEndpointID = @"user.info.intro";
        [[QCSDK shared].channelManager addDelegate:self];
        
        [self initItems];
        
    }
    return self;
}

-(void) initData {
    if(self.fromChannel) {
        self.memberOfMy = [[QCSDK shared].channelManager getMember:self.fromChannel uid:[QCApp shared].loginInfo.uid];
        self.memberOfUser = [[QCSDK shared].channelManager getMember:self.fromChannel uid:self.uid];
        self.fromChannelInfo = [[QCSDK shared].channelManager getChannelInfo:self.fromChannel];
        if(!self.fromChannelInfo) {
            [[QCSDK shared].channelManager fetchChannelInfo:self.fromChannel];
        }
        [self reloadData];
    }
}

- (void)dealloc{
     [[QCSDK shared].channelManager removeDelegate:self];
}

- (void)loadPersonChannelInfo:(NSString *)uid completion:(channelInfoCompletion)completion {
    self.completion = completion;
    self.uid = uid;
    
    __weak typeof(self) weakSelf = self;
    [self requestUserDetail:uid].then(^(UserModel *user){
        // 清空缓存的头像
        [[SDImageCache sharedImageCache] removeImageForKey:[QCAvatarUtil getAvatar:user.uid?:@""] withCompletion:nil];
        
        // 重新缓存用户的channelInfo
        QCChannelInfo *channelInfo = [weakSelf channelInfoFromUser:user];
        QCChannel *channel = [[QCChannel alloc] initWith:uid channelType:WK_PERSON];
        channelInfo.channel = channel;
        weakSelf.channelInfo = channelInfo;
        [[QCSDK shared].channelManager addOrUpdateChannelInfo:channelInfo];
        if(completion) {
             completion();
        }
    }).catch(^(NSError *err){
        [QCNavigationManager.shared.topViewController.view showHUDWithHide:err.domain];
    });
    
//    QCChannel *channel = [[QCChannel alloc] initWith:uid channelType:WK_PERSON];
//    QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:channel];
//    
//    if(channelInfo) {
//        self.channelInfo = channelInfo;
//        if(completion) {
//             completion();
//        }
//    }
//    // 远程提取频道信息
//    [[QCSDK shared].channelManager fetchChannelInfo:channel completion:^(QCChannelInfo * channelInfo) {
//        if(channelInfo) {
//            [[QCSDK shared].channelManager addOrUpdateChannelInfo:channelInfo];
//        }
//    }];
}

-(AnyPromise*) applyFriend:(NSString*)uid remark:(NSString*)remark vercode:(NSString*)vercode{
    return [[QCAPIClient sharedClient] POST:@"friend/apply" parameters:@{@"to_uid":uid?:@"",@"to_name":self.channelInfo.name?:@"",@"remark":remark?:@"",@"vercode":vercode?:@""}];
}

-(AnyPromise*) updateRemark:(NSString*)remark {
    return [[QCAPIClient sharedClient] PUT:@"friend/remark" parameters:@{@"uid":self.channelInfo.channel.channelId?:@"",@"remark":remark?:@""}];
}

-(AnyPromise*) deleteFriend {
     return [[QCAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"friends/%@",self.channelInfo.channel.channelId?:@""] parameters:nil];
}


-(AnyPromise*) addBlacklist {
    return [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"user/blacklist/%@",self.channelInfo.channel.channelId?:@""] parameters:nil];
}
-(AnyPromise*) deleteBlacklist {
    return [[QCAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"user/blacklist/%@",self.channelInfo.channel.channelId?:@""] parameters:nil];
}


-(void) initItems {
    __weak typeof(self) weakSelf = self;
    // 备注
    [[QCApp shared] setMethod:@"user.info.setRemark" handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[QCApp shared].loginInfo.uid]) {
            return nil;
        }
        // 从群成员列表进入个人详情页不显示「设置备注」入口（如需放开请删除下面 if 语句）
        if(weakSelf.fromChannel && weakSelf.fromChannel.channelType == WK_GROUP) {
            return nil;
        }
        return  @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLangW(@"设置备注",weakSelf),
                        @"onClick":^{
                            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoVMUpdateRemark:)]) {
                                [weakSelf.delegate userInfoVMUpdateRemark:weakSelf];
                            }
                        }
                    },
            ],
        };
    } category:QCPOINT_CATEGORY_USER_INFO_ITEM sort:4000];
    
    // 邀请信息（群成员资料页隐藏"进群方式"和加入时间）
    [[QCApp shared] setMethod:@"user.info.inviteInfo" handler:^id _Nullable(id  _Nonnull param) {
        return nil;
    } category:QCPOINT_CATEGORY_USER_INFO_ITEM sort:3999];
    
    // 个人禁言
    [[QCApp shared] setMethod:@"user.info.forbidden" handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[QCApp shared].loginInfo.uid]) {
            return nil;
        }
        QCChannelInfo *channelInfo = param[@"channel_info"];
        if(!channelInfo) {
            return nil;
        }
        if(!weakSelf.fromChannel || weakSelf.fromChannel.channelType == WK_PERSON) {
            return nil;
        }
        QCChannelMember *memberOfUser = weakSelf.memberOfUser;
        if(!memberOfUser) {
            return nil;
        }
        QCChannelMember *memberOfMy = weakSelf.memberOfMy;
        if(!memberOfMy) {
            return nil;
        }
        if(memberOfMy.role != QCMemberRoleManager && memberOfMy.role != QCMemberRoleCreator) {
            return nil;
        }
        NSInteger forbiddenExpirTime = 0; // 禁言失效时间
        if(memberOfUser.extra[@"forbidden_expir_time"]) {
            forbiddenExpirTime = [memberOfUser.extra[@"forbidden_expir_time"] integerValue];
        }
        
        return  @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":QCCountdownFormItemModel.class,
                        @"label":LLangW(@"群内禁言", weakSelf),
                        @"value": forbiddenExpirTime>0?LLang(@"禁言中"):@"",
                        @"second":@(forbiddenExpirTime),
                        @"onClick":^{
                            
                            QCChannelMember *member = [[QCSDK shared].channelManager getMember:weakSelf.fromChannel uid:uid];
                            if(member && member.extra[@"forbidden_expir_time"] && [member.extra[@"forbidden_expir_time"] intValue]>0) {
                                QCActionSheetView2 *sheet = [QCActionSheetView2 initWithTip:nil];
                                [sheet addItem:[QCActionSheetButtonItem2 initWithTitle:LLangW(@"解除禁言", weakSelf) onClick:^{
                                    UIView *topView = [QCNavigationManager shared].topViewController.view;
                                    [topView showHUD];
                                    [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/forbidden_with_member",weakSelf.fromChannel.channelId] parameters:@{
                                        @"member_uid":uid,
                                        @"action":@(0)
                                    }].then(^{
                                        // 解除禁言成功后主动同步群成员信息
                                        [[QCGroupManager shared] syncMemebers:weakSelf.fromChannel.channelId];
                                        
                                        // 发送群成员更新通知，触发 UI 刷新禁言状态
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [[NSNotificationCenter defaultCenter] postNotificationName:QCNOTIFY_GROUP_MEMBERUPDATE object:@{@"group_no":weakSelf.fromChannel.channelId}];
                                        });
                                        
                                        [topView hideHud];
                                        [[QCNavigationManager shared] popViewControllerAnimated:YES];
                                    }).catch(^(NSError *error){
                                        [topView hideHud];
                                        [topView showHUDWithHide:error.domain];
                                    });
                                }]];
                                [sheet show];
                                return;
                            }
                            
                            QCForbiddenSpeakTimeSelectVC *vc = [QCForbiddenSpeakTimeSelectVC new];
                            vc.channel = weakSelf.fromChannel;
                            vc.uid = uid;
                            [[QCNavigationManager shared] pushViewController:vc animated:YES];
                        }
                    },
            ],
        };
    } category:QCPOINT_CATEGORY_USER_INFO_ITEM sort:3990];
    
    // 解除好友关系
    [[QCApp shared] setMethod:@"user.info.freeFriend" handler:^id _Nullable(id  _Nonnull param) {
        QCChannelInfo *channelInfo = param[@"channel_info"];
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[QCApp shared].loginInfo.uid]) {
            return nil;
        }
        return  @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLangW(@"解除好友关系",weakSelf),
                        @"hidden": channelInfo.follow == QCChannelInfoFollowFriend?@(false):@(true),
                        @"onClick":^{
                            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoVMFreeFriend:)]) {
                                [weakSelf.delegate userInfoVMFreeFriend:weakSelf];
                            }
                        }
                    },
            ]
        };
    } category:QCPOINT_CATEGORY_USER_INFO_ITEM sort:3000];
    
    // 添加黑名单
    [[QCApp shared] setMethod:@"user.info.addBlack" handler:^id _Nullable(id  _Nonnull param) {
        QCChannelInfo *channelInfo = param[@"channel_info"];
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[QCApp shared].loginInfo.uid]) {
            return nil;
        }
        return  @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":channelInfo && channelInfo.status == QCChannelStatusBlacklist?LLangW(@"拉出黑名单", weakSelf):LLangW(@"拉入黑名单", weakSelf),
                        @"onClick":^{
                            if(self.channelInfo.status == QCChannelStatusBlacklist) {
                                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoVMRemoveBlacklist:)]) {
                                    [weakSelf.delegate userInfoVMRemoveBlacklist:weakSelf];
                                }
                            }else {
                                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoVMAddBlacklist:)]) {
                                    [weakSelf.delegate userInfoVMAddBlacklist:weakSelf];
                                }
                            }
                            
                        }
                    },
            ],
        };
    } category:QCPOINT_CATEGORY_USER_INFO_ITEM sort:2000];
    
    // 投诉
    [[QCApp shared] setMethod:@"user.info.report" handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[QCApp shared].loginInfo.uid]) {
            return nil;
        }
        return  @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLangW(@"投诉", weakSelf),
                        @"onClick":^{
                            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoVMReport:)]) {
                                [weakSelf.delegate userInfoVMReport:weakSelf];
                            }
                        }
                    },
            ],
        };
    } category:QCPOINT_CATEGORY_USER_INFO_ITEM sort:1000];
    
    // 来源
    [[QCApp shared] setMethod:@"user.info.source" handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[QCApp shared].loginInfo.uid]) {
            return nil;
        }
        QCChannelInfo *channelInfo = param[@"channel_info"];
        if(!channelInfo || (!channelInfo.extra[@"source_desc"] || [channelInfo.extra[@"source_desc"] isEqualToString:@""])) {
            return  nil;
        }
        return  @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":QCMultiLabelItemModel.class,
                        @"mode": @(QCMultiLabelItemModeLeftRight),
                        @"label":LLang(@"来源"),
                        @"value":channelInfo.extra[@"source_desc"]?:@"",
                    },
            ],
        };
    } category:QCPOINT_CATEGORY_USER_INFO_ITEM sort:900];
    
    
    // 功能介绍
    [[QCApp shared] setMethod:self.introEndpointID handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        
        NSString *intro;
        if([uid isEqualToString:QCApp.shared.config.fileHelperUID]) {
            intro = LLang(@"登录网页版本，向我发送消息，可以在手机与电脑间传输文字、图片、音频、视频等文件");
        }
        if([uid isEqualToString:QCApp.shared.config.systemUID]) {
            intro = [NSString stringWithFormat:@"%@官方用来发送一些通知的账号",QCApp.shared.config.appName];
        }
        if(!intro) {
            return nil;
        }
        return  @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":QCMultiLabelItemModel.class,
                        @"mode": @(QCMultiLabelItemModeLeftRight),
                        @"label":LLang(@"功能介绍"),
                        @"value":intro,
                    },
            ],
        };
    } category:QCPOINT_CATEGORY_USER_INFO_ITEM sort:900];
}


- (NSArray<NSDictionary *> *)tableSectionMaps {
    if(!self.channelInfo) {
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionaryWithDictionary:@{@"uid":self.uid?:@"",@"channel_info":self.channelInfo,@"reload":^{
        [weakSelf reloadData];
    },@"context":self.contextDict}];
    if(self.memberOfUser) {
        paramDict[@"memberOfUser"] = self.memberOfUser;
    }
    
    NSMutableArray<NSDictionary*> *items = [NSMutableArray array];
    
    NSArray<QCEndpoint*> *endpoints =  [QCApp.shared getEndpointsWithCategory:QCPOINT_CATEGORY_USER_INFO_ITEM];
    if(endpoints && endpoints.count>0) {
        for (QCEndpoint *endpoint in endpoints) {
            if([self isSystemAccount:self.uid] && ![endpoint.sid isEqualToString:self.introEndpointID]) {
                continue;
            }
            id result = endpoint.handler(paramDict);
            if(result) {
                [items addObject:result];
            }
        }
    }
    return items;
}

-(BOOL) isSystemAccount:(NSString*)uid {
    return [QCApp.shared isSystemAccount:uid];
}

- (NSMutableDictionary *)contextDict {
    if(!_contextDict) {
        _contextDict = [NSMutableDictionary dictionary];
    }
    return _contextDict;
}

- (BOOL)isBlacklist {
    return  self.channelInfo && self.channelInfo.status == QCChannelStatusBlacklist;
}

-(AnyPromise*) requestUserDetail:(NSString*)uid {
    NSString *groupNo = @"";
    if(self.fromChannel.channelType == WK_GROUP) {
        groupNo = self.fromChannel.channelId;
    }
    return [QCAPIClient.sharedClient GET:[NSString stringWithFormat:@"users/%@",uid] parameters:@{@"group_no":groupNo?:@""} model:UserModel.class];
}

- (QCChannelInfo *)channelInfoFromUser:(UserModel *)user {
    QCChannelInfo *info = [QCChannelInfo new];
    info.channel = [QCChannel personWithChannelID:user.uid];
    info.name = user.name;
    info.remark = user.remark;
    info.logo = user.vercode;  // Assuming 'vercode' is the logo
    info.stick = user.top;
    info.mute = user.mute;
    info.status = user.status;
    info.receipt = user.receipt;
    info.flame = user.flame;
    info.flameSecond = user.flameSecond;
    info.robot = user.robot;
    info.category = user.category;
    info.online = user.online;
    info.deviceFlag = user.deviceFlag;
    info.lastOffline = user.lastOffline;
    info.beDeleted = user.beDeleted;
    info.beBlacklist = user.beBlacklist;
    info.follow = user.follow;
    info.stick = user.top;
    
    info.logo = [NSString stringWithFormat:@"users/%@/avatar",user.uid];
    
    info.extra[@"sex"] = @(user.sex);
    
    [info setExtraValue:user.shortNo?:@"" forKey:QCChannelExtraKeyShortNo];
    [info setExtraValue:user.sourceDesc?:@"" forKey:QCChannelExtraKeySource];
    [info setExtraValue:user.vercode?:@"" forKey:QCChannelExtraKeyVercode];
    [info setSettingValue:user.screenshot forKey:QCChannelExtraKeyScreenshot];
    [info setSettingValue:user.revokeRemind forKey:QCChannelExtraKeyRevokeRemind];
    [info setSettingValue:user.chatPwdOn forKey:QCChannelExtraKeyChatPwd];
    return info;
}

#pragma mark - 事件
// 频道数据更新
-(void) channelInfoUpdate:(QCChannelInfo*)channelInfo {
    if(channelInfo.channel.channelType == WK_PERSON && [channelInfo.channel.channelId isEqualToString:self.uid] ) {
        self.channelInfo = channelInfo;
        if(self.completion) {
            self.completion();
        }
    }
}

@end


@implementation UserModel

+ (UserModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    UserModel *u = [UserModel new];
    u.uid = [dictory objectForKey:@"uid"] ?: @"";
    u.name = [dictory objectForKey:@"name"] ?: @"";
    u.username = [dictory objectForKey:@"username"] ?: @"";
    u.email = [dictory objectForKey:@"email"] ?: @"";
    u.zone = [dictory objectForKey:@"zone"] ?: @"";
    u.phone = [dictory objectForKey:@"phone"] ?: @"";
    u.mute = [[dictory objectForKey:@"mute"] boolValue];
    u.top = [[dictory objectForKey:@"top"] boolValue];
    u.sex = [[dictory objectForKey:@"sex"] integerValue];
    u.category = [dictory objectForKey:@"category"] ?: @"";
    u.shortNo = [dictory objectForKey:@"short_no"] ?: @"";
    u.chatPwdOn = [[dictory objectForKey:@"chat_pwd_on"] boolValue];
    u.screenshot = [[dictory objectForKey:@"screenshot"] boolValue];
    u.revokeRemind = [[dictory objectForKey:@"revoke_remind"] boolValue];
    u.receipt = [[dictory objectForKey:@"receipt"] boolValue];
    u.online = [[dictory objectForKey:@"online"] boolValue];
    u.lastOffline = [[dictory objectForKey:@"last_offline"] integerValue];
    u.deviceFlag = [[dictory objectForKey:@"device_flag"] integerValue];
    u.follow = [[dictory objectForKey:@"follow"] boolValue];
    u.beDeleted = [[dictory objectForKey:@"be_deleted"] boolValue];
    u.beBlacklist = [[dictory objectForKey:@"be_blacklist"] boolValue];
    u.vercode = [dictory objectForKey:@"vercode"] ?: @"";
    u.sourceDesc = [dictory objectForKey:@"source_desc"] ?: @"";
    u.remark = [dictory objectForKey:@"remark"] ?: @"";
    u.isUploadAvatar = [[dictory objectForKey:@"is_upload_avatar"] integerValue];
    u.status = [[dictory objectForKey:@"status"] integerValue];
    u.robot = [[dictory objectForKey:@"robot"] boolValue];
    u.isDestroy = [[dictory objectForKey:@"is_destroy"] boolValue];
    u.flame = [[dictory objectForKey:@"flame"] boolValue];
    u.flameSecond = [[dictory objectForKey:@"flame_second"] integerValue];
    return u;
}




@end
