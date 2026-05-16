//
//  QCLottieStickerCell.h
//  QCCore
//
//  Created by tt on 2021/8/26.
//

#import <QCCore/QCCore.h>
//#import <SDWebImageLottieCoder/SDWebImageLottieCoder.h>
#import "QCStickerImageView.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCLottieStickerCell : QCMessageCell

@property(nonatomic,strong) QCStickerImageView *animatedImageView;

@end

NS_ASSUME_NONNULL_END
