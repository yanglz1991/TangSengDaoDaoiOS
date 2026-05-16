//
//  QCButtonItemCell2.m
//  QCCore
//
//  Created by tt on 2020/8/17.
//

#import "QCButtonItemCell2.h"
#import "QCApp.h"

@implementation QCButtonItemModel2

- (Class)cell {
    return QCButtonItemCell2.class;
}

- (NSNumber *)showArrow {
    return @(false);
}
@end

@interface QCButtonItemCell2 ()

@property(nonatomic,strong) UIButton *btn;

@property(nonatomic,strong) QCButtonItemModel2 *model;

@end
@implementation QCButtonItemCell2

+ (CGSize)sizeForModel:(QCButtonItemModel2 *)model {
    return CGSizeMake(model.width>0?model.width:QCScreenWidth, model.height>0?model.height:44.0f);
}

- (void)setupUI {
    [super setupUI];
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.btn];
}

- (UIButton *)btn {
    if(!_btn) {
        _btn = [[UIButton alloc] init];
        [_btn setBackgroundColor:[QCApp shared].config.themeColor];
        _btn.layer.masksToBounds = YES;
        _btn.layer.cornerRadius = 4.0f;
    }
    return _btn;
}

- (void)refresh:(QCButtonItemModel2*)cellModel {
    [super refresh:cellModel];
    self.model = cellModel;
    [self.btn setTitle:cellModel.title?:@"" forState:UIControlStateNormal];
    
    [self.btn removeTarget:self action:@selector(btnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.btn addTarget:self action:@selector(btnPressed) forControlEvents:UIControlEventTouchUpInside];
}

-(void) btnPressed {
    if(self.model.onPressed) {
        self.model.onPressed();
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.btn.lim_height = self.lim_height;
    if(self.model.width>0) {
        self.btn.lim_width  = self.model.width;
    }else {
        self.btn.lim_width  = self.lim_width - 30.0f;
    }
    
    self.btn.lim_left = self.lim_width/2.0f - self.btn.lim_width/2.0f;
}
@end
