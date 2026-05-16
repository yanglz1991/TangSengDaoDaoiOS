//
//  QCFuncGroupEditItemCell.h
//  QCCore
//
//  Created by tt on 2022/5/5.
//

#import "QCCore.h"
#import "QCFuncGroupEditItemModel.h"
NS_ASSUME_NONNULL_BEGIN


@interface QCFuncGroupEditItemCell : UITableViewCell

@property(nonatomic,strong) UISwitch *enableSwitch;

@property(nonatomic,copy) void(^onSwitch)(BOOL on);

-(void) refresh:(QCFuncGroupEditItemModel*) item;

@end

NS_ASSUME_NONNULL_END
