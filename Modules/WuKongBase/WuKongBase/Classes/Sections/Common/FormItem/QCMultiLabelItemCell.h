//
//  QCMulitLabelItemCell.h
//  WuKongBase
//
//  Created by tt on 2020/1/30.
//


#import "QCFormItemCell.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    QCMultiLabelItemModeUpDown, // 标题和值采用上下布局
    QCMultiLabelItemModeLeftRight, // 标题和值才有左右布局
} QCMultiLabelItemMode;

@interface QCMultiLabelItemModel : QCFormItemModel
// label
@property(nonatomic,copy) NSString *label;
// value
@property(nonatomic,copy) NSString *value;

@property(nonatomic,strong) NSNumber *mode; // QCMultiLabelItemMode

@end

@interface QCMultiLabelItemCell : QCFormItemCell



@end

NS_ASSUME_NONNULL_END
