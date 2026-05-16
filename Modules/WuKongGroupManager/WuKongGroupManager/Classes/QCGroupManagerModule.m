//
//  QCGroupManagerModule.m
//  WuKongGroupManager
//
//  Created by tt on 2022/6/27.
//

#import "QCGroupManagerModule.h"
#import "QCGroupManagerVC.h"
#import "QCGroupAvatarVC.h"

@QCModule(QCGroupManagerModule)
@implementation QCGroupManagerModule

-(NSString*) moduleId {
    return @"WuKongGroupManager";
}

// 模块初始化
- (void)moduleInit:(QCModuleContext*)context{
    NSLog(@"【WuKongGroupManager】模块初始化！");
    __weak typeof(self) weakSelf = self;
    // 群管理
    [self setMethod:QCPOINT_GROUPMANAGER_SHOW handler:^id _Nullable(id  _Nonnull param) {
        QCGroupManagerVC *vc =  [QCGroupManagerVC new];
        vc.channel = [QCChannel fromMap:param];
        [[QCNavigationManager shared] pushViewController:vc animated:YES];
        return nil;
    }];
    
    [self setMethod:@"channelsetting.groupmanager" handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        BOOL isCreatorOrManager = [param[@"is_creator_or_manager"] boolValue];
        return @{
            @"height":@(0.0f),
            @"items": @[
                @{
                    @"class":QCLabelItemModel.class,
                    @"label":LLangW(@"群管理",weakSelf),
                    @"hidden": @(!isCreatorOrManager),
                    @"showBottomLine":@(NO),
                    @"bottomLeftSpace":isCreatorOrManager?@(0.0f):[NSNull null],
                    @"onClick":^{
                        [[QCApp shared] invoke:QCPOINT_GROUPMANAGER_SHOW param:[channel toMap]];

                    },
                }
            ]
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:89600];
    
    // 群头像
    [self setMethod:@"channelsetting.groupavatar" handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        return @{
            @"height":@(0.0f),
            @"items": @[
                @{
                    @"class":QCLabelItemModel.class,
                    @"label":LLangW(@"群聊头像",weakSelf),
                    @"showBottomLine":@(NO),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                        QCGroupAvatarVC *vc = [QCGroupAvatarVC new];
                        vc.groupNo = channel.channelId;
                        [[QCNavigationManager shared] pushViewController:vc animated:YES];
                    }
                },
            ],
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:89900];
    
    // 群备注
    [self setMethod:@"channelsetting.groupremark" handler:^id _Nullable(id  _Nonnull param) {
        QCChannel *channel = param[@"channel"];
        if(channel.channelType != WK_GROUP) {
            return nil;
        }
        QCChannelInfo *channelInfo = param[@"channel_info"];
        return @{
            @"height":@(0.0f),
            @"items": @[
                @{
                    @"class":QCLabelItemModel.class,
                    @"label":LLangW(@"群备注",weakSelf),
                    @"value":channelInfo && channelInfo.remark?channelInfo.remark:@"",
                    @"showBottomLine":@(NO),
                    @"showTopLine":@(NO),
                    @"onClick":^{
                        [weakSelf toSettingGroupRemark:channelInfo channel:channel];
                    }
                },
            ],
        };
    } category:QCPOINT_CATEGORY_CHANNELSETTING sort:89800];
}


-(void) toSettingGroupRemark:(QCChannelInfo*)channelInfo channel:(QCChannel*)channel{
    NSString *groupName = channelInfo?channelInfo.displayName:@"";
    QCInputVC *inputVC = [QCInputVC new];
    inputVC.title = LLang(@"修改群备注");
    inputVC.maxLength = 10;
    inputVC.placeholder = LLang(@"修改群备注");
    inputVC.defaultValue = groupName;
    [inputVC setOnFinish:^(NSString * _Nonnull value) {
        
        [[QCChannelSettingManager shared] channel:channel remark:value].then(^{
            [[QCNavigationManager shared] popViewControllerAnimated:YES];
        }).catch(^(NSError *error){
            [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
        });
       
    }];
    [[QCNavigationManager shared] pushViewController:inputVC animated:YES];
}


@end
