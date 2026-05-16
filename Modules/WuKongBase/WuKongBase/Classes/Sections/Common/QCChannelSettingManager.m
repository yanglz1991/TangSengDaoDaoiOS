//
//  QCChannelSettingManager.m
//  WuKongBase
//
//  Created by tt on 2021/8/10.
//

#import "QCChannelSettingManager.h"
#import "WuKongBase.h"
@implementation QCChannelSettingManager


+ (instancetype)shared{
    static QCChannelSettingManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[QCChannelSettingManager alloc] init];
    });
    
    return _shared;
}

// 更新群设置
-(void) updateGroupSetting:(QCGroupSettingKey)key on:(BOOL)on groupNo:(NSString*)groupNo{
    [[QCGroupManager shared] groupSetting:groupNo settingKey:key on:on];
}
// 更新用户设置-免打扰
-(void) channel:(QCChannel*)channel mute:(BOOL) on {
    if(channel.channelType == WK_PERSON) {
        [self updateUserSetting:channel.channelId settingDict:@{@"mute":@(on?1:0)}];
    }else {
        [self updateGroupSetting:QCGroupSettingKeyMute on:on groupNo:channel.channelId];
    }
    
}
// 设置-置顶
-(void) channel:(QCChannel*)channel stick:(BOOL) on {
    if(channel.channelType == WK_PERSON) {
        [self updateUserSetting:channel.channelId settingDict:@{@"top":@(on?1:0)}];
    }else {
        [self updateGroupSetting:QCGroupSettingKeyStick on:on groupNo:channel.channelId];
    }
    
}
// 设置-消息回执
-(void) channel:(QCChannel*)channel receipt:(BOOL) on {
    if(channel.channelType == WK_PERSON) {
        [self updateUserSetting:channel.channelId settingDict:@{@"receipt":@(on?1:0)}];
    }else {
        [self updateGroupSetting:QCGroupSettingKeyReceipt on:on groupNo:channel.channelId];
    }
}
// 阅后即焚
-(void) channel:(QCChannel*)channel flame:(BOOL) on {
    if(channel.channelType == WK_PERSON) {
        [self updateUserSetting:channel.channelId settingDict:@{@"flame":@(on?1:0)}];
    }else {
        [self updateGroupSetting:QCGroupSettingKeyFlame on:on groupNo:channel.channelId];
    }
}
-(void) channel:(QCChannel*)channel flameSecond:(NSInteger) flameSecond {
    if(channel.channelType == WK_PERSON) {
        [self updateUserSetting:channel.channelId settingDict:@{@"flame_second":@(flameSecond)}];
    }else {
        [[QCGroupManager shared] groupSetting:channel.channelId key:@"flame_second" value:@(flameSecond)];
    }
}
// 设置-聊天密码开启
-(void) channel:(QCChannel*)channel chatPwdOn:(BOOL)on {
    if(channel.channelType == WK_PERSON) {
        [self updateUserSetting:channel.channelId settingDict:@{@"chat_pwd_on":@(on?1:0)}];
    }else {
        [self updateGroupSetting:QCGroupSettingKeyChatPwdOn on:on groupNo:channel.channelId];
    }
}
// 更新设置-截屏通知
-(void) channel:(QCChannel*)channel screenshot:(BOOL) on {
    if(channel.channelType == WK_PERSON) {
        [self updateUserSetting:channel.channelId settingDict:@{@"screenshot":@(on?1:0)}];
    }else {
        [self updateGroupSetting:QCGroupSettingKeyScreenshot on:on groupNo:channel.channelId];
    }
}

-(void) group:(NSString*)groupNo save:(BOOL) on {
    [self updateGroupSetting:QCGroupSettingKeySave on:on groupNo:groupNo];
}

