//
//  QCContactsAddFunctionItemCell.h
//  QCCore
//
//  Created by tt on 2020/6/22.
//

#import <UIKit/UIKit.h>
#import <QCCore/QCCore.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCContactsAddFunctionItemModel : QCFormItemModel
// 标题
@property(nonatomic,copy) NSString *title;
// 子标题
@property(nonatomic,copy) NSString *subtitle;
// icon图像
@property(nonatomic,strong) UIImage *icon;

@end

@interface QCContactsAddFunctionItemCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
