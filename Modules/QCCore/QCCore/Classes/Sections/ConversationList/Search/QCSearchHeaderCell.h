//
//  QCSearchHeaderCell.h
//  QCCore
//
//  Created by tt on 2020/4/25.
//

#import <QCCore/QCCore.h>
#import "QCFormItemCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCSearchHeaderModel : QCFormItemModel

@property(nonatomic,copy) NSString *title;

@end

@interface QCSearchHeaderCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
