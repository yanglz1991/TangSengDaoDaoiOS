//
//  QCIconTitleItemCell.h
//  QCCore
//
//  Created by tt on 2020/2/2.
//

#import "QCCore.h"
#import "QCFormItemCell.h"
NS_ASSUME_NONNULL_BEGIN


@interface QCIconTitleItemModel : QCFormItemModel
// 标题
@property(nonatomic,copy) NSString *title;
// icon宽度
@property(nonatomic,strong) NSNumber *width;
// icon高度
@property(nonatomic,strong) NSNumber *height;
// icon的url
@property(nonatomic,copy) NSString *iconURL;
// icon图像
@property(nonatomic,strong) UIImage *icon;

// icon是否显示为圆形
@property(nonatomic,assign) BOOL circular;

@end

@interface QCIconTitleItemCell : QCCell
@property(nonatomic,strong) UIImageView *iconImageView; // 头像
@property(nonatomic,strong) UILabel *titleLbl; // 标题


@end

NS_ASSUME_NONNULL_END
