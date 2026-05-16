//
//  QCReceiptManager.h
//  QCIM
//
//  Created by tt on 2021/4/9.
//

#import <Foundation/Foundation.h>
#import "QCMessage.h"
NS_ASSUME_NONNULL_BEGIN

// 消息已读
typedef void(^QCMessageReadedCallback)(NSError * __nullable error);
typedef void(^QCMessageReadedProvider)(QCChannel *channel,NSArray<QCMessage*>*messages,QCMessageReadedCallback callback);

@interface QCReceiptManager : NSObject

+ (QCReceiptManager *)shared;

/**
 添加需要已读回执的消息
 */
-(void) addReceiptMessages:(QCChannel*)channel messages:(NSArray<QCMessage*>*)messages;


/**
 flush到服务器
 */
//-(void) flush:(QCChannel*)channel complete:(void(^)(NSError *error))complete;

// 消息已读提供者
@property(nonatomic,copy) QCMessageReadedProvider messageReadedProvider;


@end

NS_ASSUME_NONNULL_END
