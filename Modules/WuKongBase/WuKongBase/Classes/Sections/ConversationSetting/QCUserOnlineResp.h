//
//  QCUserOnlineResp.h
//  WuKongBase
//
//  Created by tt on 2023/1/3.
//

#import <Foundation/Foundation.h>
#import "QCModel.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCUserOnlineResp:QCModel

@property(nonatomic,copy) NSString *uid;
@property(nonatomic,assign) QCDeviceFlagEnum deviceFlag;
@property(nonatomic,assign) NSInteger lastOnline;
@property(nonatomic,assign) NSInteger lastOffline;
@property(nonatomic,assign) BOOL online;

@end

NS_ASSUME_NONNULL_END
