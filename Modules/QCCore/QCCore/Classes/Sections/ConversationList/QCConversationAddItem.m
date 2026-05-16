//
//  QCConversationAddItem.m
//  QCCore
//
//  Created by tt on 2020/12/16.
//

#import "QCConversationAddItem.h"

@implementation QCConversationAddItem

+(QCConversationAddItem*) title:(NSString*)title icon:(UIImage*)icon onClick:(ConversationAddClick)click {
    QCConversationAddItem *item = [QCConversationAddItem new];
    item.title = title;
    item.icon = icon;
    item.onClick = click;
    return item;
}

@end
