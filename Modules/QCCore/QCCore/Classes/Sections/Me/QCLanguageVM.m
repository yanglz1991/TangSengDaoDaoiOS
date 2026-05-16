//
//  QCLanguageVM.m
//  QCCore
//
//  Created by tt on 2020/12/25.
//

#import "QCLanguageVM.h"
#import "QCLabelItemSelectCell.h"


@implementation QCLanguageVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    NSString *langue = [QCApp shared].config.langue;
    __weak typeof(self) weakSelf = self;
    return @[
        @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":QCLabelItemSelectModel.class,
                        @"label":@"简体中文",
                        @"selected":@([langue isEqualToString:@"zh-Hans"]),
                        @"onClick":^{
                            [QCApp shared].config.langue = @"zh-Hans";
                            [weakSelf reloadData];
                        }
                    },
                    @{
                        @"class":QCLabelItemSelectModel.class,
                        @"label":@"English",
                        @"selected":@([langue isEqualToString:@"en"]),
                        @"onClick":^{
                            [QCApp shared].config.langue = @"en";
                            [weakSelf reloadData];
                        }
                    }
            ],
        }
    ];
}

@end
