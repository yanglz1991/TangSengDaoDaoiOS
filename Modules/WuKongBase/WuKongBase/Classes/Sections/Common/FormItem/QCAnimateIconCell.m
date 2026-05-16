//
//  QCAnimateIconCell.m
//  WuKongMessagePrivacy
//
//  Created by tt on 2023/9/25.
//

#import "QCAnimateIconCell.h"

@implementation QCAnimateIconModel

- (Class)cell {
    return QCAnimateIconCell.class;
}

- (CGFloat)width {
    if(_width <=0) {
        return 72.0f;
    }
    return _width;
}

- (CGFloat)height {
    if(_height <= 0) {
        return 72.0f;
    }
    return _height;
}

@end

@interface QCAnimateIconCell ()

@property(nonatomic,strong) UIImageView *iconImgView;

@property(nonatomic,strong) QCAnimateIconModel *model;

@end

@implementation QCAnimateIconCell

+ (CGSize)sizeForModel:(QCAnimateIconModel *)model {
    return CGSizeMake(QCScreenWidth, model.height);
}

- (void)setupUI {
    [super setupUI];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.contentView addSubview:self.iconImgView];
}

- (void)refresh:(QCAnimateIconModel *)model {
    [super refresh:model];
    
    if(model.icon) {
        self.iconImgView.image = model.icon;
    }else if(model.iconURL) {
        [self.iconImgView sd_setImageWithURL:model.iconURL];
    }
   
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconImgView.lim_size = CGSizeMake(self.model.width, self.model.height);
    
    self.iconImgView.lim_centerX_parent = self;
}

- (UIImageView *)iconImgView {
    if(!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
    }
    return _iconImgView;
}

@end
