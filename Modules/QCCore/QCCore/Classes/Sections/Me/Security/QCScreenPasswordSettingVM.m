//
//  QCScreenPasswordSettingVM.m
//  QCCore
//
//  Created by tt on 2021/8/16.
//

#import "QCScreenPasswordSettingVM.h"

@implementation QCScreenPasswordSettingVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
 
    __weak typeof(self) weakSelf = self;
    NSNumber *lockAfterMinute =  [QCApp shared].loginInfo.extra[@"lock_after_minute"]?:@(0);
    NSString *lockScreenPwd = [QCApp shared].loginInfo.extra[@"lock_screen_pwd"];
    BOOL lockScreenOn = false;
    if(lockScreenPwd && ![lockScreenPwd isEqualToString:@""]) {
        lockScreenOn = true;
    }
    return @[
        @{
            @"height":@(15.0f),
            @"items":@[
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLang(@"自动锁定"),
                        @"value": [weakSelf getLockTimeDesc:lockAfterMinute.integerValue],
                        @"onClick":^{
                            [weakSelf.delegate screenPasswordSettingVMAutoLockDidClick:weakSelf];
                        }
                    },
            ],
        },
        @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLang(@"更改解锁密码"),
                        @"onClick":^{
                            [weakSelf.delegate screenPasswordSettingVMChangeLockDidClick:weakSelf];
                        }
                    },
            ],
        },
        @{
            @"height":@(15.0f),
            @"items":@[
                    @{
                        @"class":QCButtonItemModel.class,
                        @"title":LLang(@"关闭解锁密码"),
                        @"onClick":^{
                            [weakSelf.delegate screenPasswordSettingVMCloseLockDidClick:weakSelf];
                        }
                    }
            ],
        },
    ];
}

-(NSString*) getLockTimeDesc:(NSInteger)minute {
    NSString *timeStr;
    if(minute == 0) {
        timeStr = LLang(@"立即");
    }else if(minute>=60) {
        timeStr = LLang(@"离开1小时后");
    }else {
        timeStr =  [NSString stringWithFormat:LLang(@"离开%d分钟后"),minute];
    }
    return timeStr;
}

-(AnyPromise*) requestSetLockAfterMinute {
    NSNumber *lockAfterMinute =  [QCApp shared].loginInfo.extra[@"lock_after_minute"]?:@(0);
   return [[QCAPIClient sharedClient] PUT:@"user/lock_after_minute" parameters:@{
        @"lock_after_minute":lockAfterMinute,
    }];
}

-(AnyPromise*) requestCloseLock {
    return  [[QCAPIClient sharedClient] DELETE:@"user/lockscreenpwd" parameters:nil];
}

@end
