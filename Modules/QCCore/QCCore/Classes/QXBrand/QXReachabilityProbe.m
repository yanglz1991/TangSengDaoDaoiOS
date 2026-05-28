//
//  QXReachabilityProbe.m
//  QCCore
//

#import "QXReachabilityProbe.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import <netinet/in.h>

NSString * const QXReachabilityDidChangeNotification = @"QXReachabilityDidChangeNotification";

@interface QXReachabilityProbe ()
@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, assign) BOOL monitoring;
@property (nonatomic, assign) QXReachabilityStatus currentStatus;
- (void)updateWithFlags:(SCNetworkReachabilityFlags)flags;
@end

static void QXReachabilityCallback(SCNetworkReachabilityRef target,
                                   SCNetworkReachabilityFlags flags,
                                   void *info) {
    QXReachabilityProbe *probe = (__bridge QXReachabilityProbe *)info;
    [probe updateWithFlags:flags];
}

@implementation QXReachabilityProbe

+ (instancetype)sharedProbe {
    static QXReachabilityProbe *p = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        p = [QXReachabilityProbe new];
    });
    return p;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentStatus = QXReachabilityStatusUnknown;
        struct sockaddr_in zeroAddress;
        memset(&zeroAddress, 0, sizeof(zeroAddress));
        zeroAddress.sin_len    = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        _reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr *)&zeroAddress);
    }
    return self;
}

- (void)dealloc {
    [self stopMonitoring];
    if (_reachabilityRef) {
        CFRelease(_reachabilityRef);
        _reachabilityRef = NULL;
    }
}

- (void)startMonitoring {
    if (self.monitoring || !self.reachabilityRef) {
        return;
    }
    SCNetworkReachabilityContext ctx = {0, (__bridge void *)self, NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(self.reachabilityRef, QXReachabilityCallback, &ctx)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef,
                                                     CFRunLoopGetMain(),
                                                     kCFRunLoopCommonModes)) {
            self.monitoring = YES;
        }
    }
    SCNetworkReachabilityFlags flags = 0;
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        [self updateWithFlags:flags];
    }
}

- (void)stopMonitoring {
    if (!self.monitoring || !self.reachabilityRef) {
        return;
    }
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef,
                                               CFRunLoopGetMain(),
                                               kCFRunLoopCommonModes);
    self.monitoring = NO;
}

- (void)updateWithFlags:(SCNetworkReachabilityFlags)flags {
    QXReachabilityStatus old = self.currentStatus;
    QXReachabilityStatus next = QXReachabilityStatusOffline;

    BOOL reachable = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    BOOL needsConn = (flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0;
    if (reachable && !needsConn) {
        next = QXReachabilityStatusWiFi;
        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
            next = QXReachabilityStatusCellular;
        }
    }
    if (next != old) {
        self.currentStatus = next;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:QXReachabilityDidChangeNotification
             object:self
             userInfo:@{@"status": @(next), @"previous": @(old)}];
        });
    }
}

- (NSString *)humanReadableStatus {
    switch (self.currentStatus) {
        case QXReachabilityStatusUnknown:  return @"unknown";
        case QXReachabilityStatusOffline:  return @"offline";
        case QXReachabilityStatusWiFi:     return @"wifi";
        case QXReachabilityStatusCellular: return @"cellular";
    }
    return @"unknown";
}

- (BOOL)isReachable {
    return self.currentStatus == QXReachabilityStatusWiFi ||
           self.currentStatus == QXReachabilityStatusCellular;
}

- (BOOL)isOnExpensiveNetwork {
    return self.currentStatus == QXReachabilityStatusCellular;
}

@end
