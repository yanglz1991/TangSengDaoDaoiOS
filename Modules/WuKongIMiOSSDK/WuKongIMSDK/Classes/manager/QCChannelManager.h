//
//  QCChannelManager.h
//  WuKongIMSDK
//
//  Created by tt on 2019/12/23.
//

#import <Foundation/Foundation.h>
#import "QCChannel.h"
#import "QCChannelInfo.h"
#import "QCChannelMemberDB.h"
#import "QCTaskOperator.h"


NS_ASSUME_NONNULL_BEGIN


@protocol QCChannelManagerDelegate <NSObject>

@optional


/**
 频道信息更新

 @param channelInfo <#channelInfo description#>
 */
-(void) channelInfoUpdate:(QCChannelInfo*)channelInfo;

-(void) channelInfoUpdate:(QCChannelInfo*)channelInfo oldChannelInfo:(QCChannelInfo* __nullable)oldChannelInfo;


/// 频道数据移除
/// @param channel <#channel description#>
-(void) channelInfoDelete:(QCChannel*)channel oldChannelInfo:(QCChannelInfo * __nullable )oldChannelInfo;

@end


typedef void  (^QCChannelInfoBlock)(QCChannelInfo*);

@interface QCChannelManager : NSObject

+ (QCChannelManager *)shared;

/**
 获取频道信息

 @param channel 频道
 @param channelInfoBlock 获取到频道信息回调
 */
-(QCTaskOperator*) fetchChannelInfo:(QCChannel*) channel  completion:(_Nullable QCChannelInfoBlock)channelInfoBlock;

-(void) fetchChannelInfo:(QCChannel*) channel;

/**
  添加频道请求（此方法适合大量cell获取频道数据）
 */
-(void) addChannelRequest:(QCChannel*)channel complete:(void(^_Nullable)(NSError *error,bool notifyBefore))complete;

/**
  取消请求
 */
-(void) cancelRequest:(QCChannel*)channel;

/**
 获取频道信息

 @param channel 频道
 @return <#return value description#>
 */
-(QCChannelInfo*) getChannelInfo:(QCChannel*)channel;

/**
  获取用户频道信息
 */
-(QCChannelInfo*) getChannelInfoOfUser:(NSString*)uid;

/**
删除频道信息
 */
-(void) deleteChannelInfo:(QCChannel*) channel;


/**
 添加或更新频道，如果需要更新的话（只与version大于当前库里的version才更新）

 @param channelInfo <#channelInfo description#>
 */
-(void) addOrUpdateChannelInfoIfNeed:(QCChannelInfo*) channelInfo;


/**
 添加或更新（不比较版本）

 @param channelInfo <#channelInfo description#>
 */
-(void) addOrUpdateChannelInfo:(QCChannelInfo*) channelInfo;


/// 更新频道信息
/// @param channelInfo <#channelInfo description#>
-(void) updateChannelInfo:(QCChannelInfo*) channelInfo;


/// 添加频道信息
/// @param channelInfo <#channelInfo description#>
-(void) addChannelInfo:(QCChannelInfo*) channelInfo;
/**
 更新频道设置

 @param channel 频道
 @param setting 频道设置字典 比例设置免打扰 则传 @{@"mute":@(true)} 设置多个 @{@"mute":@(true),@"stick":@(true)}
 */
-(void) updateChannelSetting:(QCChannel*)channel setting:(NSDictionary*)setting;


/**
 批量添加或更新频道信息 (不通知上层)

 @param channelInfos <#channelInfos description#>
 */
-(void) addOrUpdateChannelInfos:(NSArray<QCChannelInfo*>*) channelInfos;


/**
  删除某个频道内的成员
 @param channel 频道
 */
-(void) deleteMembers:(QCChannel*)channel;

/**
 添加或更新频道成员

 @param members 频道成员集合
 */
-(void) addOrUpdateMembers:(NSArray<QCChannelMember*>*)members;


/**
 获取频道成员集合

 @param channel 频道对象
 @return <#return value description#>
 */
-(NSArray<QCChannelMember*>*) getMembersWithChannel:(QCChannel*)channel;

/**
  获取频道成员集合
 @param channel 频道对象
 @param limit 数量限制
 */
-(NSArray<QCChannelMember*>*) getMembersWithChannel:(QCChannel*)channel limit:(NSInteger)limit;

/**
 频道成员数量
 */
-(NSInteger) getMemberCount:(QCChannel*)channel;


/**
 获取频道指定成员

 @param channel 频道
 @param uid 成员UID
 */
-(QCChannelMember*) getMember:(QCChannel*)channel uid:(NSString*)uid;



/// 是否是管理员（群主或管理员）
/// @param channel <#channel description#>
/// @param uid <#uid description#>
-(BOOL) isManager:(QCChannel*)channel memberUID:(NSString*)uid;

/**
 获取频道的成员最新同步key
 
 @param channel 频道信息
 @return <#return value description#>
 */
-(NSString*) getMemberLastSyncKey:(QCChannel*)channel;


/// 设置频道在线
/// @param channel <#channel description#>
/// @param deviceFlag 设备标记
-(void) setChannelOnline:(QCChannel*)channel deviceFlag:(QCDeviceFlagEnum)deviceFlag;
-(void) setChannelOnline:(QCChannel*)channel;

/// 设置频道离线
/// @param channel <#channel description#>
-(void) setChannelOffline:(QCChannel*)channel;
- (void)setChannelOffline:(QCChannel *)channel deviceFlag:(QCDeviceFlagEnum)deviceFlag;


/// 只更新频道的在线状态
/// @param online <#online description#>
-(void) updateChannelOnlineStatus:(QCChannel*)channel online:(BOOL)online;



/// 设置频道离线
/// @param channel 频道
/// @param lastOffline 最后一次离线时间
/// @param deviceFlag 最后一次离线的设备
- (void)setChannelOffline:(QCChannel *)channel lastOffline:(NSTimeInterval)lastOffline deviceFlag:(QCDeviceFlagEnum)deviceFlag;
-(void) setChannelOffline:(QCChannel*)channel lastOffline:(NSTimeInterval)lastOffline;
/**
 设置频道缓存

 @param channelInfo <#channelInfo description#>
 */
-(void) setCache:(QCChannelInfo*) channelInfo;


/**
 获取缓存内的频道信息

 @return <#return value description#>
 */
-(QCChannelInfo*) getCache:(QCChannel*)channel;


/**
  从缓存中获取频道成员
 */
-(QCChannelMember*) getMemberFromCache:(QCChannel *)channel uid:(NSString *)uid;


// 删除频道的成员缓存
-(void) deleteMembersWithChannelFromCache:(QCChannel*)channel;

/**
 移除频道所有缓存
 */
-(void) removeChannelAllCache;
/**
 添加连接委托
 
 @param delegate <#delegate description#>
 */
-(void) addDelegate:(id<QCChannelManagerDelegate>) delegate;


/**
 移除连接委托
 
 @param delegate <#delegate description#>
 */
-(void)removeDelegate:(id<QCChannelManagerDelegate>) delegate;

@end

NS_ASSUME_NONNULL_END
