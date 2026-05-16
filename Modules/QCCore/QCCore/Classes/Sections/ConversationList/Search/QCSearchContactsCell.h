//
//  QCSearchContactsCell.h
//  QCCore
//
//  Created by tt on 2020/4/25.
//

#import "QCFormItemCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCSearchContactsModel : QCFormItemModel

@property(nonatomic,copy) NSString *avatar; // 头像
@property(nonatomic,copy) NSString *name; // 昵称
@property(nonatomic,copy) NSString *contain; // 包含的关键字
@property(nonatomic,copy) NSString *keyword; //变色的文字

@end

@interface QCSearchContactsCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
