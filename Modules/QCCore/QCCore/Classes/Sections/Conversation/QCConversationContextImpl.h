//
//  QCConversationContextImpl.h
//  QCCore
//
//  Created by tt on 2022/5/19.
//

#import <Foundation/Foundation.h>
#import "QCConversationContext.h"
#import "QCConversationVM.h"
#import "QCConversationView.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCConversationContextImpl : NSObject<QCConversationContext>

-(instancetype) initWithChannel:(QCChannel*)channel conersationView:(QCConversationView*)conversationView conversationVM:(QCConversationVM*)conversationVM;


-(void) callConversationInputChangeDelegate;

-(void) layoutMentionUserHandle;

@end

NS_ASSUME_NONNULL_END
