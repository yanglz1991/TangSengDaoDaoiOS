//
//  QCConversationPosition.h
//  WuKongBase
//
//  Created by tt on 2021/8/11.
//

#import <Foundation/Foundation.h>
#import <WuKongIMSDK/WuKongIMSDK.h>

// 最近会话位置类型
typedef enum : NSInteger {
    QCConversationPositionTypeScrollToBottom = -1, // 滚动到底部（特殊位置）
    QCConversationPositionTypeUnreadFirst = 0, // 第一条未读消息位置
    QCConversationPositionTypeMention = 1, // 已确认
    QCConversationPositionTypeApplyJoinGroup = 2, // 申请进群
} QCConversationPositionType;


NS_ASSUME_NONNULL_BEGIN

@interface QCConversationPosition : NSObject

@property(nonatomic,assign) QCConversationPositionType positionType;

@property(nonatomic,assign) uint32_t orderSeq; // 消息的orderSeq

@property(nonatomic,assign) int offset; // 基于此消息的偏移位置

+(QCConversationPosition*) orderSeq:(uint32_t)orderSeq offset:(int)offset type:(QCConversationPositionType)type;

+(QCConversationPosition*) orderSeq:(uint32_t)orderSeq offset:(int)offset;

@end

@interface QCConversationPositionManager : NSObject

+ (QCConversationPositionManager *)shared;

-(void) reload;

-(void) channel:(QCChannel*)channel position:(QCConversationPosition* )position;

-(void) removePositions:(QCChannel*)channel;

-(void) removePositions:(QCChannel*)channel type:(QCConversationPositionType)type;

-(NSArray<QCConversationPosition*>*) position:(QCChannel*)channel;

@end

NS_ASSUME_NONNULL_END
