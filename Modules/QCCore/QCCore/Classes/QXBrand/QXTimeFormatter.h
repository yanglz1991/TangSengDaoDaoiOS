//
//  QXTimeFormatter.h
//  QCCore
//
//  禧语时间格式化。聊天列表式相对时间、会话头时间标签、
//  动态时间分组等。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QXTimeBucket) {
    QXTimeBucketJustNow = 0,
    QXTimeBucketMinutesAgo,
    QXTimeBucketHoursAgo,
    QXTimeBucketYesterday,
    QXTimeBucketThisWeek,
    QXTimeBucketThisYear,
    QXTimeBucketEarlier,
};

@interface QXTimeFormatter : NSObject

+ (instancetype)sharedFormatter;

/// 类微信会话列表的相对时间。
- (NSString *)conversationListStringFromTimestamp:(NSTimeInterval)timestamp;

/// 消息气泡顶部的时间分组标签。
- (NSString *)messageBucketStringFromTimestamp:(NSTimeInterval)timestamp;

/// 任意时间分桶（用于聚合统计）。
- (QXTimeBucket)bucketFromTimestamp:(NSTimeInterval)timestamp;

/// 输出 ISO8601 字符串（用于日志）。
- (NSString *)iso8601StringFromTimestamp:(NSTimeInterval)timestamp;

/// 简单时长 (秒) 转 mm:ss / hh:mm:ss。
- (NSString *)durationStringFromSeconds:(NSTimeInterval)seconds;

@end

NS_ASSUME_NONNULL_END
