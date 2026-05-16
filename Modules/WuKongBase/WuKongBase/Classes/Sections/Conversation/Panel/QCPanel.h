//
//  QCPanel.h
//  WuKongBase
//
//  Created by tt on 2020/1/11.
//

#import <Foundation/Foundation.h>
#import "QCConversationContext.h"
#import "QCInputChangeTextRespondProto.h"
NS_ASSUME_NONNULL_BEGIN


@interface QCPanel : UIView

-(instancetype) initWithContext:(id<QCConversationContext>) context;

@property(nonatomic,weak) id<QCConversationContext> context;

@property(nonatomic,strong) UIView *contentView;

/**
 往输入框插入文本
 */
-(void) inputInsertText:(NSString *)text;

-(void) layoutPanel:(CGFloat)height;


@end

NS_ASSUME_NONNULL_END
