//
//  QCScreenPasswordVC.m
//  QCCore
//
//  Created by tt on 2021/8/16.
//

#import "QCScreenPasswordSetVC.h"
#import "QCScreenPasswordSetVM.h"
#import "QCScreenPasswordSettingVC.h"
@interface QCScreenPasswordSetVC ()

@property(nonatomic,strong) QCCorePasswordView *corePasswordView;
@property(nonatomic,strong) UILabel *titleLbl;
@property(nonatomic,assign) BOOL again; // 是否再次输入密码
@property(nonatomic,copy) NSString *firstPwd; // 第一次输入的密码

@end

@implementation QCScreenPasswordSetVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCScreenPasswordSetVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLang(@"设置解锁密码");
    [self.view addSubview:self.corePasswordView];
    [self.view addSubview:self.titleLbl];
    [self.corePasswordView beginInput];
}


- (QCCorePasswordView *)corePasswordView {
    if(!_corePasswordView) {
        CGFloat leftSpace = 20.0f;
        __weak typeof(self) weakSelf = self;
        _corePasswordView = [[QCCorePasswordView alloc] initWithFrame:CGRectMake(leftSpace, self.navigationBar.lim_bottom+60.0f, QCScreenWidth - leftSpace*2, 40.0f)];
        _corePasswordView.PasswordCompeleteBlock = ^(NSString *password) {
            if(weakSelf.again) {
                if(![password isEqualToString:weakSelf.firstPwd]) {
                    [weakSelf.view showMsg:LLangW(@"两次密码输入不一致",weakSelf)];
                    return;
                }
                [weakSelf.view showHUD];
                [weakSelf.viewModel requestLockscreenpwd:password].then(^{
                    [weakSelf.view hideHud];
                    QCScreenPasswordSettingVC *settingVC = [QCScreenPasswordSettingVC new];
                    [[QCNavigationManager shared] replacePushViewController:settingVC animated:YES];
                }).catch(^(NSError *error){
                    [weakSelf.view hideHud];
                    [weakSelf.view showHUDWithHide:LLangW(error.domain, weakSelf)];
                });
               
                return;
            }
            
            QCScreenPasswordSetVC *vc = [QCScreenPasswordSetVC new];
            vc.again = true;
            vc.firstPwd = password;
            [[QCNavigationManager shared] replacePushViewController:vc animated:YES];
        };
    }
    return _corePasswordView;
}


- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.text = LLang(@"请输入密码");
        _titleLbl.textColor = [UIColor grayColor];
        _titleLbl.font = [[QCApp shared].config appFontOfSize:14.0f];
        [_titleLbl sizeToFit];
        
        _titleLbl.lim_centerX_parent = self.view;
        _titleLbl.lim_top = self.corePasswordView.lim_top - _titleLbl.lim_height - 40.0f;
    }
    return _titleLbl;
}

@end
