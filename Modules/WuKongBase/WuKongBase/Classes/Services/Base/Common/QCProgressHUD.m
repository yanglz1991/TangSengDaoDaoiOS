//
//  QCProgressHUD.m
//  WuKongBase
//
//  Created by tt on 2020/1/12.
//

#import "QCProgressHUD.h"
#import <MBProgressHUD/MBProgressHUD.h>
 static MBProgressHUD *hud = nil;
@implementation QCProgressHUD

+ (instancetype)sharedView
{
    static QCProgressHUD *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QCProgressHUD alloc] init];
    });
    return instance;
}

+(void) show{
    [[QCProgressHUD sharedView] showInView:[UIApplication sharedApplication].keyWindow];
}

+(void) dismiss{
    if(hud) {
        [hud hideAnimated:YES];
    }
}


-(void) showInView:(UIView*)view{
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
}
@end
