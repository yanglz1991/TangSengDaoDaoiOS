//
//  QCThemeUtil.h
//  QCCore
//
//  Created by tt on 2022/9/9.
//

#import <Foundation/Foundation.h>
#import <QCIM/QCIM.h>
#import "QCAppConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCThemeUtil : NSObject

// 获取某个频道的背景数据
+(NSData*) getChatBackground:(QCChannel*)channel style:(QCSystemStyle)style;

// 是否存在聊天背景图
+(BOOL) existChatBackground:(QCChannel*)channel;

/**
 保存某个频道的背景图
 */
+(BOOL) saveChatBackground:(QCChannel*)channel data:(NSData*)data style:(QCSystemStyle)style;

// 保存默认背景图
+(BOOL) saveDefaultBackground:(NSData*)data style:(QCSystemStyle)style;

// 是否存在默认的聊天背景
+(BOOL) existDefaultbackground;

// 获取全局的默认背景图数据
+(NSData*) getDefaultBackground:(QCSystemStyle)style;

@end

NS_ASSUME_NONNULL_END
