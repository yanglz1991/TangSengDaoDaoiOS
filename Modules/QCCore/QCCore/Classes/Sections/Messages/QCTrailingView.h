//
//  QCTrailingView.h
//  QCCore
//
//  Created by tt on 2021/9/17.
//

#import <UIKit/UIKit.h>
#import "QCMessageModel.h"

// 尾部
#define QCTrailingLeft 20.0f // 最后尾部左边间距
#define QCTimeLeftSpace 2.0f // 时间左边距离
#define QCTimeFontSize 10.0f // 时间字体大小
#define QCTimeHeight 12.0f
#define QCEditTipHeight 10.0f // 编辑提示高度
#define QCEditTipFontSize 9.0f // 编辑提示文字大小
#define QCStatusSize CGSizeMake(12.0f,12.0f)
#define QCSecurityLockSize CGSizeMake(12.0f,12.0f)
#define QCStatusLeft 2.0f // 状态icon左边距离
#define QCSecurityLockRight 2.0f // 安全锁右边距离
#define QCPinnedIconSize CGSizeMake(12.0f,12.0f) // 置顶的icon大小

NS_ASSUME_NONNULL_BEGIN

@class QCMessageCell;

@interface QCTrailingView : UIView

@property(nonatomic,weak) QCMessageCell *messageCell;
// 尾部
@property(nonatomic,strong) UIView *trailingContentView; // 消息尾部视图
@property(nonatomic,strong) UIImageView *statusImgView; // 消息状态
@property(nonatomic,strong) UILabel *timeLbl; // 时间
@property(nonatomic,strong) UIImageView *securityLockImgView; // 安全锁，有此锁说明消息进行了端对端加密
@property(nonatomic,strong) UILabel *editTipLbl; // 编辑提醒

@property(nonatomic,strong) UIImageView *pinnedImgView; // 置顶icon

@property(nonatomic,assign) BOOL tailWrap; // 尾部是否wrap（是否包含背景框）


+(CGSize) size:(QCMessageModel*)message;


-(void) refresh:(QCMessageModel*)messageModel;



/**
 让尾部状态视图包裹起来
 */
-(void) layoutTailWrap;

@end

NS_ASSUME_NONNULL_END
