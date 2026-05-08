//
//  WKSecureChannelMenu.m
//  WuKongBase
//

#import "WKSecureChannelMenu.h"
#import "WKSecureChannelManager.h"
#import "WuKongBase.h"
#import "WKLabelItemCell.h"
#import "WKFormSection.h"
#import "UIView+WK.h"
#import "UIView+WKCommon.h"

@implementation WKSecureChannelMenu

+ (void)registerSecureChannelMenu {
    [[WKApp shared] setMethod:@"commonsetting.secure_channel" handler:^id _Nullable(id _Nonnull param) {
        WKSecureChannelManager *mgr = [WKSecureChannelManager shared];
        if (!mgr.enabled || mgr.displayName.length == 0) {
            return nil;
        }
        return @{
            @"height": WKSectionHeight,
            @"items": @[
                @{
                    @"class": WKLabelItemModel.class,
                    @"label": mgr.displayName,
                    @"onClick": ^{
                        [WKSecureChannelMenu handleClick];
                    }
                }
            ]
        };
    } category:WKPOINT_CATEGORY_COMMONSETTING sort:75000];
}

+ (void)handleClick {
    WKSecureChannelManager *mgr = [WKSecureChannelManager shared];
    NSString *saved = [mgr savedPassword];
    if (saved.length > 0) {
        // 免密自动验证;失败则清除并弹密码框
        [mgr verifyWithPassword:saved complete:^(NSString * _Nullable url, NSError * _Nullable error) {
            if (url.length > 0) {
                [WKSecureChannelMenu openWebView:url];
            } else {
                [mgr clearSavedPassword];
                [WKSecureChannelMenu showPasswordAlert];
            }
        }];
    } else {
        [WKSecureChannelMenu showPasswordAlert];
    }
}

+ (UIViewController *)topViewController {
    UIViewController *top = [WKNavigationManager shared].topViewController;
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
            [WKSecureChannelMenu showToast:LLang(@"请输入密码")];
            return;
        }
        [[WKSecureChannelManager shared] verifyWithPassword:pwd complete:^(NSString * _Nullable url, NSError * _Nullable error) {
            if (url.length > 0) {
                [[WKSecureChannelManager shared] setSavedPassword:pwd];
                [WKSecureChannelMenu openWebView:url];
            } else {
                NSString *msg = error.localizedDescription;
                if (msg.length == 0) msg = LLang(@"密码错误");
                [WKSecureChannelMenu showToast:msg];
            }
        }];
    }]];
    [[WKSecureChannelMenu topViewController] presentViewController:alert animated:YES completion:nil];
}

+ (void)openWebView:(NSString *)url {
    if (url.length == 0) return;
    WKWebViewVC *vc = [[WKWebViewVC alloc] init];
    vc.url = [NSURL URLWithString:url];
    [[WKNavigationManager shared] pushViewController:vc animated:YES];
}

+ (void)showToast:(NSString *)msg {
    UIView *view = [WKSecureChannelMenu topViewController].view;
    if (view && msg.length > 0) {
        [view showHUDWithHide:msg];
    }
}

@end
