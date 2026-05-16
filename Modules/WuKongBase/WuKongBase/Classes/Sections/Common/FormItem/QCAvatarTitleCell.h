//
//  QCAvatarTitleCell.h
//  WuKongBase
//
//  Created by tt on 2022/11/7.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCAvatarTitleModel : QCFormItemModel

@property(nonatomic,copy) NSString *avatar;
@property(nonatomic,copy) NSString *name;


@end

@interface QCAvatarTitleCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
