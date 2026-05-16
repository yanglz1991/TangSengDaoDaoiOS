//
//  QCConversationPasswordVM.h
//  QCCore
//
//  Created by tt on 2020/10/30.
//

#import "QCCore.h"

NS_ASSUME_NONNULL_BEGIN

@class QCConversationPasswordVM;

@protocol QCConversationPasswordVMDelegate <NSObject>


@optional

-(void) conversationPasswordVMFinished:(QCConversationPasswordVM*)vm;

@end

@interface QCConversationPasswordVM : QCBaseTableVM

@property(nonatomic,weak) id<QCConversationPasswordVMDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
