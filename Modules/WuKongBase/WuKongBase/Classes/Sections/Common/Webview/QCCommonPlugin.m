//
//  QCCommonPlugin.m
//  WuKongBase
//
//  Created by tt on 2020/4/3.
//

#import "QCCommonPlugin.h"
#import "QCNavigationManager.h"
@implementation QCCommonPlugin

//- (void)showConversation:(QCMsgCommand *)command {
//   NSString *channelID = command.arguments[@"channel_id"]?:@"";
//   NSInteger channelType = command.arguments[@"channel_type"]?[command.arguments[@"channel_type"] integerValue]:0;
//    NSString *forward = command.arguments[@"forward"];
//    if(!channelID || [channelID isEqualToString:@""]) {
//        return;
//    }
//    QCConversationVC *conversationVC =  [QCConversationVC new];
//    conversationVC.channel = [[QCChannel alloc] initWith:channelID channelType:channelType];
//    if(forward && [forward isEqualToString:@"replace"]) {
//        [[QCNavigationManager shared] replacePushViewController:conversationVC animated:YES];
//    }else {
//        [[QCNavigationManager shared] pushViewController:conversationVC animated:YES];
//    }
//}
//
//- (void)pop:(QCMsgCommand *)command {
//    [[QCNavigationManager shared] popViewControllerAnimated:YES];
//}

@end
