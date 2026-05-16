//
//  QCCheckBoxCell.m
//  QCCore
//
//  Created by tt on 2023/9/28.
//

#import "QCCheckBoxCell.h"
#import "QCCheckBox.h"
#import "QCApp.h"
@implementation QCCheckBoxModel

- (Class)cell {
    return QCCheckBoxCell.class;
}

@end

@interface QCCheckBoxCell ()<QCCheckBoxDelegate>

@property(nonatomic,strong) QCCheckBox *checkbox;

@property(nonatomic,strong) QCCheckBoxModel *model;
 
@end

@implementation QCCheckBoxCell

- (void)setupUI {
    [super setupUI];
    [self.valueView addSubview:self.checkbox];
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkboxPressed)];
    [self addGestureRecognizer:tap];
}

- (void)refresh:(QCCheckBoxModel *)model {
    [super refresh:model];
    self.model = model;
    
    self.checkbox.on = model.on;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.checkbox.lim_left = self.valueView.lim_width - self.checkbox.lim_width;
    self.checkbox.lim_centerY_parent = self.valueView;
}

- (QCCheckBox *)checkbox {
    if(!_checkbox) {
        _checkbox = [[QCCheckBox alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
        _checkbox.onFillColor = [QCApp shared].config.themeColor;
        _checkbox.onCheckColor = [UIColor whiteColor];
        _checkbox.onAnimationType = BEMAnimationTypeBounce;
        _checkbox.offAnimationType = BEMAnimationTypeBounce;
        _checkbox.animationDuration = 0.0f;
        _checkbox.lineWidth = 1.0f;
        _checkbox.tintColor = [UIColor grayColor];
        _checkbox.onTintColor =[QCApp shared].config.themeColor;
        _checkbox.delegate = self;
    }
    return _checkbox;
}

-(void) checkboxPressed {
    [self.checkbox setOn:!self.checkbox.on animated:YES];
    if(self.model.onCheck) {
        self.model.onCheck(self.checkbox.on);
    }
    
}

- (void)didTapCheckBox:(QCCheckBox*)checkBox {
    if(self.model.onCheck) {
        self.model.onCheck(checkBox.on);
    }
}

@end
