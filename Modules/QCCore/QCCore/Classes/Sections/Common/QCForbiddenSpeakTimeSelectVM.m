//
//  QCForbiddenSpeakTimeSelectVM.m
//  QCCore
//
//  Created by tt on 2022/3/25.
//

#import "QCForbiddenSpeakTimeSelectVM.h"

@interface QCForbiddenSpeakTimeSelectVM ()

@property(nonatomic,assign) NSInteger selectedIndex;


@end

@implementation QCForbiddenSpeakTimeSelectVM


-(NSDictionary*) getTimeLabelItem:(NSString*)time selected:(BOOL)selected onClick:(void(^)(void)) onClick{
    
    return @{
        @"class":QCLabelItemSelectModel.class,
        @"label":time,
        @"showArrow": @(false),
        @"selected": @(selected),
        @"onClick":onClick,
    };
}

- (NSArray<NSDictionary *> *)tableSectionMaps {
    
    NSArray *timeItems = @[@[LLang(@"1分钟"),@(60)],@[LLang(@"10分钟"),@(60*10)],@[LLang(@"1小时"),@(60*60)],@[LLang(@"1天"),@(60*60*24)],@[LLang(@"7天"),@(60*60*24*7)],@[LLang(@"30天"),@(60*60*24*30)]];
    if(self.selectSeconds <= 0) {
        self.selectSeconds = ((NSNumber*)timeItems[0][1]).intValue;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    BOOL isCustom = true;
    for(NSInteger i=0;i<timeItems.count;i++) {
        NSArray *times =  timeItems[i];
        NSInteger second = ((NSNumber*)times[1]).intValue;
        __weak typeof(self) weakSelf = self;
        BOOL selected = self.selectSeconds == second;
        if(selected) {
            isCustom = false;
            self.selectedIndex = i;
        }
        [items addObject: [self getTimeLabelItem:times[0] selected:selected onClick:^{
            weakSelf.selectSeconds = second;
            [weakSelf reloadData];
        }]];
    }
    NSString *customTime = @"";
    if(isCustom && self.selectSeconds>0) {
        NSInteger day = self.selectSeconds/(60*60*24);
        NSInteger hour = (self.selectSeconds%(60*60*24))/(60*60);
        NSInteger minute = ((self.selectSeconds%(60*60*24))%(60*60))/60;
        if(day<=0 && hour <=0) {
            customTime = [NSString stringWithFormat:@"%ld分钟",(long)minute];
        }else if(day<=0 && hour>0) {
            customTime = [NSString stringWithFormat:@"%ld小时%ld分",(long)hour,(long)minute];
        }else if(day>0) {
            customTime = [NSString stringWithFormat:@"%ld天%ld小时%ld分",(long)day,(long)hour,(long)minute];
        }
    }
    __weak typeof(self) weakSelf = self;
//    [items addObject: @{
//        @"class":QCLabelItemSelectModel.class,
//        @"label":LLang(@"自定义"),
//        @"value": customTime,
//        @"showArrow": @(false),
//        @"onClick":^{
//            [self.delegate forbiddenSpeakTimeSelectVMDidCustomTime:self];
//        }
//    }];
    
    return @[
        @{
            @"height":@(0.0f),
            @"items": items,
        },
        @{
            @"height":@(20.0f),
            @"items": @[
                @{
                    @"class":QCButtonItemModel2.class,
                    @"title":LLang(@"确认"),
                    @"onPressed":^{
                        [weakSelf requestForbidden];
                    }
                }
            ],
        }
    ];
}

-(void) requestForbidden {
    UIView *topView = [QCNavigationManager shared].topViewController.view;
    [topView showHUD];
    [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/forbidden_with_member",self.channel.channelId] parameters:@{
        @"member_uid":self.uid,
        @"action":@(1),
        @"key": @(self.selectedIndex+1),
    }].then(^{
        // 设置成功后主动同步群成员信息
        [[QCGroupManager shared] syncMemebers:self.channel.channelId];
        
        // 发送群成员更新通知，触发 UI 刷新禁言状态
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:QCNOTIFY_GROUP_MEMBERUPDATE object:@{@"group_no":self.channel.channelId}];
        });
        
        [topView hideHud];
        [[QCNavigationManager shared] popViewControllerAnimated:YES];
    }).catch(^(NSError *error){
        [topView hideHud];
        [topView showHUDWithHide:error.domain];
    });
}


@end
