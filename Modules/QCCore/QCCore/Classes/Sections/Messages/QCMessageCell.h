//
//  QCMessageCell.h
//  QCCore
//
//  Created by tt on 2019/12/28.
//

#import "QCMessageBaseCell.h"
#import "QCImageView.h"
#import "QCCore.h"
#import "QCMessageContentView.h"
#import "QCCheckBox.h"
#import "QCTrailingView.h"
#import "QCTapLongTapOrDoubleTapGestureRecognizerEvent.h"
#import "QCUserAvatar.h"
@class TapLongTapOrDoubleTapGestureRecognizerWrap;
@class ContextExtractedContentContainingNode;
@class QCMessageCell;
@class QCBubbleBackgroundView;
NS_ASSUME_NONNULL_BEGIN

// 昵称文本高度
#define WK_NICKNAME_HEIGHT 17.0f
#define WK_NICKNAME_MAX_WIDTH 100.0f
#define WK_NICKNAME_FONT  [[QCApp shared].config appFontOfSize:14.0f]


#define WK_CONTENT_INSETS  UIEdgeInsetsMake(8.0f, 12.0f, 8.0f, 12.0f) // 正文边距

#define WK_BUBBLE_INSETS  UIEdgeInsetsMake(0.0f, 5.0f, 4.0f, 5.0f) // 气泡边距

#define WK_AVATAR_SIZE CGSizeMake(45.0f,45.0f) // 头像大小



// 最后那个气泡偏移指定距离 为了与其他气泡对齐(左或右的边距)
#define QCLastBubbleOffsetSpace 0.0f

typedef enum : NSUInteger {
    QCBubblePostionUnknown,
    QCBubblePostionFirst, // 连续消息的第一条消息
    QCBubblePostionMiddle, // 连续消息的中间消息
    QCBubblePostionLast, // 连续消息的最后一条消息
    QCBubblePostionSingle, // 单条
} QCBubblePostion;

typedef enum :NSUInteger {
    QCMessageTapActionSingleTap, // 单击
    QCMessageTapActionLongPress, // 长按
} QCMessageTapAction;

@interface QCMessageCell : QCMessageBaseCell

@property(nonatomic,copy,nullable) void(^onPrepareForReuse)(void); // 即将被复用

// 名字
@property(nonatomic,strong) UILabel *nameLbl;
// 气泡背景


@property(nonatomic,strong) ContextExtractedContentContainingNode *mainContextSourceNode;

@property(nonatomic,strong) UIImageView *bubbleBackgroundView;

// 头像
@property(nonatomic,strong) QCUserAvatar *avatarImgView;
// 发送失败按钮
@property(nonatomic,strong) UIView *sendFailBtn;

@property(nonatomic,assign) BOOL showNavigateToMessage; // 是否显示跳转到消息的按钮

@property(nonatomic,strong) QCTrailingView *trailingView; // 消息尾部视图

@property(nonatomic,assign) BOOL tailWrap; // 尾部是否wrap

@property(nonatomic,strong) QCCheckBox *checkBox;

@property(nonatomic,assign) BOOL showCheckBox; // 是否显示checkBox

@property(nonatomic,strong) UIView *flameBox;
/**
 自定义消息Cell的正文大小 继承WKMessageCell的不需要实现sizeForMessage只需要实现contentSizeForMessage
 
 @param model  要显示的消息model
 @return 返回消息的大小
 */
+ (CGSize) contentSizeForMessage:(QCMessageModel *)model;
/**
 消息正文视图
 */
@property(nonatomic,strong) QCMessageContentView *messageContentView;


// 点击
-(void) onTap;
-(void) onTapWithGestureRecognizer:(TapLongTapOrDoubleTapGestureRecognizerWrap*)gesture;

// 正文边距
+(UIEdgeInsets) contentEdgeInsets:(QCMessageModel*) model;
// 气泡边距
+(UIEdgeInsets) bubbleEdgeInsets:(QCMessageModel*) model contentSize:(CGSize)contentSize;


/// 是否隐藏气泡
+ (BOOL) hiddenBubble;

/// 隐藏阅后即焚的进度条
-(BOOL) hiddenFlameProgress;

/// 动画呈现或隐藏checkbox
/// @param show <#show description#>
-(void) animationCheckBox:(BOOL)show;


/**
 获取消息的气泡位置
 */
+(QCBubblePostion) bubblePosition:(QCMessageModel*)messageModel;


// 布局回应
-(void) layoutReaction;

/**
 重写此方法 自定义name的布局
 */
-(void) layoutName;

+(BOOL) isShowName:(QCMessageModel*)model;


// 获取发送者名字
+(NSString*) getFromName:(QCMessageModel*)messageModel;

// 获取昵称大小
+(CGSize) getNicknameSize:(QCMessageModel*)messageModel;

-(void) startReminderAnimation;

-(BOOL) respondContentSingleTap; // 是否响应正文单点

// 响应tap或longTap 或doubleTap
// 当用户点击某个point位置时 返回对应的行为
-(QCTapLongTapOrDoubleTapGestureRecognizerEvent*) tapActionAtPoint:(CGPoint)point;
// 响应上述方法返回的行为
-(void) tapLongTapOrDoubleTapGesture:(TapLongTapOrDoubleTapGestureRecognizerWrap*)recognizer;



@end

@interface QCBubbleBackgroundView : UIImageView

@property(nonatomic,assign) CGRect originalViewFrame; //  原始大小

@property(nonatomic,copy) void(^onAnimateCompletion)(void); // 完成动画

@end

NS_ASSUME_NONNULL_END
