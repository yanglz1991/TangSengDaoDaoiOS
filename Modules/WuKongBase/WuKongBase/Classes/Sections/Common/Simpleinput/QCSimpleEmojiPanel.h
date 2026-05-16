//
//  QCSimpleEmojiPanel.h
//  WuKongBase
//
//  Created by tt on 2020/11/18.
//

#import <UIKit/UIKit.h>
#import "QCConstant.h"
#import "UIView+WK.h"
#import "QCEmoticonService.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCSimpleEmojiPanel : UIView

@property(nonatomic,copy) void(^onSend)(void); // 发送消息

@property(nonatomic,copy) void(^onEmoji)(QCEmotion *emoji); // emoji点击

-(void) layoutPanel:(CGFloat)height;


@end

NS_ASSUME_NONNULL_END
