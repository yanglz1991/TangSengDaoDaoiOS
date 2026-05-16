//
//  QCConversationUtil.h
//  QCIM
//
//  Created by tt on 2020/1/24.
//

#import <Foundation/Foundation.h>
#import "QCConversation.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCConversationUtil : NSObject
// 合并提醒数据
+(NSArray<QCReminder*>*) mergeReminders:(NSArray<QCReminder*>*)source dest:(NSArray<QCReminder*>*)dest;
@end

NS_ASSUME_NONNULL_END
