//
//  QCMeItem.m
//  QCCore
//
//  Created by tt on 2020/7/14.
//

#import "QCMeItem.h"

@implementation QCMeItem

+(QCMeItem*) initWithTitle:(NSString*)title icon:(UIImage*)icon onClick:(void(^)(void))onClick {
    QCMeItem *item = [QCMeItem new];
    item.title = title;
    item.icon = icon;
    item.onClick = onClick;
    return item;
}


+(QCMeItem*) initWithTitle:(NSString*)title icon:(UIImage*)icon sectionHeight:(CGFloat)sectionHeight onClick:(void(^)(void))onClick {
    QCMeItem *item = [QCMeItem new];
    item.title = title;
    item.sectionHeight = sectionHeight;
    item.icon = icon;
    item.onClick = onClick;
    return item;
}

+(QCMeItem*) initWithTitle:(NSString*)title icon:(UIImage*)icon nextSectionHeight:(CGFloat)nextSectionHeight onClick:(void(^)(void))onClick {
    QCMeItem *item = [QCMeItem new];
    item.title = title;
    item.nextSectionHeight = nextSectionHeight;
    item.icon = icon;
    item.onClick = onClick;
    return item;
}
@end
