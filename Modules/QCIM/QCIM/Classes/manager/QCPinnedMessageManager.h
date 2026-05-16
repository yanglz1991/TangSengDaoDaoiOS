//
//  QCPinnedMessageManager.h
//  QCIM
//
//  Created by tt on 2024/5/22.
//

#import <Foundation/Foundation.h>
#import "QCPinnedMessage.h"
#import "QCMessage.h"
NS_ASSUME_NONNULL_BEGIN

@protocol QCPinnedMessageManagerDelegate <NSObject>

@optional

// 置顶消息改变
-(void) pinnedMessageChange:(QCChannel*)channel;

@end

@interface QCPinnedMessageManager : NSObject


/**
 添加委托
 
 @param delegate <#delegate description#>
 */
-(void) addDelegate:(id<QCPinnedMessageManagerDelegate>) delegate;
/**
 移除委托
 
 @param delegate <#delegate description#>
 */
-(void)removeDelegate:(id<QCPinnedMessageManagerDelegate>) delegate;

+ (QCPinnedMessageManager *)shared;

// 通过频道获取置顶的消息集合
-(NSArray<QCMessage*>*) getPinnedMessagesByChannel:(QCChannel*)channel;

// 获取某个频道的最大version
-(uint64_t) getMaxVersion:(QCChannel*)channel;

// 删除某个频道的所有置顶
-(void) deletePinnedByChannel:(QCChannel*)channel;

// 删除某条消息的置顶
-(void) deletePinnedByMessageId:(uint64_t)messageId;

// 添加或更新置顶消息
-(void) addOrUpdatePinnedMessages:(NSArray<QCPinnedMessage*>*)messages;

// 是否置顶
-(BOOL) hasPinned:(uint64_t)messageId;

@end

NS_ASSUME_NONNULL_END
