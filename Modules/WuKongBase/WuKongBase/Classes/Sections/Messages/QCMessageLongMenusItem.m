//
//  QCMessageLongMenusItem.m
//  WuKongBase
//
//  Created by tt on 2020/1/28.
//

#import "QCMessageLongMenusItem.h"

@implementation QCMessageLongMenusItem

+(instancetype) initWithTitle:(NSString*)title onTap:(void(^)(id<QCConversationContext> context)) onTap {
    QCMessageLongMenusItem *item = [QCMessageLongMenusItem new];
    item.title = title;
    item.onTap = onTap;
    return item;
}

+(instancetype) initWithTitle:(NSString*)title icon:(UIImage*)icon onTap:(void(^)(id<QCConversationContext> context)) onTap {
    QCMessageLongMenusItem *item = [QCMessageLongMenusItem new];
    item.title = title;
    item.onTap = onTap;
    item.icon = icon;
    return item;
}

@end
