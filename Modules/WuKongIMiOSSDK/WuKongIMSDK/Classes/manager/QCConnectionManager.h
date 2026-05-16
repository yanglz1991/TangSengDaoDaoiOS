//
//  QCConnectionManager.h
//  WuKongIMSDK
//
//  Created by tt on 2019/11/23.
//

#import <Foundation/Foundation.h>
#import "QCPacket.h"
#import "QCConnectInfo.h"
#import "QCConst.h"
NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    QCNoConnect,    // 未连接
    QCConnecting,  // 连接中
    QCPullingOffline, // 拉取离线中
    QCConnected, // 已建立连接
    QCDisconnected, // 断开连接
} QCConnectStatus;






@protocol QCConnectionManagerDelegate <NSObject>

@optional
/**
 连接状态监听
 */
-(void) onConnectStatus:(QCConnectStatus)status reasonCode:(QCReason)reasonCode;


/**
  连接被踢出

 @param reasonCode 踢出原因代号
 @param reason 踢出原因字符串
 */
-(void) onKick:(uint8_t)reasonCode reason:(NSString*)reason;
@end

@interface QCConnectionManager : NSObject

+ (QCConnectionManager*)sharedManager;

@property(nonatomic,assign,readonly) QCConnectStatus connectStatus;


///  获取连接地址
@property(nonatomic,copy) void(^getConnectAddr)(void(^complete)(NSString * __nullable addr));
/**
 *  连接悟空IM服务器
 */
-(void) connect;

/**
 断开连接
 @param force 是否强制断开 如果force设置为true 将不再自动重连
 */
-(void) disconnect:(BOOL) force;


/// 登出，将强制断开，并清除登录信息
-(void) logout;


/**
 添加连接委托

 @param delegate <#delegate description#>
 */
-(void) addDelegate:(id<QCConnectionManagerDelegate>) delegate;


/**
 移除连接委托

 @param delegate <#delegate description#>
 */
-(void)removeDelegate:(id<QCConnectionManagerDelegate>) delegate;


/**
 发送包

 @param packet <#packet description#>
 */
-(void) sendPacket:(QCPacket*)packet;

-(void) writeData:(NSData*) data;

/**
 发送ping包
 */
-(void) sendPing;

/**
  唤醒IM
 @param timeout 超时时间（超时后不管有没有成功都会执行complete）
 */
-(void) wakeup:(NSTimeInterval)timeout complete:(void(^__nullable)(NSError * __nullable error))complete;



@end

NS_ASSUME_NONNULL_END
