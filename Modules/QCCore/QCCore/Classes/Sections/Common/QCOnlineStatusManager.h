//
//  QCOnlineStatusManager.h
//  QCCore
//
//  Created by tt on 2020/8/29.
//

#import <Foundation/Foundation.h>
#import <QCIM/QCIM.h>
#import "QCModel.h"
#import "QCConstant.h"
@class QCOnlineStatusResp;
@class QCPCOnlineResp;
NS_ASSUME_NONNULL_BEGIN

@class QCOnlineStatusManager;

@protocol QCOnlineStatusManagerDelegate <NSObject>

@optional

// 在线状态改变
-(void) onlineStatusManagerChange:(QCOnlineStatusManager*)manager status:(QCOnlineStatusResp*)status;

// 我的pc在线状态改变
-(void) onlineStatusManagerMyPCOnlineChange:(QCOnlineStatusManager*)manager status:(QCPCOnlineResp*)status;

@end

@interface QCOnlineStatusManager : NSObject



+ (QCOnlineStatusManager *)shared;

@property(nonatomic,assign) BOOL pcOnline; // pc是否在线
@property(nonatomic,assign) QCDeviceFlagEnum pcDeviceFlag; // pc设备
@property(nonatomic,assign) BOOL  muteOfApp; // app静音

@property(nonatomic,assign) BOOL needUpdate; // 是否需要更新在线状态

-(void) addDelegate:(id<QCOnlineStatusManagerDelegate>) delegate;

- (void)removeDelegate:(id<QCOnlineStatusManagerDelegate>) delegate;


/// 设置频道是否在线
/// @param channel 频道对象
/// @param online 是否在线
/// @param deviceFlag 当前在线或离线的设备标记
-(void) setChannelOnline:(QCChannel*)channel online:(BOOL)online deviceFlag:(QCDeviceFlagEnum)deviceFlag;


/// 如果频道在线状态需要更新则请求更新频道在线状态
-(void) requestUpdateChannelOnlineStatusIfNeed;

// 获取在线状态提示 空表示不显示
-(NSString*) onlineStatusTip:(QCChannelInfo*)channelInfo;

-(NSString*) onlineStatusDetailTip:(QCChannelInfo*)channelInfo;

// 设备标记对应的名字
-(NSString*) deviceName:(QCDeviceFlagEnum)deviceFlag;

- (void)callOnlineStatusChangeMyPCOnlineStatusDelegate:(QCPCOnlineResp*)status;

@end

@interface QCFriendAndMyDeviceOnlineStatusResp : QCModel

@property(nonatomic,strong,nullable) NSArray<QCOnlineStatusResp*> *friends;

@property(nonatomic,strong,nullable) QCPCOnlineResp *pc;

@end

@interface QCPCOnlineResp : QCModel

@property(nonatomic,assign) QCDeviceFlagEnum deviceFlag;

@property(nonatomic,assign) BOOL online; // pc是否在线

@property(nonatomic,assign) BOOL muteOfApp; //  app是否开启禁音

@end

@interface QCOnlineStatusResp : QCModel

@property(nonatomic,copy) NSString *uid; // 在线用户uid
@property(nonatomic,assign) NSInteger lastOffline; // 最后一次离线时间
@property(nonatomic,assign) BOOL online; // 是否在线
@property(nonatomic,assign) QCDeviceFlagEnum deviceFlag; // 设备flag

@end

NS_ASSUME_NONNULL_END
