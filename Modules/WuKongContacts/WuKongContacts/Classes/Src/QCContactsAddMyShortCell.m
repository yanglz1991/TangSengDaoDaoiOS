//
//  QCContactsAddMyShortCell.m
//  WuKongBase
//
//  Created by tt on 2020/6/22.
//

#import "QCContactsAddMyShortCell.h"

@implementation QCContactsAddMyShortModel

-(Class) cell {
    return QCContactsAddMyShortCell.class;
}

@end

@interface QCContactsAddMyShortCell ()

@property(nonatomic,strong) UILabel *valueLbl;
@property(nonatomic,strong) UIButton *iconBtn;
@property(nonatomic,strong) QCContactsAddMyShortModel *model;

@end

@implementation QCContactsAddMyShortCell

+(CGSize) sizeForModel:(QCContactsAddMyShortModel*)model{
    return  CGSizeMake(QCScreenWidth, 30.0f);
}

- (void)setupUI {
    [super setupUI];
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.valueLbl];
    [self.contentView addSubview:self.iconBtn];
}

- (void)refresh:(QCContactsAddMyShortModel*)cellModel {
    [super refresh:cellModel];
    self.model = cellModel;
    self.valueLbl.text = [NSString stringWithFormat:LLang(@"我的%@号：%@"),[QCApp shared].config.appName,cellModel.value?:@""];
    [self.valueLbl sizeToFit];
}

- (UIButton *)iconBtn {
    if(!_iconBtn) {
        _iconBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
        [_iconBtn setImage:[self imageName:@"Contacts/Others/Qrcode"] forState:UIControlStateNormal];
        [_iconBtn addTarget:self action:@selector(qrcodePressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iconBtn;
}

-(void) qrcodePressed {
    if(self.model.onQRCode) {
        self.model.onQRCode();
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.valueLbl.lim_width + self.iconBtn.lim_width;
    
    self.valueLbl.lim_left = self.lim_width/2.0f -  width/2.0f;
    self.valueLbl.lim_top = self.lim_height/2.0f - self.valueLbl.lim_height/2.0f;
    
    self.iconBtn.lim_left = self.valueLbl.lim_right + 8.0f;
    self.iconBtn.lim_top = self.lim_height/2.0f - self.iconBtn.lim_height/2.0f;
    
}

- (UILabel *)valueLbl {
    if(!_valueLbl) {
        _valueLbl = [[UILabel alloc]  init];
        [_valueLbl setTextColor:[QCApp shared].config.defaultTextColor];
        [_valueLbl setFont:[[QCApp shared].config appFontOfSize:13.0f]];
    }
    return _valueLbl;
}

-(UIImage*) imageName:(NSString*)name {
    return [[QCApp shared] loadImage:name moduleID:@"WuKongContacts"];
}


@end
