//
//  QCChannelInfo.m
//  WuKongIMSDK
//
//  Created by tt on 2019/12/23.
//

#import "QCChannelInfo.h"


@interface QCChannelInfo ()


@end

@implementation QCChannelInfo


- (NSMutableDictionary *)extra {
    if(!_extra) {
        _extra = [[NSMutableDictionary alloc] init];
    }
    return _extra;
}

- (NSString *)displayName {
    if(!self.remark || [self.remark isEqualToString:@""]) {
        return self.name;
    }
    return self.remark;
}

-(id) extraValueForKey:(QCChannelExtraKey)key {
    return [self extraValueForKey:key defaultValue:nil];
}

-(id) extraValueForKey:(QCChannelExtraKey)key defaultValue:(id)value {
    id v=  self.extra[key];
    if(v) {
        return v;
    }
    return value;
}

- (void)setExtraValue:(id)value forKey:(QCChannelExtraKey)key {
    self.extra[key] = value;
}

- (BOOL)settingForKey:(QCChannelExtraKey)key defaultValue:(BOOL)on {
    id value = [self extraValueForKey:key defaultValue:@(on)];
    if(value) {
        return [value boolValue];
    }
    return on;
}

- (void)setSettingValue:(BOOL)on forKey:(QCChannelExtraKey)key {
    [self setExtraValue:@(on) forKey:key];
}


- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    QCChannelInfo *channelInfo = [QCChannelInfo allocWithZone:zone];
    channelInfo.channel = [QCChannel channelID:self.channel.channelId channelType:self.channel.channelType];
    channelInfo.follow = self.follow;
    channelInfo.name = self.name;
    channelInfo.remark = self.remark;
    channelInfo.notice = self.notice;
    channelInfo.logo = self.logo;
    channelInfo.stick = self.stick;
    channelInfo.mute = self.mute;
    channelInfo.showNick = self.showNick;
    channelInfo.save = self.save;
    channelInfo.forbidden = self.forbidden;
    channelInfo.invite = self.invite;
    channelInfo.version = self.version;
    channelInfo.status = self.status;
    channelInfo.online = self.online;
    channelInfo.receipt = self.receipt;
    channelInfo.category = self.category;
    channelInfo.lastOffline = self.lastOffline;
    channelInfo.robot = self.robot;
    channelInfo.extra = [self.extra mutableCopy];
    return channelInfo;
}

@end
