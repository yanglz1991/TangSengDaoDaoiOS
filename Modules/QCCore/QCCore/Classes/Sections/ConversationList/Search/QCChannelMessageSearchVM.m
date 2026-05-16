//
//  QCChannelMessageSearchVM.m
//  QCCore
//
//  Created by tt on 2020/8/10.
//
#import <QCIM/QCIM.h>
#import "QCSearchHeaderCell.h"
#import "QCChannelMessageSearchVM.h"
#import "QCChannelMessageCell.h"
#import "QCConversationVC.h"

@implementation QCChannelMessageSearchVM


- (NSArray<NSDictionary *> *)tableSectionMaps {
    
    NSArray *results = [[QCMessageDB shared] getMessages:self.channel keyword:self.keyword limit:2000];
    if(!results || results.count<=0) {
        return nil;
    }
    NSMutableArray *newResults = [NSMutableArray array];
    for (QCMessage *message in results) {
        if(message.fromUid && ![message.fromUid isEqualToString:@""]) {
            [newResults addObject:message];
        }
    }
    
    NSMutableArray *items = [NSMutableArray array];
     [items addObject: @{
                @"class":QCSearchHeaderModel.class,
                @"title":[NSString stringWithFormat:LLang(@"%lu条与“%@”相关记录"),(unsigned long)newResults.count,self.keyword],
                @"showBottomLine":@(NO),
                         
     }];
    
    for (NSInteger i=0; i<newResults.count; i++) {
        QCMessage *message = newResults[i];
        NSString *name = @"";
        NSString *logo = @"";
        if(!message.from) {
            // 如果from不存在则异步去获取
            [[QCChannelManager shared] fetchChannelInfo:[[QCChannel alloc] initWith:message.fromUid channelType:WK_PERSON]];
        }
        if(message.from && message.from.displayName) {
            name = message.from.displayName;
        }
        if(message.from && message.from.logo) {
            logo = [QCAvatarUtil getFullAvatarWIthPath:message.from.logo];
        }
        [items addObject:@{
           @"class":QCChannelMessageModel.class,
           @"name":name,
           @"avatar":[QCAvatarUtil getFullAvatarWIthPath:logo],
           @"keyword": self.keyword?:@"",
           @"content": [message.content searchableWord]?:@"",
           @"timestamp": @(message.timestamp),
           @"showBottomLine":@(NO),
           @"showTopLine":@(NO),
           @"onClick":^{
            QCConversationVC *vc = [[QCConversationVC alloc] init];
            vc.channel = self.channel;
            vc.locationAtOrderSeq = message.orderSeq;
            [[QCNavigationManager shared] pushViewController:vc animated:YES];
            }
        }];
    }
    return @[@{
         @"height":@(0.01f),
         @"items":items,
    }];
}


@end
