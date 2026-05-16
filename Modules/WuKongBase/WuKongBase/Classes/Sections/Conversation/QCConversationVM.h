//
//  QCConversationVM.h
//  WuKongBase
//
//  Created by tt on 2022/5/19.
//

#import <Foundation/Foundation.h>
#import <WuKongIMSDK/WuKongIMSDK.h>
#import <PromiseKit/PromiseKit.h>
#import "QCGroupBaseInfo.h"
#import "QCModel.h"
#import "QCConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCConversationVM : NSObject

@property(nonatomic,strong) QCChannel *channel;
@property(nonatomic,strong) QCChannelInfo *channelInfo;


@property(nonatomic,assign,readonly) QCGroupType groupType;

// -------------------- 群成员相关 --------------------
@property(nonatomic,strong) NSArray<QCChannelMember*> *members;
@property(nullable,nonatomic,strong) QCChannelMember *memberOfMe; // 我在群里的信息

@property(nonatomic,assign,readonly) NSInteger memberCount;
@property(nonatomic,assign,readonly) QCMemberRole memberRole;
@property(nonatomic,assign) NSInteger forbiddenExpirTime; // 禁言过期时间 0表示未禁言

@property(nonatomic,copy) void(^onMemberUpdate)(void); // 群成员有更新

/**
 获取所有成员

 @return <#return value description#>
 */
-(NSArray<QCChannelMember*>*) getAllMembers;

/**
 同步成员
 */
-(void) syncMembersIfNeed;

-(void) requestMembers;



/// 正在输入中
-(void) typing;


@end



NS_ASSUME_NONNULL_END
