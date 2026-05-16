//
//  QCInputChangeTextRespondProto.h
//  Pods
//
//  Created by tt on 2019/12/15.
//
#import "QCConversationContext.h"



@protocol QCInputChangeRespondResult<NSObject>

@property(nonatomic,assign) BOOL changeText;  // return NO to not change text

@property(nonatomic,assign) BOOL next; // 是否允许下一个响应链执行

@end

@protocol QCInputChangeTextRespondProto <NSObject>

/**
 输入框委托事件
 */
@property(nonatomic,weak) id<QCConversationContext> conversationContext;

- (id<QCInputChangeRespondResult>)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

@end
