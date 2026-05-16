//
//  QCEmojiContentView.h
//  QCCore
//
//  Created by tt on 2020/1/10.
//

#import <UIKit/UIKit.h>
#import "QCEmoticonService.h"
#import "QCStickerContentView.h"
NS_ASSUME_NONNULL_BEGIN


@interface QCEmojiContentView : QCStickerContentView

// emoji点击
@property(nonatomic,copy) void(^onEmoji)(QCEmotion *emoji);


@end

NS_ASSUME_NONNULL_END
