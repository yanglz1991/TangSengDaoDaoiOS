//
//  QCConversationContext.h
//  QCCore
//
//  Created by tt on 2020/1/15.
//

#import <Foundation/Foundation.h>
#import <QCIM/QCIM.h>
#import "QCMessageModel.h"
#import "QCInputMentionCache.h"
@class QCMessageCell;
@protocol QCConversationContext;
NS_ASSUME_NONNULL_BEGIN
@class QCConversationInputPanel;
@class QCMessageContextController;

@protocol QCConversationInputDelegate <NSObject>

// 输入框内容改变
-(void) conversationInputChange:(id<QCConversationContext>)context;


@end

@protocol QCConversationContext<NSObject>

@optional

//  获取当前会话的频道
@property(nonatomic,strong,readonly) QCChannel *channel;

// 输入框是否有输入文本
@property(nonatomic,assign,readonly) BOOL hasInputText;

@property(nonatomic,strong,nullable) UIView *inputTopView;


-(NSArray<QCMessageModel*>*) getMessagesWithContentType:(NSInteger)contentType;

-(NSArray<NSString*> *) dates; // 当前列表的所有日期

-(NSArray<QCMessageModel*>*) messagesAtDate:(NSString*)date; // 获取日期对应的消息

/**
 刷新消息对应的cell

 @param messageModel <#messageModel description#>
 */
-(void) refreshCell:(QCMessageModel*) messageModel;

/**
 获取可见的指定下标的cell

 */
-(UITableViewCell*) cellForRowAtIndex:(NSIndexPath*)indexPath;


// 获取当前文本的entity
-(NSArray<QCMessageEntity*>*) entities:(NSString*)text;
-(NSArray<QCMessageEntity*>*) entities:(NSString*)text mentionCache:(QCInputMentionCache*)mentionCache;


// 获取当前文本的@信息
-(QCMentionedInfo*) mentionedInfo:(NSString*)text;
-(QCMentionedInfo*) mentionedInfo:(NSString*)text mentionCache:(QCInputMentionCache*)mentionCache;
/**
 发送消息

 @param content <#content description#>
 */
-(QCMessage*) sendMessage:(QCMessageContent*)content;

// 发送文本消息
-(QCMessage*) sendTextMessage:(NSString*)text;

-(QCMessage*) sendTextMessage:(NSString*)text entities:(nullable NSArray<QCMessageEntity*>*)entities robotID:(nullable NSString*)robotID;
/**
 重发消息
 */
-(void) resendMessage:(QCMessage*)message;

/**
 转发消息
 */
-(void) forwardMessage:(QCMessageContent*)content;


/**
 将输入的文本发送出去
 */
-(void) inputTextToSend;

/**
 往输入框插入文本
 */
-(void) inputInsertText:(NSString *)text;

-(void) inputSetText:(NSString*)text;

/**
 删除范围内的文本
 
 @param range <#range description#>
 */
-(void) inputDeleteText:(NSRange)range;


/**
 获取当前输入框的文本
 
 @return <#return value description#>
 */
-(NSString*) inputText;



/**
 输入框的有效范围
 
 @return <#return value description#>
 */
-(NSRange) inputSelectedRange;



/**
 获取当前会话的频道信息
 
 @return <#return value description#>
 */
-(QCChannelInfo*) getChannelInfo;


/**
 显示当前会话的@用户列表
 */
-(void) showMentionUsers;

-(void) showMentionUsers:(NSString*)keyword;

-(void) hideMentionUsers;

/// 添加@
/// @param uid 被@人的uid
-(void) addMention:(NSString*)uid;



/// 设置多选模式
/// @param multiple <#multiple description#>
-(void) setMultipleOn:(BOOL)multiple selectedMessage:(QCMessageModel * _Nullable)messageModel;

// ---------- 回复相关 ----------

/// 回复
/// @param message <#message description#>
-(void) replyTo:(QCMessage*)message;

// 正在回复的消息
-(QCMessage*) replyingMessage;

// 回复的view
-(UIView*) replyView:(QCMessage*)message;

// 是否有回复
-(BOOL) hasReply;


// ---------- 编辑相关 ----------

/**
 编辑消息
 */
-(void) editTo:(QCMessage*)message;


// 正在编辑中的消息
-(QCMessage*) editingMessage;

// 编辑的view
-(UIView*) editView:(QCMessage*)message;

// 是否有编辑消息
-(BOOL) hasEdit;



/// 定位到指定的消息
/// @param messageSeq  通过消息messageSeq定位消息
-(void) locateMessageCell:(uint32_t)messageSeq;


-(void) inputBecomeFirstResponder;

/// 结束输入
-(void) endEditing;

// 长按消息cell
-(void) longPressMessageCell:(QCMessageCell*)messageCell gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;


///开始录音
- (void)startRecordingVoiceMessage;

// 功能组是否放大
-(BOOL) isFuncGroupZooming;

// 功能组停止放大
-(void) stopFuncGroupZoom;

-(UIViewController*) targetVC;

// 是否被禁言
-(BOOL) forbidden;

// 可见的cell
-(NSArray<UITableViewCell*>*) visibleCells;

// 是否显示最近会话顶部视图
-(void) showConversationTopView:(BOOL)show animated:(BOOL)animated;

// 刷新输入框
-(void) refreshInputView;

-(void) addInputDelegate:(id<QCConversationInputDelegate>)delegate;

-(void) removeInputDelegate:(id<QCConversationInputDelegate>)delegate;

// 导航到指定的消息
-(void) navigateToMessage:(QCMessageModel*)message;

@end

NS_ASSUME_NONNULL_END
