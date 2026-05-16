//
//  QCBlacklistCell.m
//  QCCore
//
//  Created by tt on 2020/6/26.
//

#import "QCBlacklistCell.h"

@implementation QCBlacklistModel


@end

@interface QCBlacklistCell ()
@property(nonatomic,strong) UILabel *nameLbl;
@end

@implementation QCBlacklistCell

- (void)setupUI {
    [super setupUI];
    [self addSubview:self.nameLbl];
}

- (void)refresh:(QCBlacklistModel*)cellModel {
    [super refresh:cellModel];
    self.nameLbl.text = cellModel.name;
    [self.nameLbl sizeToFit];
    
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
    }
    return _nameLbl;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.nameLbl.lim_left = 15.0f;
    self.nameLbl.lim_top = self.lim_height/2.0f - self.nameLbl.lim_height/2.0f;
}

+ (NSString *)cellId {
    return @"QCBlacklistCell";
}

@end
