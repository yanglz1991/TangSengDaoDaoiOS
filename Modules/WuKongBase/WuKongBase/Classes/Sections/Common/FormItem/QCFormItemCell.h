//
//  QCFormItemCell.h
//  WuKongBase
//
//  Created by tt on 2020/1/21.
//

#import "QCCell.h"
#import "QCFormItemModel.h"
#import "UIView+WK.h"
#import "QCConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCFormItemCell : QCCell

@property(nonatomic,strong) UIImageView *arrowImgView; // 箭头

+(CGSize) sizeForModel:(QCFormItemModel*)model;

-(void) refresh:(QCFormItemModel*)model;

-(void) onWillDisplay;

-(void) onEndDisplay;
@end

NS_ASSUME_NONNULL_END
