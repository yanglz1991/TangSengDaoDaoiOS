//
//  QCFormItemModel.m
//  QCCore
//
//  Created by tt on 2020/1/21.
//

#import "QCFormItemModel.h"
#import "QCFormItemCell.h"

@interface QCFormItemModel ()


@end

@implementation QCFormItemModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bottomLeftSpace  = @(20.0f);
    }
    return self;
}
- (Class)cell {
    return QCFormItemCell.class;
}

- (CGFloat)cellHeight {
    if(_cellHeight>0) {
        return _cellHeight;
    }
    return [self defaultCellHeight];
}

-(CGFloat) defaultCellHeight {
    return 54.0f;
}
@end
