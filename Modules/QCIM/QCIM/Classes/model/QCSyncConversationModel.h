//
//  QCOfflineConversation.h
//  QCIM
//
//  Created by tt on 2020/9/30.
//

#import <Foundation/Foundation.h>
#import "QCChannel.h"
#import "QCMessage.h"
#import "QCConversation.h"

#import "QCCMDDB.h"
NS_ASSUME_NONNULL_BEGIN



@interface QCSyncConversationModel : NSObject

@property(nonatomic,strong) QCChannel *channel; // 频道

@property(nonatomic,strong) QCChannel *parentChannel; // 频道

@property(nonatomic,assign) NSInteger unread; // 消息未读数

@property(nonatomic,assign) BOOL mute;

@property(nonatomic,assign) BOOL stick;

@property(nonatomic,assign) NSTimeInterval timestamp; // 最后一次会话时间

@property(nonatomic,assign) uint32_t lastMsgSeq; // 最后一次会话的消息序列号

@property(nonatomic,copy) NSString *lastMsgClientNo; // 最后一次会话的消息客户端编号

@property(nonatomic,assign) long long version; // 数据版本

@property(nonatomic,strong) NSArray<QCMessage*> *recents; // 会话的最新消息集合

@property(nonatomic,strong) QCConversationExtra *remoteExtra;

@property(nonatomic,strong,readonly) QCConversation *conversation;

@end

@interface QCCMDModel : NSObject

@property(nonatomic,copy) NSString *no; // cmd唯一编号
@property(nonatomic,copy) NSString *cmd;
// 消息时间（服务器时间,单位秒）
@property(nonatomic,assign) NSInteger timestamp;

// cmd 参数
@property(nonatomic,strong) NSDictionary *param;

+(QCCMDModel*) message:(QCMessage*)message;

+(QCCMDModel*) cmdMessage:(QCCMDMessage*)cmdMessage;

@end

@interface QCSyncConversationWrapModel : NSObject

@property(nonatomic,strong) NSArray<QCSyncConversationModel*> *conversations;

@end



NS_ASSUME_NONNULL_END
