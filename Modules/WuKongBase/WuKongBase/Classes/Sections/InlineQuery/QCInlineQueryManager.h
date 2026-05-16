//
//  QCInlineQueryManager.h
//  WuKongBase
//
//  Created by tt on 2021/11/9.
//

#import <Foundation/Foundation.h>
#import "QCResultPanel.h"
#import "QCInlineQueryResult.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCInlineQueryManager : NSObject

+ (instancetype _Nonnull )shared;

-(QCResultPanel*) createResultPanel:(QCInlineQueryResult*)result context:(id<QCConversationContext> __nonnull)context;

@end

NS_ASSUME_NONNULL_END
