//
//  QCReminderManager.h
//  WuKongIMSDK
//
//  Created by tt on 2022/4/19.
//

#import <Foundation/Foundation.h>
#import "QCReminder.h"
@class QCReminderManager;
NS_ASSUME_NONNULL_BEGIN

// 消息提醒提供
typedef void(^QCReminderCallback)(NSArray<QCReminder*> * __nullable reminders,NSError * __nullable error);
typedef void(^QCReminderProvider)(QCReminderCallback callback);


// 消息提醒done提供
typedef void(^QCReminderDoneCallback)(NSError * __nullable error);
typedef void(^QCReminderDoneProvider)(NSArray<NSNumber*> *ids,QCReminderDoneCallback callback);

@protocol QCReminderManagerDelegate <NSObject>

@optional

// 某个频道的reminders发生变化
-(void) reminderManager:(QCReminderManager*)manager didChange:(QCChannel*)channel reminders:(NSArray<QCReminder*>*) reminders;

@end

@interface QCReminderManager : NSObject

+ (QCReminderManager *)shared;

-(void) sync;

-(void) done:(NSArray<NSNumber*>*)ids;

/**
 添加委托
 
 @param delegate <#delegate description#>
 */
-(void) addDelegate:(id<QCReminderManagerDelegate>) delegate;


/**
 移除委托
 
 @param delegate <#delegate description#>
 */
-(void)removeDelegate:(id<QCReminderManagerDelegate>) delegate;

@property(nonatomic,copy) QCReminderProvider reminderProvider; // 消息提醒项内容同步提供者
@property(nonatomic,copy) QCReminderDoneProvider reminderDoneProvider; // 消息提醒项完成提供者



@end

NS_ASSUME_NONNULL_END
