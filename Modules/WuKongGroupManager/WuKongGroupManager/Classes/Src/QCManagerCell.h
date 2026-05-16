//
//  QCManagerCell.h
//  WuKongBase
//
//  Created by tt on 2020/4/1.
//

#import "QCViewItemCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCManagerModel : QCViewItemModel


/// 管理员头像
@property(nonatomic,copy) NSString *icon;


/// 管理员名称
@property(nonatomic,copy) NSString *title;


/// 是否显示减号
@property(nonatomic,assign) BOOL showSub;


/// 删除点击
@property(nonatomic,strong) void(^onSub)(void);

@end

@interface QCManagerCell : QCViewItemCell


@end

@interface QCManagerAddModel : QCViewItemModel

/// 管理员名称
@property(nonatomic,copy) NSString *title;

@end

@interface QCManagerAddCell : QCViewItemCell


@end

NS_ASSUME_NONNULL_END
