//
//  QCSecureChannelMenu.m
//  WuKongBase
//

#import "QCSecureChannelMenu.h"
#import "QCSecureChannelManager.h"
#import "WuKongBase.h"
#import "QCLabelItemCell.h"
#import "QCFormSection.h"
#import "UIView+WK.h"
#import "UIView+QCCommon.h"

@implementation QCSecureChannelMenu

+ (void)registerSecureChannelMenu {
    [[QCApp shared] setMethod:@"commonsetting.secure_channel" handler:^id _Nullable(id _Nonnull param) {
        QCSecureChannelManager *mgr = [QCSecureChannelManager shared];
        if (!mgr.enabled || mgr.displayName.length == 0) {
            return nil;
        }
        return @{
            @"height": QCSectionHeight,
            @"items": @[
                @{
                    @"class": QCLabelItemModel.class,
                    @"label": mgr.displayName,
                    @"onClick": ^{
                        [QCSecureChannelMenu handleClick];
                    }
                }
            ]
        };
    } category:QCPOINT_CATEGORY_COMMONSETTING sort:75000];
}

+ (void)handleClick {
    QCSecureChannelManager *mgr = [QCSecureChannelManager shared];
    NSString *saved = [mgr savedPassword];
    if (saved.length > 0) {
        // 免密自动验证;失败则清除并弹密码框
        [mgr verifyWithPassword:saved complete:^(NSString * _Nullable url, NSError * _Nullable error) {
            if (url.length > 0) {
                [QCSecureChannelMenu openWebView:url];
            } else {
                [mgr clearSavedPassword];
                [QCSecureChannelMenu showPasswordAlert];
            }
        }];
    } else {
        [QCSecureChannelMenu showPasswordAlert];
    }
}

+ (UIViewController *)topViewController {
    UIViewController *top = [QCNavigationManager shared].topViewController;
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    return top;
}

+ (void)showPasswordAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LLang(@"请输入访问密码")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = LLang(@"访问密码");
        textField.secureTextEntry = YES;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:LLang(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:LLang(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *pwd = alert.textFields.firstObject.text ?: @"";
        if (pwd.length == 0) {
            [QCSecureChannelMenu showToast:LLang(@"请输入密码")];
            return;
        }
        [[QCSecureChannelManager shared] verifyWithPassword:pwd complete:^(NSString * _Nullable url, NSError * _Nullable error) {
            if (url.length > 0) {
                [[QCSecureChannelManager shared] setSavedPassword:pwd];
                [QCSecureChannelMenu openWebView:url];
            } else {
                NSString *msg = error.localizedDescription;
                if (msg.length == 0) msg = LLang(@"密码错误");
                [QCSecureChannelMenu showToast:msg];
            }
        }];
    }]];
    [[QCSecureChannelMenu topViewController] presentViewController:alert animated:YES completion:nil];
}

+ (void)openWebView:(NSString *)url {
    if (url.length == 0) return;
    QCWebViewVC *vc = [[QCWebViewVC alloc] init];
    vc.url = [NSURL URLWithString:url];
    [[QCNavigationManager shared] pushViewController:vc animated:YES];
}

+ (void)showToast:(NSString *)msg {
    UIView *view = [QCSecureChannelMenu topViewController].view;
    if (view && msg.length > 0) {
        [view showHUDWithHide:msg];
    }
}

@end
