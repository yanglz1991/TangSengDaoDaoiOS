//
//  QCReminderDB.h
//  WuKongIMSDK
//
//  Created by tt on 2022/4/19.
//

#import <Foundation/Foundation.h>
#import "QCReminder.h"
#import "QCChannel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCReminderDB : NSObject

+ (QCReminderDB *)shared;

-(void) addOrUpdates:(NSArray<QCReminder*>*)reminders;

/**
 获取等待done的提醒项
 */
-(NSDictionary<QCChannel*,NSArray<QCReminder*>*>*) getWaitDoneReminders:(NSArray<QCChannel*>*) channels;

-(NSArray<QCReminder*>*) getWaitDoneReminder:(QCChannel*) channel;

-(NSArray<QCReminder*>*) getWaitDoneReminders:(QCChannel*)channel type:(QCReminderType)type;

// 获取所有等待完成的提醒
-(NSDictionary<QCChannel*,NSArray<QCReminder*>*>*) getAllWaitDoneReminders;


-(int64_t) getMaxVersion;

// 将对应id的提醒更新为done状态
-(void) updateDone:(NSArray<NSNumber*>*)ids;

// 更新过期的done=1的数据的上传状态为失败
-(void) updateExpireDoneUploadStatusFail:(NSInteger)expireTime;

-(void) updateUploadStatus:(QCReminderUploadStatus)status reminderID:(NSNumber*)reminderID;

-(NSArray<QCReminder*>*) getWaitUploads;

// 获取提醒项列表
-(NSArray<QCReminder*>*) getReminders:(NSArray<NSNumber*>*)ids;

@end

NS_ASSUME_NONNULL_END
