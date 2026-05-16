//
//  QCCheckBoxCell.h
//  QCCore
//
//  Created by tt on 2023/9/28.
//

#import "QCViewItemCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCCheckBoxModel : QCViewItemModel

@property(nonatomic,assign) BOOL on;
@property(nonatomic,copy) void(^onCheck)(BOOL on);

@end



@interface QCCheckBoxCell : QCViewItemCell

@end

NS_ASSUME_NONNULL_END
