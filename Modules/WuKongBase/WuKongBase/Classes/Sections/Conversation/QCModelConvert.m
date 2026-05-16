//
//  QCModelConvert.m
//  WuKongBase
//
//  Created by tt on 2020/1/24.
//

#import "QCModelConvert.h"
#import "QCAvatarUtil.h"
@implementation QCModelConvert

+(QCContactsSelect*) toContactsSelect:(QCChannelMember*)channelMember {
    QCContactsSelect *contactsSelect = [QCContactsSelect new];
    contactsSelect.uid =channelMember.memberUid;
    if(channelMember.memberRemark && ![channelMember.memberRemark isEqualToString:@""]) {
        contactsSelect.name = channelMember.memberRemark;
    }else {
        contactsSelect.name =channelMember.memberName;
    }
    if(channelMember.memberAvatar && ![channelMember.memberAvatar isEqualToString:@""]) {
        contactsSelect.avatar = [QCAvatarUtil getFullAvatarWIthPath:channelMember.memberAvatar];
    }else {
        contactsSelect.avatar = [QCAvatarUtil getAvatar:channelMember.memberUid];
    }
    
    return contactsSelect;
}

@end
