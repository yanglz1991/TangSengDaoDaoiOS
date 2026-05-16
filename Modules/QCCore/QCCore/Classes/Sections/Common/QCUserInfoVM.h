//
//  QCUserInfoVM.h
//  QCCore
//
//  Created by tt on 2020/6/19.
//

#import "QCBaseTableVM.h"
#import "QCFormSection.h"
@class QCUserInfoVM;
typedef void(^channelInfoCompletion)(void);

NS_ASSUME_NONNULL_BEGIN

@protocol QCUserInfoVMDelegate <NSObject>

@optional


/// 更新备注
/// @param vm <#vm description#>
-(void) userInfoVMUpdateRemark:(QCUserInfoVM*)vm;


/// 解除好友关系
/// @param vm <#vm description#>
-(void) userInfoVMFreeFriend:(QCUserInfoVM*)vm;


/// 添加黑名单
/// @param vm <#vm description#>
-(void) userInfoVMAddBlacklist:(QCUserInfoVM*)vm;

/// 移除黑名单
/// @param vm <#vm description#>
-(void) userInfoVMRemoveBlacklist:(QCUserInfoVM*)vm;

/// 举报
/// @param vm <#vm description#>
-(void) userInfoVMReport:(QCUserInfoVM*)vm;

@end

@interface QCUserInfoVM : QCBaseTableVM


@property(nonatomic,copy) NSString *uid;
@property(nonatomic,strong) QCChannelInfo *channelInfo;

@property(nonatomic,strong,nullable) QCChannel *fromChannel; // 从那个频道进入的用户信息页面
@property(nonatomic,strong) QCChannelInfo *fromChannelInfo; // 从那个频道过来的
@property(nonatomic,strong) QCChannelMember *memberOfUser; // 用户在频道内的成员对象（ 如果是从某个频道过来的，则有可能有此值）
@property(nonatomic,strong) QCChannelMember *memberOfMy; // 我在频道内的成员对象（ 如果是从某个频道过来的，则有可能有此值）

@property(nonatomic,assign,readonly) BOOL isBlacklist; // 是黑名单那用户

@property(nonatomic,weak) id<QCUserInfoVMDelegate> delegate;

///加载个人频道信息（如果没有则去服务器请求）
/// @param uid <#uid description#>
-(void) loadPersonChannelInfo:(NSString*)uid completion:(channelInfoCompletion)completion;

/**
 申请好友

 @param uid 好友uid
 @param remark 申请备注
 @return <#return value description#>
 */
-(AnyPromise*) applyFriend:(NSString*)uid remark:(NSString*)remark vercode:(NSString*)vercode;


/// 修改备注
/// @param remark 备注
-(AnyPromise*) updateRemark:(NSString*)remark;


/// 删除好友
-(AnyPromise*) deleteFriend;

// 添加黑名单
-(AnyPromise*) addBlacklist;

/// 删除黑名单
-(AnyPromise*) deleteBlacklist;

-(void) initData;

@end

NS_ASSUME_NONNULL_END
