//
//  QXTelemetryRingBuffer.h
//  QCCore
//
//  线程安全的事件环形缓冲区。仅在内存中保留最近 N 条遥测，
//  避免本地无限增长，并支持快照导出。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QXTelemetryRingBuffer<__covariant ObjectType> : NSObject

- (instancetype)initWithCapacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, assign, readonly) NSUInteger capacity;
@property (nonatomic, assign, readonly) NSUInteger count;

- (void)appendObject:(ObjectType)object;
- (NSArray<ObjectType> *)snapshot;
- (void)clear;
- (NSUInteger)dropOldest:(NSUInteger)n;

@end

NS_ASSUME_NONNULL_END
