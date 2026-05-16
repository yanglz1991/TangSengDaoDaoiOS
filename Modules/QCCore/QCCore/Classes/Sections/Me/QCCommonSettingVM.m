//
//  QCCommonSettingVM.m
//  QCCore
//
//  Created by tt on 2020/6/21.
//

#import "QCCommonSettingVM.h"
#import "QCDarkModeVC.h"
//#import <FLEX/FLEX.h>
#import "QCLanguageVC.h"
#import "NSString+QCLocalized.h"
#import "QCModuleVC.h"
#import "QCSecureChannelMenu.h"
#import "QCSecureChannelManager.h"

@interface QCCommonSettingVM ()

@property(nonatomic,strong) NSMutableDictionary *param;

@end

@implementation QCCommonSettingVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self registerItems];
            [QCSecureChannelMenu registerSecureChannelMenu];
        });
        // 每次进入"通用"页都刷新一次加密通道配置
        __weak typeof(self) weakSelf = self;
        [[QCSecureChannelManager shared] refreshConfig:^(BOOL enabled, NSString * _Nonnull name) {
            [weakSelf reloadData];
        }];
    }
    return self;
}

-(void) registerItems {
    // 深色模式
    [[QCApp shared] setMethod:@"commonsetting.notify" handler:^id _Nullable(id  _Nonnull param) {
        BOOL supportDarkMode = NO;
        if (@available(iOS 13.0, *)) {
            supportDarkMode = YES;
        }
        NSString *darkDesc = LLang(@"打开");
        if([QCApp shared].config.darkModeWithSystem) {
            darkDesc = LLang(@"跟随系统");
        }else {
            darkDesc = QCApp.shared.config.style == QCSystemStyleDark?LLang(@"打开"):LLang(@"关闭");
        }
        return  @{
            @"height":QCSectionHeight,
            @"items":@[
                @{
                    @"class":QCLabelItemModel.class,
                    @"label":LLang(@"深色模式"),
                    @"value": darkDesc?:@"",
                    @"hidden":@(!supportDarkMode),
                    @"onClick":^{
                        
                        QCDarkModeVC *vc = [QCDarkModeVC new];
                        [[QCNavigationManager shared] pushViewController:vc animated:YES];
                        
                    }
                },
               ]

        };
    } category:QCPOINT_CATEGORY_COMMONSETTING sort:90000];
    
    // 清除缓存
    [[QCApp shared] setMethod:@"commonsetting.clearcache" handler:^id _Nullable(NSMutableDictionary   *param) {
        void(^reloadData)(void)  = param[@"reloadData"];
      
        BOOL cacheLoaded = false;
        NSUInteger cacheSize = 0;
        if(param[@"cacheLoaded"] && [param[@"cacheLoaded"] boolValue]) {
            cacheLoaded =  true;
            cacheSize = [ param[@"cacheSize"] intValue];
        }
        
        if(!cacheLoaded) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                NSUInteger cacheSize = [[SDImageCache sharedImageCache] totalDiskSize];
                NSError *err;
                unsigned long long videoCacheSize =  [QCApp.shared calculateVideoCachedSizeWithError:&err];
                cacheSize += videoCacheSize;
                
                cacheSize += [[QCSDK shared].mediaManager messageCacheSize];
                
                param[@"cacheSize"] = @(cacheSize);
                param[@"cacheLoaded"]=@(true);
                dispatch_async(dispatch_get_main_queue(), ^{
                    reloadData();
                });
                
            });
        }
        
        return  @{
            @"height":@(0.0f),
            @"items":@[
                @{
                    @"class":QCLabelItemModel.class,
                    @"label":LLang(@"清空图片/视频缓存"),
                    @"value": [self fileSizeWithInterge:cacheSize],
                    @"onClick":^{
                        QCActionSheetView2 *actionSheetView = [QCActionSheetView2 initWithTip:LLang(@"是否清除缓存")];
                        [actionSheetView addItem:[QCActionSheetButtonItem2 initWithAlertTitle:LLang(@"清空缓存") onClick:^{
                            [QCApp.shared cleanVideoCache]; // 清空视频缓存
                            
                            [[QCSDK shared].mediaManager cleanMessageCache]; // 消息缓存
                            // 清空图片缓存
                            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                                param[@"cacheLoaded"]=@(false);
                                reloadData();
                            }];
                           
                        }]];
                        [actionSheetView show];
                    }
                },
               ]

        };
    } category:QCPOINT_CATEGORY_COMMONSETTING sort:80000];
    
    // 聊天备份和恢复
