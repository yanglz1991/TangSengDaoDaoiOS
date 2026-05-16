//
//  QCMeInfoVM.m
//  QCCore
//
//  Created by tt on 2020/6/23.
//

#import "QCMeInfoVM.h"
#import "QCIconItemCell.h"
#import "QCMeAvatarCell.h"
#import "QCMeAvatarVC.h"
#import "QCMeQRCodeVC.h"
@implementation QCMeInfoVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    QCLoginInfo *loginInfo = [QCApp shared].loginInfo;
    NSString *sexName = LLang(@"男");
    NSInteger sex = 0;
    if(loginInfo.extra[@"sex"]) {
        sex = [loginInfo.extra[@"sex"] integerValue];
    }
    if(sex == 0) {
        sexName = LLang(@"女");
    }else if (sex == 1) {
        sexName = LLang(@"男");
    }else{
        sexName = LLang(@"未设置");
    }
    BOOL canSettingShortNo = false;
    if((loginInfo.extra[@"short_status"] && [loginInfo.extra[@"short_status"] boolValue]) || QCApp.shared.remoteConfig.shortnoEditOff) {
        canSettingShortNo = false;
    }else {
        canSettingShortNo = true;
    }
    __weak typeof(self) weakSelf = self;
    
    id onShortNoClick;
    if(!canSettingShortNo) {
        onShortNoClick = [NSNull null];
    }else {
        onShortNoClick = ^{
            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(meInfoVMUpdateShortNo:)]) {
                [weakSelf.delegate meInfoVMUpdateShortNo:weakSelf];
            }
        };
    }
    return @[
        @{
            @"height":@(0.1f),
            @"items":@[
                    @{
                        @"class":QCMeAvatarModel.class,
                        @"label":LLang(@"头像"),
                        @"onClick":^{
                            [[QCNavigationManager shared] pushViewController:[QCMeAvatarVC new] animated:YES];
                        }
                    },
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLang(@"名字"),
                        @"value":loginInfo.extra[@"name"]?:@"",
                        @"onClick":^{
                            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(meInfoVMUpdateName:)]) {
                                [weakSelf.delegate meInfoVMUpdateName:weakSelf];
                            }
                        }
                    },
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":[NSString stringWithFormat:LLang(@"%@号"),[QCApp shared].config.appName],
                        @"value":loginInfo.extra[@"short_no"]?:@"",
                        @"valueCopy":@(true),
                        @"showArrow":@(canSettingShortNo),
                        @"onClick":onShortNoClick,
                    },
                    @{
                         @"class":QCIconItemModel.class,
                         @"label":LLang(@"我的二维码"),
                         @"icon":[self imageName:@"Me/Index/Qrcode"],
                         @"width":@(24.0f),
                         @"height":@(24.0f),
                         @"onClick":^{
                             [[QCNavigationManager shared] pushViewController:[QCMeQRCodeVC new] animated:YES];
                         }
                    },
            ],
        },
        @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLang(@"性别"),
                        @"value":sexName,
                        @"onClick":^{
                            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(meInfoVMUpdateSex:)]) {
                                 [weakSelf.delegate meInfoVMUpdateSex:weakSelf];
                             }
                        }
                    },
            ],
        },
    ];
}

-(AnyPromise*) updateInfo:(NSString*)field value:(NSString*)value {
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:value forKey:field];
    return [[QCAPIClient sharedClient] PUT:@"user/current" parameters:paramDict];
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//    return [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}

@end
