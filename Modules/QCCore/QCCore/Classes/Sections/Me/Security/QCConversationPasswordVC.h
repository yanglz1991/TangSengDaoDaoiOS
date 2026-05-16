//
//  QCConversationPasswordVC.h
//  QCCore
//
//  Created by tt on 2020/10/30.
//

#import "QCCore.h"
#import "QCConversationPasswordVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCConversationPasswordVC : QCBaseTableVC<QCConversationPasswordVM*>

@property(nonatomic,copy) void(^onFinish)(void);

@end

NS_ASSUME_NONNULL_END
