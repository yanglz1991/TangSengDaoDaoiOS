//
//  QCConversationView.h
//  WuKongBase
//
//  Created by tt on 2022/5/18.
//

#import <UIKit/UIKit.h>
#import "QCMessageListView.h"
#import "QCConversationVM.h"
#import "QCRobotMenusListView.h"
#import "QCConversationTopView.h"
@class QCConversationView;
@class QCConversationContextImpl;
NS_ASSUME_NONNULL_BEGIN

@protocol QCConversationViewDelegate <NSObject>

@optional

//  面板弹出或缩回
-(void) conversationView:(QCConversationView*)conversationView inputPanelUpOrDown:(BOOL)up;


@end

@interface QCConversationView : UIView


- (instancetype)initWithFrame:(CGRect)frame channel:(QCChannel*)channel;

@property(nonatomic,strong) QCConversationVM *conversationVM; // 会话ViewModel

@property(nonatomic,strong) QCConversationContextImpl *conversationContext; // 最近会话上下文

@property(nonatomic,strong) QCChannel *channel;

@property(nonatomic,weak) id<QCConversationViewDelegate> delegate;

/// 定位的orderSeq （如果有值，则会定位到此order_seq的消息）
@property(nonatomic,assign) uint32_t locationAtOrderSeq;

@property(nonatomic,assign) BOOL keepKeyboard; // 是否保持键盘状态



@property(nonatomic,strong) QCConversationTopView *topView; // 最近会话顶部视图

@property(nonatomic,strong) QCMessageListView *messageListView; // 消息列表

@property(nonatomic,strong)  QCConversationInputPanel *input; // 输入框面板

@property(nonatomic,strong,nullable) UIView *inputParentView; // 输入框的父视图（非必需）如果为空则表示当前view

@property(nonatomic,assign) CGFloat tableOffsetY; // table Y轴的偏移量，使用完记得恢复为0



-(BOOL) setGroupForbiddenIfNeed; // 按需显示群禁言面板


- (void)viewWillDisappear:(BOOL)animated;

-(void) viewDidLoad;

- (void)viewDidAppear;
-(void) viewWillAppear;
-(void) viewDidDisappear;


//-(void) reloadData;

// ---------- 多选 ----------
@property(nonatomic,copy) void(^onMultiple)(BOOL on);
-(void) setMultipleOn:(BOOL)multiple selectedMessage:(QCMessageModel * _Nullable)messageModel; // 多选设置


// ---------- 回复 ----------
@property(nonatomic,strong,nullable) QCMessage *replyMessage; // 需要回复的消息

@property(nonatomic,strong,nullable) QCMessage *editMessage; // 需要编辑的消息

// ---------- robot ----------
@property(nonatomic,strong) QCRobotMenusListView *robotMenusModalView;
@property(nonatomic,strong) NSArray<QCRobotMenus*> *robotMenus; // 机器人菜单
@property(nonatomic,assign) BOOL robotInlineOn; // 是否开启了机器人行内搜索
@property(nonatomic,strong) QCRobot *currentRobotInline; // 当前行内机器人

// 显示顶部视图
-(void) showTopView:(BOOL)show animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
