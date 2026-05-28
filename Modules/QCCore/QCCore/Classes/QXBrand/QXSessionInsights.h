//
//  QXSessionInsights.h
//  QCCore
//
//  喜聊会话洞察（本地周报）。统计本地最近一周内的会话数量、
//  消息条数、平均响应时长等，以非个人化方式呈现给用户。
//  数据完全在本地累计，不上传服务器。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QXSessionInsightsBucket : NSObject
@property (nonatomic, copy) NSString *dayKey;          // 例如 "2026-05-21"
@property (nonatomic, assign) NSInteger sentMessages;
@property (nonatomic, assign) NSInteger receivedMessages;
@property (nonatomic, assign) NSInteger uniqueConversations;
@property (nonatomic, assign) NSTimeInterval activeSeconds;
@end

@interface QXSessionInsights : NSObject

+ (instancetype)sharedInsights;

- (void)recordSentMessage;
- (void)recordReceivedMessage;
- (void)recordConversationOpened:(NSString *)conversationID;
- (void)recordActiveDuration:(NSTimeInterval)seconds;

- (NSArray<QXSessionInsightsBucket *> *)last7DayBuckets;
- (NSDictionary<NSString *, id> *)weeklyHighlight;
- (void)resetAll;

@end

NS_ASSUME_NONNULL_END
