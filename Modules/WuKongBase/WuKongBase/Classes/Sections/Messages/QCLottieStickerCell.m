//
//  QCLottieStickerCell.m
//  WuKongBase
//
//  Created by tt on 2021/8/26.
//

#import "QCLottieStickerCell.h"
#import "QCLottieStickerContent.h"
#import "QCStickerImageView.h"
#import <WuKongBase/WuKongBase-Swift.h>

#define QCLottieImgSize CGSizeMake(160.0f,160.0f)

@interface QCLottieStickerCell ()


@end

@implementation QCLottieStickerCell

- (void)onWillDisplay {
    self.animatedImageView.isPlay = true;
}

- (void)onEndDisplay {
    self.animatedImageView.isPlay = false;
}

+ (CGSize)contentSizeForMessage:(QCMessageModel *)model {
    
    return QCLottieImgSize;
}

-(void) initUI {
    [super initUI];
    
    [self.messageContentView addSubview:self.animatedImageView];
    [self.messageContentView bringSubviewToFront:self.trailingView];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.animatedImageView.isPlay = false;
}

- (void)refresh:(QCMessageModel *)model {
    [super refresh:model];
    
    QCLottieStickerContent *content = (QCLottieStickerContent*)model.content;
    
    self.animatedImageView.placehoderSvg = content.placeholder; // placehoderSvg必须现在stickerURL的前面
    self.animatedImageView.stickerURL = [[QCApp shared] getFileFullUrl:content.url];
    
    
}

- (void)onTap {
    QCLottieStickerContent *content = (QCLottieStickerContent*)self.messageModel.content;
    
    [QCApp.shared invoke:QCPOINT_TO_STICKER_INFO param:@{
        @"category":content.category?:@"",
        @"sticker_url":content.url?:@"",
        @"placeholder_svg":content.placeholder?:@"",
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (BOOL)tailWrap {
    return true;
}

+ (BOOL)hiddenBubble {
    return YES;
}

- (QCStickerImageView *)animatedImageView {
    if(!_animatedImageView) {
        _animatedImageView = [[QCStickerImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCLottieImgSize.width, QCLottieImgSize.height)];
        [_animatedImageView setUserInteractionEnabled:NO];
//        _animatedImageView.shouldCustomLoopCount = NO;
//        _animatedImageView.animationRepeatCount = 0;
//        _animatedImageView.clearBufferWhenStopped = YES;
    }
    return _animatedImageView;
}

@end
