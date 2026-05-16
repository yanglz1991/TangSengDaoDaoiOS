//
//  QCScreenPasswordVM.m
//  WuKongBase
//
//  Created by tt on 2021/8/16.
//

#import "QCScreenPasswordSetVM.h"
#import "QCMD5Util.h"
@implementation QCScreenPasswordSetVM


-(AnyPromise*) requestLockscreenpwd:(NSString*)password {
   
    NSString *pwd = [[self class] digestLockScreenPwd:password];
    [QCApp shared].loginInfo.extra[@"lock_screen_pwd"] = pwd;
    [[QCApp shared].loginInfo save];
   return [[QCAPIClient sharedClient] POST:@"user/lockscreenpwd" parameters:@{
        @"lock_screen_pwd":pwd,
    }];
}

+(NSString*) digestLockScreenPwd:(NSString*)pwd {
    return [QCMD5Util md5HexDigest:[NSString stringWithFormat:@"%@%@",pwd,[QCApp shared].loginInfo.uid]];
}

@end