//    [[QCApp shared] setMethod:@"commonsetting.chatbackup" handler:^id _Nullable(id  _Nonnull param) {
//        
//        return  @{
//            @"height":QCSectionHeight,
//            @"items":@[
//                    @{
//                        @"class":QCLabelItemModel.class,
//                        @"label":LLang(@"聊天记录备份"),
//                        @"onClick":^{
//                            QCChatBackupVC *vc = [[QCChatBackupVC alloc] init];
//                            [QCNavigationManager.shared pushViewController:vc animated:YES];
//                        }
//                    },
//                    @{
//                        @"class":QCLabelItemModel.class,
//                        @"label":LLang(@"聊天记录恢复"),
//                        @"onClick":^{
//                            QCChatRecoverVC *vc = [[QCChatRecoverVC alloc] init];
//                            [QCNavigationManager.shared pushViewController:vc animated:YES];
//                        }
//                    },
//            ],
//        };
//    } category:QCPOINT_CATEGORY_COMMONSETTING sort:79000];
    
    // 多语言
    [[QCApp shared] setMethod:@"commonsetting.lang" handler:^id _Nullable(id  _Nonnull param) {
        BOOL supportDarkMode = NO;
        if (@available(iOS 13.0, *)) {
            supportDarkMode = YES;
        }
        NSString *darkDesc = LLang(@"打开");
        if([QCApp shared].config.darkModeWithSystem) {
            darkDesc = LLang(@"跟随系统");
        }else {
            darkDesc = QCApp.shared.config.style == QCSystemStyleDark?LLang(@"打开"):LLang(@"关闭");
        }
        
        return  @{
            @"height":QCSectionHeight,
            @"items":@[
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLang(@"多语言"),
                        @"onClick":^{
                            QCLanguageVC *vc = [QCLanguageVC new];
                            [[QCNavigationManager shared] pushViewController:vc animated:YES];
                        }
                    },
            ],
        };
    } category:QCPOINT_CATEGORY_COMMONSETTING sort:70000];
    
    // 模块
    [[QCApp shared] setMethod:@"commonsetting.modules" handler:^id _Nullable(id  _Nonnull param) {
        // 隐藏「功能模块」入口（如需放开请删除下面这行 return nil）
        return nil;
        return  @{
            @"height":QCSectionHeight,
            @"items":@[
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLang(@"功能模块"),
                        @"onClick":^{
                            QCModuleVC *vc = [QCModuleVC new];
                            [[QCNavigationManager shared] pushViewController:vc animated:YES];
                        }
                    },
            ],
        };
    } category:QCPOINT_CATEGORY_COMMONSETTING sort:69000];
    
    // 版本信息
    [[QCApp shared] setMethod:@"commonsetting.version" handler:^id _Nullable(id  _Nonnull param) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        
        return @{
            @"height":QCSectionHeight,
            @"items":@[
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLang(@"版本信息"),
                        @"value":appVersion?:@"",
                        @"onClick":^{
                            if (@available(iOS 10.0, *)) {
                                if([QCApp shared].config.appID && ![[QCApp shared].config.appID isEqualToString:@""]) {
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/us/app/id/%@",[QCApp shared].config.appID]] options:@{} completionHandler:nil];
                                }
                               
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    },
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLang(@"用户协议"),
                        @"onClick":^{
                            QCWebViewVC *vc = [[QCWebViewVC alloc] init];
                            vc.url = [NSURL URLWithString:QCApp.shared.config.userAgreementUrl];
                            [QCNavigationManager.shared pushViewController:vc animated:YES];
                        }
                    },
                    @{
                        @"class":QCLabelItemModel.class,
                        @"label":LLang(@"隐私政策"),
                        @"onClick":^{
                            QCWebViewVC *vc = [[QCWebViewVC alloc] init];
                            vc.url = [NSURL URLWithString:QCApp.shared.config.privacyAgreementUrl];
                            [QCNavigationManager.shared pushViewController:vc animated:YES];
                        }
                    },
            ],
        };
    } category:QCPOINT_CATEGORY_COMMONSETTING sort:60000];
    
    
    // 退出登陆
    [[QCApp shared] setMethod:@"commonsetting.logout" handler:^id _Nullable(id  _Nonnull param) {
        __weak typeof(self) weakSelf = self;
        return  @{
            @"height":QCSectionHeight,
            @"items":@[
                    @{
                        @"class":QCButtonItemModel.class,
                        @"title":LLang(@"退出登录"),
                        @"onClick":^{
                            QCActionSheetView2 *actionSheetView = [QCActionSheetView2 initWithTip:LLangW(@"退出后不会删除任何历史数据，下次登录依然可以使用本账号。",weakSelf)];
                            [actionSheetView addItem:[QCActionSheetButtonItem2 initWithAlertTitle:LLangW(@"退出登录",weakSelf) onClick:^{
                                [actionSheetView hide];
                                [[QCApp shared] logout];
                            }]];
                            [actionSheetView show];
                        }
                    },
            ],
        };
    } category:QCPOINT_CATEGORY_COMMONSETTING sort:100];
}

- (NSArray<NSDictionary *> *)tableSectionMaps {
    __weak typeof(self) weakSelf = self;
    if(!self.param) {
        self.param = [NSMutableDictionary dictionaryWithDictionary:@{@"reloadData":^{
            [weakSelf reloadData];
        } }];
    }
   
    return  [QCApp.shared invokes:QCPOINT_CATEGORY_COMMONSETTING param:self.param];
    
}

//计算出大小
- (NSString *)fileSizeWithInterge:(NSInteger)size{
    if(size<1024) {
        return [NSString stringWithFormat:@"%ldB",(long)size];
    }else if (size < 1024 * 1024){// 小于1m
        CGFloat aFloat = size/1024;
        return [NSString stringWithFormat:@"%.0fK",aFloat];
    }else if (size < 1024 * 1024 * 1024){// 小于1G
        CGFloat aFloat = size/(1024 * 1024);
        return [NSString stringWithFormat:@"%.1fM",aFloat];
    }else{
        CGFloat aFloat = size/(1024*1024*1024);
        return [NSString stringWithFormat:@"%.1fG",aFloat];
    }
}
@end
