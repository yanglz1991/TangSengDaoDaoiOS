//
//  QCUserAvatarUtil.m
//  WuKongBase
//
//  Created by tt on 2020/2/29.
//

#import "QCAvatarUtil.h"
#import "QCApp.h"

@implementation QCAvatarUtil

+(NSString*) getAvatar:(NSString*)uid {
    return [[NSURL URLWithString:[NSString stringWithFormat:@"users/%@/avatar",uid] relativeToURL:[NSURL URLWithString:[QCApp shared].config.apiBaseUrl]] absoluteString];
}

+(NSString*) getFullAvatarWIthPath:(NSString*)avatarPath {
    if(!avatarPath) {
        return nil;
    }
    if([avatarPath hasPrefix:@"http"]) {
        return avatarPath;
    }
    if([avatarPath hasPrefix:@"/"]) {
        return [NSString stringWithFormat:@"%@%@",[QCApp shared].config.apiBaseUrl,[avatarPath stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""]];
    }
    return  [NSString stringWithFormat:@"%@%@",[QCApp shared].config.apiBaseUrl,avatarPath];
}

+(NSString*) getGroupAvatar:(NSString*)groupNo {
     return [[NSURL URLWithString:[NSString stringWithFormat:@"groups/%@/avatar",groupNo] relativeToURL:[NSURL URLWithString:[QCApp shared].config.apiBaseUrl]] absoluteString];
}

@end
