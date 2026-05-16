//
//  QCModuleVM.m
//  QCCore
//
//  Created by tt on 2023/2/23.
//

#import "QCModuleVM.h"

@implementation QCModuleVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    __weak typeof(self) weakSelf = self;
    if(!QCApp.shared.remoteConfig.requestAppModuleSuccess) {
        [QCApp.shared.remoteConfig requestConfig:^(NSError * _Nullable error) {
            [weakSelf reloadData];
        }];
    }
    NSArray<QCAppModuleResp*> *modules = QCApp.shared.remoteConfig.modules;
    
    NSMutableArray<NSDictionary*> *items = [NSMutableArray array];
    if(modules && modules.count>0) {
        for (QCAppModuleResp *resp in modules) {
            if(resp.hidden) {
                continue;
            }
            BOOL disable = false;
            BOOL on = false;
            if(resp.status == QCAppModuleStatusDisable) {
                on = false;
                disable = true;
            }else if(resp.status == QCAppModuleStatusEdit) {
                on = true;
                disable = false;
            }else if(resp.status == QCAppModuleStatusNoEdit) {
                on = true;
                disable = true;
            }
            if(!disable) {
                on = [QCApp.shared.remoteConfig moduleOn:resp.sid];
            }
            
            NSString *title = @"";
            NSNumber *sectionHeight = QCSectionHeight;
           
            
            [items addObject:@{
                @"height":sectionHeight,
                @"title":title,
                @"remark":resp.desc?:@"",
                @"items": @[
                    @{
                        @"class":QCSwitchItemModel.class,
                        @"label":resp.name?:@"",
                        @"on":@(on),
                        @"disable": @(disable),
                        @"onSwitch":^(BOOL on){
                            [QCApp.shared.remoteConfig modules:resp.sid on:on];
                            [weakSelf reloadData];
                            weakSelf.settingChange = true;
                        }
                    }
                ],
            }];
        }
    }
    
    return items;
}

@end
