//
//  QCMeItemCell.h
//  QCCore
//
//  Created by tt on 2020/6/9.
//

#import <QCCore/QCCore.h>
#import "QCFormItemCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMeItemModel : QCFormItemModel
// 标题
@property(nonatomic,copy) NSString *title;
// icon图像
@property(nonatomic,strong) UIImage *icon;

@end

@interface QCMeItemCell : QCCell

@end

NS_ASSUME_NONNULL_END
