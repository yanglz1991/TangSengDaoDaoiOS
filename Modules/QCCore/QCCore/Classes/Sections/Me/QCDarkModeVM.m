//
//  QCDarkModeVM.m
//  QCCore
//
//  Created by tt on 2020/12/11.
//

#import "QCDarkModeVM.h"
#import "QCSwitchItemCell.h"

@interface QCDarkModeVM ()


@end

@implementation QCDarkModeVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    
    NSMutableArray *items = [NSMutableArray array];
    
    
    __weak typeof(self) weakSelf = self;
    [items addObject:@{
        @"height": @(0.0f),
        @"remark": LLang(@"开启后，将跟随系统打开或关闭深色模式"),
        @"items": @[
                @{
                    @"class": QCSwitchItemModel.class,
                    @"label": LLang(@"跟随系统"),
                    @"on": @(QCApp.shared.config.darkModeWithSystem),
                    @"onSwitch":^(BOOL on){
                        QCApp.shared.config.darkModeWithSystem = on;
                        if(on) {
                            if (@available(iOS 13.0, *)) {
                                if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                                    QCApp.shared.config.style = QCSystemStyleDark;
                                }else{
                                    QCApp.shared.config.style = QCSystemStyleLight;
                                }
                               
                            }
                        }
                        [weakSelf reloadData];
                    }
                }
        ],
    }];
    if(!QCApp.shared.config.darkModeWithSystem) {
        [items addObjectsFromArray:@[
            @{
                @"height":@(10.0f),
                @"items": @[
                        @{
                                @"class": QCLabelItemSelectModel.class,
                                @"label":LLang(@"普通模式"),
                                @"selected": @(QCApp.shared.config.style==QCSystemStyleLight),
                                @"onClick":^{
                                    QCApp.shared.config.style = QCSystemStyleLight;
                                    [weakSelf reloadData];
                                }
                        },
                        @{
                                @"class": QCLabelItemSelectModel.class,
                                @"label":LLang(@"深色模式"),
                                @"selected": @(QCApp.shared.config.style==QCSystemStyleDark),
                                @"onClick":^{
                                    QCApp.shared.config.style = QCSystemStyleDark;
                                    [weakSelf reloadData];
                                }
                        }
                ]
            },
        ]];
    }
    
    return items;
}

@end
