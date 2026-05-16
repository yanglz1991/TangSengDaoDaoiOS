//
//  QCChannelDataManager.h
//  25519
//
//  Created by tt on 2022/12/2.
//

#import <Foundation/Foundation.h>
#import <WuKongIMSDK/WuKongIMSDK.h>

@class QCChannelDataManager;

NS_ASSUME_NONNULL_BEGIN

@protocol QCChannelDataManagerDelegate <NSObject>

-(void) channelDataManager:(QCChannelDataManager*)manager members:(QCChannel*)channel keyword:(NSString * __nullable )keyword page:(NSInteger)page limit:(NSInteger)limit complete:(void(^__nullable)(NSError * __nullable error,NSArray<QCChannelMember*>* __nullable members))complete;

@end

@interface QCChannelDataManager : NSObject

+ (QCChannelDataManager *)shared;

@property(nonatomic,strong) id<QCChannelDataManagerDelegate> delegate;

-(void) members:(QCChannel*)channel keyword:(NSString * __nullable )keyword page:(NSInteger)page limit:(NSInteger)limit complete:(void(^__nullable)(NSError * __nullable error,NSArray<QCChannelMember*>* __nullable members))complete;


@end

NS_ASSUME_NONNULL_END
