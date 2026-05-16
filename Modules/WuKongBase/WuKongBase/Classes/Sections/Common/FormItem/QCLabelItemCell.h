//
//  QCLabelItemCell.h
//  WuKongBase
//
//  Created by tt on 2020/1/21.
//

#import "QCFormItemCell.h"
#import "QCCopyLabel.h"
#import "QCFormItemModel.h"
#import "QCViewItemCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCLabelItemModel : QCViewItemModel

@property(nonatomic,copy) NSString *value;

@property(nonatomic,strong) UIFont *valueFont;

@property(nonatomic,assign) BOOL valueCopy; // value是否允许复制

+(instancetype) initWith:(NSString*)label value:(NSString*) value;

+(instancetype) initWith:(NSString*)label value:(NSString*) value onClick:(void(^)(QCFormItemModel* model,NSIndexPath *indexPath))onClick;

@end


@interface QCLabelItemCell : QCViewItemCell


@property(nonatomic,strong) QCCopyLabel *valueLbl;

@end

NS_ASSUME_NONNULL_END
