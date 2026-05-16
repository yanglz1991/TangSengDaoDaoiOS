//
//  QCRetryManager.h
//  QCIMBase
//
//  Created by tt on 2019/12/29.
//

#import <Foundation/Foundation.h>
#import "QCMessage.h"
#import "QCReminder.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCRetryItem : NSObject
// 消息
@property(nonatomic,strong) QCMessage *message;
@property(nonatomic,strong) QCMessageExtra *messageExtra;
@property(nonatomic,strong) QCReminder *reminder;
// 重试次数
@property(nonatomic,assign) long retryCount;
// 下次重试时间
@property(nonatomic,assign) long nextRetryTime;

@property(nonatomic,assign) long nextRetryTime2;


@end

@interface QCRetryManager : NSObject

+ (QCRetryManager *)shared;


/**
 开启重试
 */
-(void) start;


/**
 停止重试
 */
-(void) stop;
/**
 添加重试项

 @param message 消息
 */
-(void) add:(QCMessage*)message;

-(void) addMessageExtra:(QCMessageExtra*)messageExtra;

/**
 移除重试项

 @param key key
 */
-(void) removeRetryItem:(NSString*) key;

-(void) removeMessageExtraRetryItem:(NSString*) key;

-(void) addReminder:(QCReminder*)reminder;
-(void) removeReminderRetryItem:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
