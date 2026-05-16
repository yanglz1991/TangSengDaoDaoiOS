//
//  QCUserHeaderCell.h
//  QCCustomerService
//
//  Created by tt on 2022/4/8.
//

#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCUserHeaderModel : QCFormItemModel

@property(nonatomic,copy) NSString *avatar;
@property(nonatomic,copy) NSString *name;


@end

@interface QCUserHeaderCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
