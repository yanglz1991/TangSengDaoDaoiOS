//
//  QCScreenProtectionView.m
//  QCCore
//
//  Created by tt on 2021/8/18.
//

#import "QCScreenProtectionView.h"
#import <QCCore/QCCore.h>
@interface QCScreenProtectionView ()

@property(nonatomic,strong) UIImageView *logoImgView;
@property(nonatomic,strong) UILabel *securityTipLbl;

@end

@implementation QCScreenProtectionView


- (instancetype)init
{
    UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self = [super initWithEffect:blur];
    if (self) {
        self.frame =  [UIScreen mainScreen].bounds;
        [self.contentView addSubview:self.logoImgView];
        [self.contentView addSubview:self.securityTipLbl];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.logoImgView.lim_centerX_parent = self.contentView;
    self.logoImgView.lim_top = [QCApp shared].config.visibleEdgeInsets.top + 40.0f;
    
    self.securityTipLbl.lim_top = QCScreenHeight - [QCApp shared].config.visibleEdgeInsets.bottom - 40.0f;
    self.securityTipLbl.lim_centerX_parent = self.contentView;
    
}

- (UIImageView *)logoImgView {
    if(!_logoImgView) {
        _logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
        NSString *appIcon = [self getAppIconName];
        if(appIcon) {
            _logoImgView.image = [UIImage imageNamed:appIcon];
        }
        _logoImgView.layer.masksToBounds = YES;
        _logoImgView.layer.cornerRadius = _logoImgView.lim_height/2.0f;
    }
    return _logoImgView;
}

-(NSString*) getAppIconName {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
       
    //获取app中所有icon名字数组
    NSArray *iconsArr = infoDict[@"CFBundleIcons"][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"];
       //取最后一个icon的名字
    NSString *iconLastName = [iconsArr lastObject];
    return iconLastName;
}

- (UILabel *)securityTipLbl {
    if(!_securityTipLbl) {
        _securityTipLbl = [[UILabel alloc] init];
        _securityTipLbl.text = [NSString stringWithFormat:LLang(@"%@全力保护您的信息安全"),[QCApp shared].config.appName];
        _securityTipLbl.textColor = [QCApp shared].config.themeColor;
        _securityTipLbl.font = [[QCApp shared].config appFontOfSize:14.0f];
        [_securityTipLbl sizeToFit];
    }
    return _securityTipLbl;
}

@end
