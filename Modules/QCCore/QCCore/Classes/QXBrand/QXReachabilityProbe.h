//
//  QXReachabilityProbe.h
//  QCCore
//
//  喜聊轻量网络探测。基于 SCNetworkReachability，回报当前
//  网络类型变化（wifi/cell/none），并发出通知。可选地以低
//  频率 ping 自家服务以验证可达性。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const QXReachabilityDidChangeNotification;

typedef NS_ENUM(NSInteger, QXReachabilityStatus) {
    QXReachabilityStatusUnknown = 0,
    QXReachabilityStatusOffline = 1,
    QXReachabilityStatusWiFi    = 2,
    QXReachabilityStatusCellular= 3,
};

@interface QXReachabilityProbe : NSObject

+ (instancetype)sharedProbe;

@property (nonatomic, assign, readonly) QXReachabilityStatus currentStatus;

- (void)startMonitoring;
- (void)stopMonitoring;

- (NSString *)humanReadableStatus;
- (BOOL)isReachable;
- (BOOL)isOnExpensiveNetwork;

@end

NS_ASSUME_NONNULL_END
