//
//  QCAnimateIconCell.h
//  WuKongMessagePrivacy
//
//  Created by tt on 2023/9/25.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCAnimateIconModel : QCFormItemModel

@property(nonatomic,assign) CGFloat width;
@property(nonatomic,assign) CGFloat height;

@property(nonatomic,strong) UIImage *icon;
@property(nonatomic,strong) NSURL *iconURL;

@end

@interface QCAnimateIconCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
