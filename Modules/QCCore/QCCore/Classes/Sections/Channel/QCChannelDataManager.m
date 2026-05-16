//
//  QCChannelDataManager.m
//  25519
//
//  Created by tt on 2022/12/2.
//

#import "QCChannelDataManager.h"

@implementation QCChannelDataManager

static QCChannelDataManager *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCChannelDataManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)members:(QCChannel *)channel keyword:(NSString *)keyword page:(NSInteger)page limit:(NSInteger)limit complete:(void (^)(NSError *error,NSArray<QCChannelMember *> * _Nonnull))complete {
    if(_delegate && [_delegate respondsToSelector:@selector(channelDataManager:members:keyword:page:limit:complete:)]) {
        [_delegate channelDataManager:self members:channel keyword:keyword page:page limit:limit complete:complete];
    }
}



@end
