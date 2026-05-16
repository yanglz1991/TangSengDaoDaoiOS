//
//  QCConversationUtil.m
//  QCIM
//
//  Created by tt on 2020/1/24.
//

#import "QCConversationUtil.h"

@implementation QCConversationUtil

// 合并提醒数据
+(NSArray<QCReminder*>*) mergeReminders:(NSArray<QCReminder*>*)source dest:(NSArray<QCReminder*>*)dest {
    if(!source || source.count<=0) {
        return dest;
    }
    if(!dest || dest.count<=0) {
        return source;
    }
    NSMutableArray<QCReminder*> *newReminders = [NSMutableArray arrayWithArray:dest];
    for (QCReminder *reminderSource in source) {
        BOOL has = false;
        for (QCReminder *reminderDest in dest) {
            if(reminderSource.type == reminderDest.type) {
                has = true;
                break;
            }
        }
        if(!has) {
            [newReminders addObject:reminderSource];
        }
    }
    return newReminders;
}

@end
