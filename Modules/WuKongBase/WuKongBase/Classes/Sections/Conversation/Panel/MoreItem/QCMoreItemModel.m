//
//  QCMoreItemModel.m
//  WuKongBase
//
//  Created by tt on 2020/1/12.
//

#import "QCMoreItemModel.h"
#import "QCCommonMoreItemCell.h"
@interface QCMoreItemModel ()




@end

@implementation QCMoreItemModel

+(QCMoreItemModel*) initWithImage:(UIImage*)image title:(NSString*)title onClick:(onClickBlock)onClickBlock {
    QCMoreItemModel *model = [QCMoreItemModel new];
    model.image = image;
    model.title = title;
    model.oncClickBLock = onClickBlock;
    return model;
}

+(Class) moreItemCellClass {
    return [QCCommonMoreItemCell class];
}
@end
