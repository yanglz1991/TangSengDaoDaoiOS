//
//  QCButtonItemCell.m
//  WuKongBase
//
//  Created by tt on 2020/1/27.
//

#import "QCButtonItemCell.h"
#import "UIView+WK.h"

@implementation QCButtonItemModel

- (Class)cell {
    return QCButtonItemCell.class;
}

- (NSNumber *)showArrow {
    return @(NO);
}

- (UIColor *)color {
    if(!_color) {
        return [UIColor redColor];
    }
    return _color;
}
@end

@interface QCButtonItemCell ()

@property(nonatomic,strong) UILabel *titleLbl;

@end
@implementation QCButtonItemCell

- (void)setupUI {
    [super setupUI];
    self.titleLbl = [[UILabel alloc] init];
    [self.titleLbl setTextAlignment:NSTextAlignmentCenter];

    [self addSubview:self.titleLbl];
}

- (void)refresh:(QCButtonItemModel*)cellModel {
    [super refresh:cellModel];
    self.titleLbl.text = cellModel.title?:@"";
    [self.titleLbl setTextColor:cellModel.color];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLbl.lim_size = self.lim_size;
}
@end
