//
//  QCSwitchItemCell.h
//  QCCore
//
//  Created by tt on 2020/1/22.
//

#import "QCCore.h"
#import "QCViewItemCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCSwitchItemModel : QCViewItemModel

@property(nonatomic,strong) NSNumber *on;

@property(nonatomic,assign) BOOL disable;

@property(nonatomic,strong) void(^onSwitch)(BOOL);

@end

@interface QCSwitchItemCell : QCViewItemCell

@end

NS_ASSUME_NONNULL_END