// 更新用户设置
-(AnyPromise*) updateUserSetting:(NSString*)uid settingDict:(NSDictionary*)settingDict{
//    __weak typeof(self) weakSelf = self;
   return [[QCAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%@/setting",uid] parameters:settingDict].then(^{
        // TODO 更新用户设置服务器会发出 channelUpdate命令 所以这里无需再进行更新操作
//        QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:[QCChannel personWithChannelID:uid]];
//        if(channelInfo) {
//            for (NSString *key in settingDict.allKeys) {
//                NSNumber *value = settingDict[key];
//                if([key isEqualToString:@"mute"]) {
//                    channelInfo.mute = [value boolValue];
//                }else if([key isEqualToString:@"top"]) {
//                    channelInfo.stick = [value boolValue];
//                }else if([key isEqualToString:@"receipt"]) {
//                    channelInfo.receipt = [value boolValue];
//                }else if([key isEqualToString:@"chat_pwd_on"]) {
//                    [channelInfo setSettingValue:[value boolValue] forKey:QCChannelExtraKeyChatPwd];
//                }
//            }
//            [[QCSDK shared].channelManager addOrUpdateChannelInfo:channelInfo];
//        }
    }).catch(^(NSError *error){
        [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
    });
}

-(BOOL) mute:(QCChannel*)channel hasChannelInfo:(BOOL*)hasChannelInfo {
    QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:channel];
    if(channelInfo) {
        if(hasChannelInfo) {
            *hasChannelInfo = true;
        }
        return channelInfo.mute;
    }
    if(hasChannelInfo) {
        *hasChannelInfo = false;
    }
    return false;
}

-(BOOL) mute:(QCChannel*)channel {
   
    return [self mute:channel hasChannelInfo:nil];
}

-(BOOL) stick:(QCChannel*) channel {
    QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:channel];
    if(channelInfo) {
        return channelInfo.stick;
    }
    return false;
}

-(BOOL) receipt:(QCChannel*)channel {
    QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:channel];
    if(channelInfo) {
        return channelInfo.receipt;
    }
    return false;
}

-(BOOL)chatPwdOn:(QCChannel*)channel {
    QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:channel];
    if(channelInfo) {
        return [channelInfo settingForKey:QCChannelExtraKeyChatPwd defaultValue:false];
    }
    return false;
}

-(BOOL)screenshot:(QCChannel*)channel {
    QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:channel];
    if(channelInfo) {
        return [channelInfo settingForKey:QCChannelExtraKeyScreenshot defaultValue:false];
    }
    return false;
}

-(BOOL) save:(QCChannel*)channel {
    QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:channel];
    if(channelInfo) {
        return channelInfo.save;
    }
    return false;
}

-(void) channel:(QCChannel*)channel revokeRemind:(BOOL)on {
    if(channel.channelType == WK_PERSON) {
        [self updateUserSetting:channel.channelId settingDict:@{QCChannelExtraKeyRevokeRemind:@(on?1:0)}];
    }else {
        [self updateGroupSetting:QCGroupSettingKeyRevokeRemind on:on groupNo:channel.channelId];
    }
}

-(BOOL)revokeRemind:(QCChannel*)channel {
    QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:channel];
    if(channelInfo) {
        return [channelInfo settingForKey:QCChannelExtraKeyRevokeRemind defaultValue:false];
    }
    return false;
}

-(void) channel:(QCChannel*)channel joinGroupRemind:(BOOL)on {
    if(channel.channelType == WK_PERSON) {
        [self updateUserSetting:channel.channelId settingDict:@{QCChannelExtraKeyJoinGroupRemind:@(on?1:0)}];
    }else {
        [self updateGroupSetting:QCGroupSettingKeyJoinGroupRemind on:on groupNo:channel.channelId];
    }
}

-(BOOL) joinGroupRemind:(QCChannel*)channel {
    QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:channel];
    if(channelInfo) {
        return [channelInfo settingForKey:QCChannelExtraKeyJoinGroupRemind defaultValue:false];
    }
    return false;
}

-(AnyPromise*) channel:(QCChannel*)channel remark:(NSString*)remark {
    if(channel.channelType == WK_PERSON) {
       return [self updateUserSetting:channel.channelId settingDict:@{QCChannelExtraKeyRemark:remark?:@""}];
    }else if(channel.channelType == WK_GROUP) {
       return [[QCGroupManager shared] groupRemark:channel.channelId remark:remark?:@""];
    }
    return nil;
}

-(NSString*) remark:(QCChannel*)channel {
    QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:channel];
    if(channelInfo) {
        return channelInfo.remark;
    }
    return nil;
}


@end
