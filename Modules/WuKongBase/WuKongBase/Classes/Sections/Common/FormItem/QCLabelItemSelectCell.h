//
//  QCLabelItemSelectCell.h
//  WuKongBase
//
//  Created by tt on 2020/12/11.
//

#import "QCLabelItemCell.h"

NS_ASSUME_NONNULL_BEGIN


@interface QCLabelItemSelectModel : QCLabelItemModel

@property(nonatomic,assign) BOOL selected;

@end

@interface QCLabelItemSelectCell : QCLabelItemCell

@end

NS_ASSUME_NONNULL_END
