//
//  QCIconItemCell.h
//  WuKongBase
//
//  Created by tt on 2020/1/22.
//

#import  "WuKongBase.h"
#import "QCViewItemCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCIconItemModel : QCViewItemModel

@property(nonatomic,strong) NSNumber *width;
@property(nonatomic,strong) NSNumber *height;

@property(nonatomic,strong) UIImage *icon;

@end

@interface QCIconItemCell : QCViewItemCell

@property(nonatomic,strong) UIImageView *iconImgView;

@end

NS_ASSUME_NONNULL_END
