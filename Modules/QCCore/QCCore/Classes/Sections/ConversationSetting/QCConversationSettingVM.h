//
//  QCConversationSettingVM.h
//  QCCore
//
//  Created by tt on 2020/1/21.
//

#import <Foundation/Foundation.h>
#import <QCIM/QCIM.h>
#import "QCFormItemModel.h"
#import "QCFormSection.h"
#import "QCCore.h"
#import "QCGroupBaseInfo.h"
#import "QCUserOnlineResp.h"
NS_ASSUME_NONNULL_BEGIN
@class QCConversationSettingVM;

@protocol QCConversationSettingDelegate <NSObject>

@optional


/**
 群名点击

 @param vm <#vm description#>
 */
-(void) settingOnGroupNameClick:(QCConversationSettingVM*)vm;

/**
 群公告点击
 
 @param vm <#vm description#>
 */
-(void) settingOnGroupNoticeClick:(QCConversationSettingVM*)vm;


/**
 清空当前会话的消息

 @param vm <#vm description#>
 */
-(void) settingOnClearMessages:(QCConversationSettingVM*)vm;


/// 退出群聊
/// @param vm <#vm description#>
-(void) settingOnGroupExit:(QCConversationSettingVM*)vm;


/**
 频道数据更新

 @param vm <#vm description#>
 */
-(void) settingOnChannelUpdate:(QCConversationSettingVM*)vm;

// 顶部成员数据更新
-(void) settingOnTopNMembersUpdate:(QCConversationSettingVM*)vm;

/**

在群里的昵称
 @param vm <#vm description#>
 */
-(void) settingOnNickNameInGroup:(QCConversationSettingVM*)vm;


/// 举报
/// @param vm <#vm description#>
-(void) settingOnReport:(QCConversationSettingVM*)vm;



/**
 黑明单设置
 */
-(void) settingOnBlacklist:(QCConversationSettingVM*)vm action:(bool) addOrRemove;

@end

@interface QCConversationSettingVM : QCBaseTableVM

@property(nonatomic,strong) QCChannel *channel;

@property(nonatomic,weak) id<QCConversationContext> context;

@property(nonatomic,weak) id<QCConversationSettingDelegate> delegate;

@property(nonatomic,assign,readonly) NSInteger memberCount; // 群成员数量
@property(nonatomic,assign,readonly) QCMemberRole memberRole; // 我在此群的角色
@property(nonatomic,assign,readonly) QCGroupType groupType;

@property(nonatomic,strong) NSArray<QCUserOnlineResp*> *onlineMembers; // 在线成员


/**
 我在群里的信息
 */
@property(nullable,nonatomic,strong) QCChannelMember *memberOfMe;




/**
 频道数据
 */
@property(nonatomic,strong,readonly) QCChannelInfo *channelInfo;

/**
 同步成员
 */
-(void) syncMembersIfNeed;


/**
 我是否是群管理员

 @return <#return value description#>
 */
-(BOOL) isManagerForMe;


/**
 我是否是群创建者

 @return <#return value description#>
 */
-(BOOL) isCreatorForMe;


/**
 我是否是群创建者或管理员

 @return <#return value description#>
 */
-(BOOL) isManagerOrCreatorForMe;


/// 请求群成员邀请
-(AnyPromise*) requestGroupMemberInvite:(NSArray<NSString*>*)uids remark:(NSString*)remark;

/**
 添加黑名单
 */
-(AnyPromise*) addBlacklist;

/**
 移除黑名单
 */
-(AnyPromise*) deleteBlacklist;

// 在线成员
-(AnyPromise*) onlineMembers:(NSArray<NSString*>*)members;

// 获取成员的在线状态
-(QCUserOnlineResp*) memberOnline:(NSString*)uid;

@end




NS_ASSUME_NONNULL_END
