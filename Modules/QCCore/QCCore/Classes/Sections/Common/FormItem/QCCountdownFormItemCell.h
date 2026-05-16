//
//  QCCountdownFormItemCell.h
//  QCCore
//
//  Created by tt on 2022/11/21.
//

#import "QCCell.h"
#import "QCLabelItemCell.h"
#import "UIView+WK.h"
#import "QCConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCCountdownFormItemModel: QCLabelItemModel

@property(nonatomic,assign) NSInteger second;

@end

@interface QCCountdownFormItemCell : QCLabelItemCell

@end

NS_ASSUME_NONNULL_END
