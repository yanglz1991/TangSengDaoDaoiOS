//
//  QCLocalNotificationManager.h
//  QCCore
//
//  Created by tt on 2020/7/21.
//

#import <Foundation/Foundation.h>
#import <QCIM/QCIM.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCLocalNotificationManager : NSObject

+ (QCLocalNotificationManager *)shared;


/// 显示本地通知
/// @param message <#message description#>
-(void) showLocalNotification:(QCMessage*)message;

// 显示本地通知在允许的情况下
-(void) showLocalNotificationIfNeed:(QCMessage*)message;

@end



NS_ASSUME_NONNULL_END
