//
//  QCLoginVC.m
//  QCAuth
//
//  Created by tt on 2019/12/1.
//

#import "QCLoginVC.h"
#import "QCLoginView.h"
#import "QCRegisterNextVC.h"
#import "QCLoginPhoneCheckStartVC.h"
@interface QCLoginVC ()
 
@property(nonatomic,strong) QCLoginView  *loginView;

@end

@implementation QCLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.hidden= YES;
    [self fillZoneAndPhone];
}

- (NSString *)langTitle {
    return LLang(@"登录");
}

- (QCBaseVM *)viewModel {
    return [QCLoginVM new];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
}

-(void) loadView {
    //[super loadView];

    self.loginView = [[QCLoginView alloc] initWithFrame:CGRectMake(0, 0, QCScreenWidth, QCScreenHeight)];
   
     __weak typeof(self) weakSelf = self;
    
    self.loginView.onLogin = ^(NSString * _Nonnull mobile, NSString * _Nonnull password,NSString *country) {
        [weakSelf.view showHUD:LLangW(@"登录中",weakSelf)];
        
        [weakSelf.viewModel login:[NSString stringWithFormat:@"%@%@",country,mobile] password:password].then(^(QCLoginResp *resp){
             [weakSelf.view hideHud];
            if(!resp.name || [resp.name isEqualToString:@""]) { // 如果没名字就跳到完善注册资料页面
                [QCLoginVM handleLoginData:resp isSave:NO];
                QCRegisterNextVC *vc = [QCRegisterNextVC new];
                [[QCNavigationManager shared] pushViewController:vc animated:YES];
            }else {
                [QCLoginVM handleLoginData:resp isSave:YES];
                [[QCApp shared] invoke:QCPOINT_LOGIN_SUCCESS param:nil];
                
               
            }
            
        }).catch(^(NSError *error){
            NSDictionary *userInfo = error.userInfo;
            if(userInfo &&  userInfo[@"status"]) {
               NSInteger status =  [userInfo[@"status"] integerValue];
                if(status == 110) {
                    [weakSelf.view hideHud];
                    
                    QCLoginPhoneCheckStartVC *vc = [QCLoginPhoneCheckStartVC new];
                    vc.phone = userInfo[@"phone"]?:@"";
                    vc.uid = userInfo[@"uid"]?:@"";
                    [[QCNavigationManager shared] pushViewController:vc animated:YES];
                    return;
                }
            }
            [weakSelf.view switchHUDError:error.domain];
        });
    };
    self.view = self.loginView;
}

-(void) fillZoneAndPhone {
    NSString *currentMobile = [QCApp shared].loginInfo.extra[@"phone"];
       NSString *currentCountry = [QCApp shared].loginInfo.extra[@"zone"];
       if(currentMobile && ![currentMobile isEqualToString:@""]) {
           self.loginView.mobile = currentMobile;
       }
       if(currentCountry && ![currentCountry isEqualToString:@""]) {
           self.loginView.country = [currentCountry stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
       }
}

- (void)viewConfigChange:(QCViewConfigChangeType)type {
    [self.loginView viewConfigChange:type];
}

@end
