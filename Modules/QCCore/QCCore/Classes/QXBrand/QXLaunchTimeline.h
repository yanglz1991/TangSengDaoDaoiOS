//
//  QXLaunchTimeline.h
//  QCCore
//
//  禧语冷启动时间线追踪。在启动各阶段插入打点（mark），
//  形成可读的启动时间线，便于性能优化与发布前 self-check。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const QXLaunchMarkProcessStart;
extern NSString * const QXLaunchMarkAppDelegateStart;
extern NSString * const QXLaunchMarkConfigLoaded;
extern NSString * const QXLaunchMarkSDKReady;
extern NSString * const QXLaunchMarkFirstWindow;
extern NSString * const QXLaunchMarkFirstFrame;

@interface QXLaunchMark : NSObject
@property (nonatomic, copy, readonly)   NSString *name;
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;
@property (nonatomic, copy, readonly)   NSDictionary<NSString *, id> *attributes;
@end

@interface QXLaunchTimeline : NSObject

+ (instancetype)sharedTimeline;

- (void)mark:(NSString *)name;
- (void)mark:(NSString *)name attributes:(nullable NSDictionary<NSString *, id> *)attributes;

- (nullable QXLaunchMark *)markForName:(NSString *)name;
- (NSArray<QXLaunchMark *> *)allMarks;
- (NSTimeInterval)elapsedFrom:(NSString *)from to:(NSString *)to;

- (NSString *)humanReadableReport;

@end

NS_ASSUME_NONNULL_END
