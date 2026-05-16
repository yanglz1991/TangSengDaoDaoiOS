//
//  QCMessageBaseCell.h
//  WuKongBase
//
//  Created by tt on 2019/12/28.
//

#import <UIKit/UIKit.h>
#import "QCMessageModel.h"
#import "QCConstant.h"
#import "UIView+WK.h"
#import "QCApp.h"
#import "QCConversationContext.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMessageBaseCell : UITableViewCell

@property(nonatomic,weak) id<QCConversationContext> conversationContext;

@property(nonatomic,strong) QCMessageModel *messageModel;

/**
 自定义消息Cell的Size

 @param model  要显示的消息model
 @return 返回消息的大小
 */
+ (CGSize)sizeForMessage:(QCMessageModel *)model;


/**
 刷新消息

 @param model 消息的model
 */
- (void)refresh:(QCMessageModel *)model;

/**
 消息cell初始化
 */
-(void) initUI;

-(void) onWillDisplay;

-(void) onEndDisplay;

@end

NS_ASSUME_NONNULL_END
