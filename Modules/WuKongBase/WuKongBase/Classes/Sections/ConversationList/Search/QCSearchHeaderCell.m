//
//  QCSearchHeaderCell.m
//  WuKongBase
//
//  Created by tt on 2020/4/25.
//

#import "QCSearchHeaderCell.h"

@implementation QCSearchHeaderModel
- (Class)cell {
    return QCSearchHeaderCell.class;
}

@end

@interface QCSearchHeaderCell ()

@property(nonatomic,strong) UILabel *titleLbl;

@end

@implementation QCSearchHeaderCell

+(CGSize) sizeForModel:(QCFormItemModel*)model{
    return CGSizeMake(QCScreenWidth, 40.0f);
}

- (void)setupUI {
    [super setupUI];
    
    self.titleLbl = [[UILabel alloc] init];
    [self.titleLbl setFont:[UIFont systemFontOfSize:15.0f]];
    [self.titleLbl setTextColor:[UIColor grayColor]];
    [self addSubview:self.titleLbl];
    
}

- (void)refresh:(QCSearchHeaderModel *)model {
    [super refresh:model];
    self.titleLbl.text = model.title;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleLbl sizeToFit];
    
    self.titleLbl.lim_left = 20.0f;
    self.titleLbl.lim_top = [self lim_centerY:self.titleLbl];
    
}
@end
