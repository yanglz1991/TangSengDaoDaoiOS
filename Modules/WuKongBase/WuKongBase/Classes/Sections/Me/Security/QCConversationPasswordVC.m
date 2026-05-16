//
//  QCConversationPasswordVC.m
//  WuKongBase
//
//  Created by tt on 2020/10/30.
//

#import "QCConversationPasswordVC.h"
#import "QCConversationPasswordVM.h"
@interface QCConversationPasswordVC ()<QCConversationPasswordVMDelegate>

@end

@implementation QCConversationPasswordVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCConversationPasswordVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (NSString *)langTitle {
    return LLang(@"聊天密码");
}

#pragma mark -- QCConversationPasswordVMDelegate

- (void)conversationPasswordVMFinished:(QCConversationPasswordVM *)vm {
    if(self.onFinish) {
        self.onFinish();
    }
}

@end
