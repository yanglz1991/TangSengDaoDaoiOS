//
//  QCUserHeaderCell.h
//  WuKongCustomerService
//
//  Created by tt on 2022/4/8.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCUserHeaderModel : QCFormItemModel

@property(nonatomic,copy) NSString *avatar;
@property(nonatomic,copy) NSString *name;


@end

@interface QCUserHeaderCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
