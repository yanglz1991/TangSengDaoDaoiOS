//
//  QCMessageActionManager.m
//  QCCore
//
//  Created by tt on 2022/4/8.
//

#import "QCMessageActionManager.h"
#import "QCConversationListSelectVC.h"
@implementation QCMessageActionManager
static QCMessageActionManager *_instance;
+ (QCMessageActionManager *)shared {
    if (_instance == nil) {
        _instance = [[super alloc]init];
    }
    return _instance;
}

-(void) forwardMessages:(NSArray<QCMessage*>*)messages{
    QCConversationListSelectVC *vc = [QCConversationListSelectVC new];
    vc.title = LLang(@"选择一个聊天");
    vc.viewModel.multiple = YES;
    [vc setOnSelectChannels:^(NSArray<QCChannel *> * _Nonnull channels) {
        [[QCNavigationManager shared] popViewControllerAnimated:YES];
        for (QCChannel *channel in channels) {
            for (QCMessage *message in messages) {
                if([[QCApp shared] allowMessageForward:message.contentType]) { // 如果允许转发则直接转发
                    [[QCSDK shared].chatManager forwardMessage:message.content channel:channel];
                }else{ // 如果不允许转发，则将变成文本消息转发
                    QCTextContent *textContent = [[QCTextContent alloc] initWithContent:[message.content conversationDigest]];
                    [[QCSDK shared].chatManager forwardMessage:textContent channel:channel];
                }
            }
        }
        [[QCNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"发送成功")];
    }];
    [[QCNavigationManager shared] pushViewController:vc animated:YES];
}

-(void) forwardContent:(QCMessageContent*)messageContent complete:(void(^)(void))complete{
    QCConversationListSelectVC *vc = [QCConversationListSelectVC new];
    vc.title = LLang(@"选择一个聊天");
    vc.viewModel.multiple = YES;
    [vc setOnSelectChannels:^(NSArray<QCChannel *> * _Nonnull channels) {
        if(complete) {
            complete();
        }else {
            [[QCNavigationManager shared] popViewControllerAnimated:YES];
        }
        for (QCChannel *channel in channels) {
            if([[QCApp shared] allowMessageForward:messageContent.realContentType]) { // 如果允许转发则直接转发
                [[QCSDK shared].chatManager forwardMessage:messageContent channel:channel];
            }else{ // 如果不允许转发，则将变成文本消息转发
                QCTextContent *textContent = [[QCTextContent alloc] initWithContent:[messageContent conversationDigest]];
                [[QCSDK shared].chatManager forwardMessage:textContent channel:channel];
            }
        }
        [[QCNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"发送成功")];
    }];
    [[QCNavigationManager shared] pushViewController:vc animated:YES];
}

-(void) sendContentToFriend:(QCMessageContent*)messageContent complete:(void(^__nullable)(void))complete {
    QCConversationListSelectVC *vc = [QCConversationListSelectVC new];
    vc.title = LLang(@"选择一个聊天");
    [vc setOnSelect:^(QCChannel * _Nonnull channel) {
        if(complete) {
            complete();
        }else {
            [[QCNavigationManager shared] popViewControllerAnimated:YES];
        }
        [[QCSDK shared].chatManager sendMessage:messageContent channel:channel];
        [[QCNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"发送成功")];
        
    }];
    [[QCNavigationManager shared] pushViewController:vc animated:YES];
}

@end
