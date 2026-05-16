//
//  QCViewItemCell.h
//  QCCore
//
//  Created by tt on 2020/1/22.
//

#import "QCFormItemCell.h"
#import "QCFormItemModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCViewItemModel : QCFormItemModel

@property(nonatomic,copy) NSString *label;

@property(nonatomic,copy) UIColor *labelColor;

@end

@interface QCViewItemCell : QCFormItemCell
@property(nonatomic,strong) UILabel *labelLbl;
@property(nonatomic,strong) UIView *valueView;

@end

NS_ASSUME_NONNULL_END
