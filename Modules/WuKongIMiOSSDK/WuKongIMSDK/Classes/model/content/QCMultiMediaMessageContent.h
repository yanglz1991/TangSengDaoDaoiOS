//
//  QCMultiMediaMessageContent.h
//  WuKongIMSDK
//
//  Created by tt on 2020/1/13.
//

#import <Foundation/Foundation.h>
#import "QCMessageContent.h"
#import "QCMediaProto.h"

NS_ASSUME_NONNULL_BEGIN

/**
 如果一个消息有多个多媒体文件 使用此MessageContent
 */
@interface QCMultiMediaMessageContent : QCMessageContent


/**
 多个多媒体文件
 */
@property NSArray<id<QCMediaProto>> *medias;

@end

NS_ASSUME_NONNULL_END
