//
//  QCReminder.h
//  WuKongIMSDK
//
//  Created by tt on 2022/4/19.
//

#import <Foundation/Foundation.h>
#import "QCChannel.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    QCReminderTypeMentionMe = 1, // 有人@我
} QCReminderType;

typedef enum : NSUInteger {
    QCReminderUploadStatusSuccess, // 成功
    QCReminderUploadStatusWait, // 等待上传
    QCReminderUploadStatusError, // 上传错误
} QCReminderUploadStatus; // 提醒项上传状态

@interface QCReminder : NSObject<NSCopying>

@property(nonatomic,assign) int64_t reminderID;
@property(nonatomic,assign) uint64_t messageId;
@property(nonatomic,assign)  uint32_t messageSeq; // 消息序列号（用户唯一，有序）
@property(nonatomic,strong) QCChannel *channel; // 频道
@property(nonatomic,assign) QCReminderType type; //  提醒类型
@property(nonatomic,copy) NSString *publisher; // 发布者uid

@property(nonatomic,copy) NSString *text; // 提醒文本


@property(nonatomic,strong) NSDictionary *data; //  提醒包含的数据
 
@property(nonatomic,assign) BOOL isLocate; // 是否需要进行消息定位
@property(nonatomic,assign) int64_t version;

@property(nonatomic,assign) BOOL done; // 用户是否完成提醒

@property(nonatomic,assign) QCReminderUploadStatus uploadStatus; // 上传状态 只对本地生效

/**
 转换为字典

 @return <#return value description#>
 */
-(NSDictionary*) toDictionary;



@end

NS_ASSUME_NONNULL_END
