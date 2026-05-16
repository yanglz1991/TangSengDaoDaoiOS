//
//  QCMeVM.m
//  WuKongBase
//
//  Created by tt on 2020/6/9.
//

#import "QCMeVM.h"
#import "QCTableSectionUtil.h"
#import "QCMeItemCell.h"
#import "QCMePushSettingVC.h"
#import "QCCommonSettingVC.h"
#import "QCMeItem.h"
@implementation QCMeVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    NSArray<QCMeItem*> *itemModels = [[QCApp shared] invokes:QCPOINT_CATEGORY_ME param:nil];
    if(!itemModels || itemModels.count<=0) {
        return @[];
    }
    NSMutableArray *items = [NSMutableArray array];
    QCMeItem *preMeItem;
    for (QCMeItem *meItem in itemModels) {
       [items addObject:@{
           @"height":@(meItem.sectionHeight + (preMeItem?preMeItem.nextSectionHeight:0)),
            @"items":@[@{
                           @"class":QCMeItemModel.class,
                           @"title":meItem.title?:@"",
                           @"icon": meItem.icon,
                           @"bottomLeftSpace":@(0.0f),
                           @"showBottomLine":@(NO),
                           @"showTopLine":@(NO),
                           @"onClick":^(BOOL on){
                               if(meItem.onClick) {
                                   meItem.onClick();
                               }
                           }
                       }]
       }];
        preMeItem = meItem;
        
    }
    return items;
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}

@end
