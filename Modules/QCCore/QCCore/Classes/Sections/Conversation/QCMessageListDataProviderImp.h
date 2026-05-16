//
//  QCMessageListDataProviderImp.h
//  QCCore
//
//  Created by tt on 2022/5/18.
//

#import <Foundation/Foundation.h>
#import "QCMessageListDataProvider.h"
NS_ASSUME_NONNULL_BEGIN


@interface QCMessageListDataProviderImp : NSObject<QCMessageListDataProvider>

-(instancetype) initWithChannel:(QCChannel*)channel conversationContext:(id<QCConversationContext>)conversationContext;




@end

NS_ASSUME_NONNULL_END
