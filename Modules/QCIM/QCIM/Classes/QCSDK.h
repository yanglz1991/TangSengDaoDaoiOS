//
//  QCSDK.h
//  QCIM
//
//  Created by tt on 2019/11/23.
//

#import "QCIMHeader.h"

NS_ASSUME_NONNULL_BEGIN



// 悟空IM SDK
@interface QCSDK : NSObject

+ (QCSDK *)shared;

@property(nonatomic,strong) QCOptions* options;

/**
 连接信息串
 */
@property(nonatomic,copy) NSString *connectURL;

/**
 连接管理者
 */
@property(nonatomic,strong) QCConnectionManager *connectionManager;


/**
 聊天管理者
 */
@property(nonatomic,strong) QCChatManager *chatManager;


/**
 频道管理者
 */
@property(nonatomic,strong) QCChannelManager *channelManager;

/**
 频道信息提供者
 */
@property(nonatomic,strong) QCChannelInfoUpdate channelInfoUpdate;


/**
 媒体文件管理者
 */
@property(nonatomic,strong) QCMediaManager *mediaManager;


/**
 编码者
 */
@property(nonatomic,strong) QCCoder *coder;


/**
 包body的编码解码者管理
 */
@property(nonatomic,strong) QCPakcetBodyCoderManager *bodyCoderManager;


/**
 最近会话管理
 */
@property(nonatomic,strong) QCConversationManager *conversationManager;


/// cmd管理者
@property(nonatomic,strong) QCCMDManager *cmdManager;

// 消息已读回执管理者
@property(nonatomic,strong) QCReceiptManager *receiptManager;


// 消息回应管理
//  负责点赞数据的维护
@property(nonatomic,strong) QCReactionManager *reactionManager;

// 机器人管理者
@property(nonatomic,strong) QCRobotManager *robotManager;

// 置顶消息管理者
@property(nonatomic,strong) QCPinnedMessageManager *pinnedMessageManager;

// 提醒管理者
// 负责最近会话的提醒项，比如 有人@我，入群申请等等 还可以自定义一些提醒，比如类似微信的 [红包] [转账] 列表都会有提醒
@property(nonatomic,strong) QCReminderManager *reminderManager;

@property(nonatomic,strong) QCFlameManager *flameManager; // 阅后即焚管理者

// sdk版本号，每次升级记得修改此处
@property(nonatomic,copy,readonly) NSString *sdkVersion;



/**
 是否是debug模式

 @return <#return value description#>
 */
-(BOOL) isDebug;



/// 注册消息正文
/// @param cls 正文的class （需要继承WKMessageContent）
-(void) registerMessageContent:(Class)cls;


/// 注册消息正文（指定正文类型）
/// @param cls 正文的class （需要继承WKMessageContent）
/// @param contentType 正文类型
-(void) registerMessageContent:(Class)cls contentType:(NSInteger)contentType;


/**
 获取正文类型对应的正文对象

 @param contentType <#contentType description#>
 @return <#return value description#>
 */
-(Class) getMessageContent:(NSInteger)contentType;


/**
 是否是系统消息 （目前规定的系统消息的contentType类型为 [1000,2000]之间）

 @param contentType 正文类型
 @return <#return value description#>
 */
-(BOOL) isSystemMessage:(NSInteger)contentType;


// 离线消息拉取（普通模式）
@property(nonatomic,copy,readonly) QCOfflineMessagePull offlineMessagePull;
@property(nonatomic,copy,readonly) QCOfflineMessageAck offlineMessageAck;

// 离线会话拉取（万人群模式）
//@property(nonatomic,copy,readonly) QCOfflineMessagePull offlineMessagePull;

/**
 离线消息提供者

 @param offlineMessageCallback 消息回调
 @param offlineMessageAckCallback ack回调
 */
-(void) setOfflineMessageProvider:(QCOfflineMessagePull) offlineMessageCallback offlineMessagesAck:(QCOfflineMessageAck) offlineMessageAckCallback;


/**
 获取消息文件上传任务

 @param message <#message description#>
 @return <#return value description#>
 */
-(QCMessageFileUploadTask*) getMessageFileUploadTask:(QCMessage*)message;


/// 获取消息下载任务
/// @param message <#message description#>
-(QCMessageFileDownloadTask*) getMessageDownloadTask:(QCMessage*)message;

@end

NS_ASSUME_NONNULL_END
