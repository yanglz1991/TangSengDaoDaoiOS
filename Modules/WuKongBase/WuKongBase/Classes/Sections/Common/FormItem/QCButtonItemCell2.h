//
//  QCButtonItemCell2.h
//  WuKongBase
//
//  Created by tt on 2020/8/17.
//

#import "QCFormItemCell.h"

NS_ASSUME_NONNULL_BEGIN
@interface QCButtonItemModel2 : QCFormItemModel

@property(nonatomic,assign) CGFloat width;
@property(nonatomic,assign) CGFloat height;

@property(nonatomic,copy) NSString *title;

@property(nonatomic,copy) void(^onPressed)(void);

@end

@interface QCButtonItemCell2 : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
