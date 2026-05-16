//
//  QCButtonItemCell.h
//  WuKongBase
//
//  Created by tt on 2020/1/27.
//

#import "QCFormItemCell.h"
#import "QCFormItemModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCButtonItemModel : QCFormItemModel

@property(nonatomic,copy) NSString *title;

@property(nonatomic,strong) UIColor *color;

@end

@interface QCButtonItemCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
