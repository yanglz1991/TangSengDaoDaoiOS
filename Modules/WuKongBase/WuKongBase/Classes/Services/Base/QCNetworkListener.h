//
//  QCNetworkListener.h
//  WuKongBase
//
//  Created by tt on 2020/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class QCNetworkListener;
@protocol QCNetworkListenerDelegate <NSObject>

@optional


/// 网络状态发送变化
/// @param listener <#listener description#>
-(void) networkListenerStatusChange:(QCNetworkListener*)listener;

@end

@interface QCNetworkListener : NSObject

@property(nonatomic) BOOL hasNetwork; // 是否有网络

+ (QCNetworkListener *)shared;


/// 开始监听
-(void) start;

-(void) addDelegate:(id<QCNetworkListenerDelegate>)delegate;

- (void)removeDelegate:(id<QCNetworkListenerDelegate>) delegate;

@end

NS_ASSUME_NONNULL_END
