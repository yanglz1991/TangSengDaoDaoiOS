//
//  QCImageBrowser.h
//  QCCore
//
//  Created by tt on 2022/4/8.
//

#import <YBImageBrowser/YBImageBrowser.h>
#import "QCConversationContext.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCImageBrowser : YBImageBrowser

@property(nonatomic,copy) void(^onEditFinish)(UIImage*img);

@property(nonatomic,copy) void(^onDealloc)(void);

@property(nonatomic,weak) id<QCConversationContext> conversationContext;

@end

NS_ASSUME_NONNULL_END
