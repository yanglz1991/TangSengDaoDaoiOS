//
//  QCConversationExtraDB.h
//  QCIM
//
//  Created by tt on 2022/4/23.
//

#import <Foundation/Foundation.h>
#import "QCConversationExtra.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCConversationExtraDB : NSObject

+ (QCConversationExtraDB *)shared;

-(void) addOrUpdates:(NSArray<QCConversationExtra*>*)extras;

-(void) updateVersion:(QCChannel*)channel version:(int64_t)version;

-(int64_t) getMaxVersion;


@end

NS_ASSUME_NONNULL_END
