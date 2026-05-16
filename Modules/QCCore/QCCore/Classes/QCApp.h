//
//  QCApp.h
//  QCCore
//
//  Created by tt on 2019/12/1.
// 此类为全局APP方法
//

#import <Foundation/Foundation.h>
#import "QCLoginInfo.h"
#import "QCEndpoint.h"
#import "QCMessageRegistry.h"
#import <SDWebImage/SDWebImage.h>
#import <QCIM/QCIM.h>
#import "QCConversationContext.h"
#import "QCAppConfig.h"
#import "QCEndpointManager.h"
#import "QCStickerPackage.h"
#import <PromiseKit/PromiseKit.h>
NS_ASSUME_NONNULL_BEGIN


@protocol QCAppDelegate <NSObject>

@optional


/// app已登出
-(void) appLogout;

// app登录成功
-(void) appLoginSuccess;

@end

@interface QCApp : NSObject
+ (QCApp *)shared;

@property(nonatomic,strong) QCEndpointManager *endpointManager;


/**
 添加委托
 
 @param delegate <#delegate description#>
 */
-(void) addDelegate:(id<QCAppDelegate>) delegate;


/**
 移除委托
 
 @param delegate <#delegate description#>
 */
-(void)removeDelegate:(id<QCAppDelegate>) delegate;

/**
 配置信息
 */
@property(nonatomic,strong) QCAppConfig *config;

// app远程配置
@property(nonatomic,strong) QCAppRemoteConfig *remoteConfig;

/**
 首页视图控制器（APP的首页）
 */
@property(nonatomic,strong) UIViewController*(^getHomeViewController)(void);

/**
 是否已登录

 @return <#return value description#>
 */
-(BOOL) isLogined;


/**
 当前用户信息
 */
@property(nonatomic,strong,readonly) QCLoginInfo *loginInfo;


/**
 消息登记管理
 */
@property(nonatomic,strong,readonly) QCMessageRegistry *messageRegitry;


/// 图片缓存
@property(nonatomic,strong) SDImageCache *imageCache;


/// 当前聊天的频道
@property(nonatomic,weak) QCChannel *currentChatChannel;


/// 当前打开的最近会话上下文
@property(nonatomic,weak) id<QCConversationContext> conversationContext;

@property(nonatomic,strong) NSArray<QCSticker*> *collectStickers; // 收藏的表情
@property(nonatomic,assign) BOOL collectStickerRequested; // 是否已经成功请求了收藏表情的数据

// app初始化
-(void) appInit;

-(BOOL) appOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

-(BOOL) appContinueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/**
 登出
 */
-(void) logout;

/**
 立即登出（不调用服务端注销接口，仅清理本地登录态并跳转登录页）
 用于 token 失效 / 强制下线 等需要立刻退出的场景。
 */
-(void) immediatelyLogout;

/**
 主动检查当前登录态是否被管理后台封禁（账号 / IP / 设备三个维度任意一个命中即弹窗并退出）。
 用于 APP 启动 / 从后台回到前台 / socket 重连成功时兜底，防止 forceLogout CMD 因客户端离线未送达。
 未登录或已弹过提示框时不会重复弹窗。
 */
-(void) checkBanStatusAndHandle;

/**
 是否正在显示封禁/强制下线弹窗（共享标志）。
 forceLogout CMD（QCSystemMessageHandler）/ onKick（QCSystemMessageHandler）/ checkBanStatusAndHandle（QCApp）
 三个入口共用，任一入口弹窗后置 YES，避免其他入口重复弹窗或显示错误提示词。
 immediatelyLogout 时自动复位为 NO。
 */
@property(nonatomic,assign) BOOL banDialogShowing;

/**
 注册端点
 @param endpoint 端点对象
 */
-(void) registerEndpoint:(QCEndpoint*)endpoint;

-(void) unregisterEndpointWithCategory:(NSString*)category;

-(QCEndpoint*) getEndpoint:(NSString*)sid;


/**
 调用endpoint

 @param endpointSID endpoint的 sid
 @param param 传入参数
 @return 返回
 */
-(id) invoke:(NSString*)endpointSID param:(__nullable id)param;
-(NSArray*) invokes:(NSString*)category param:(__nullable id)param;

/**
 设置方法

 @param sid poit唯一id
 @param handler 处理方法
 */
-(void) setMethod:(NSString*)sid handler:(QCHandler) handler;
-(void) setMethod:(NSString*)sid handler:(QCHandler) handler category:(NSString* __nullable)category;
-(void) setMethod:(NSString*)sid handler:(QCHandler) handler category:(NSString* __nullable)category sort:(int)sort;


/// 是否有指定的方法
/// @param sid <#sid description#>
-(BOOL) hasMethod:(NSString*)sid;


/**
 获取指定类别的端点

 @param category point类别
 @return <#return value description#>
 */
-(NSArray<QCEndpoint*>*) getEndpointsWithCategory:(NSString*)category;


/// 注册消息cell和content
/// @param cellClass 消息cell
/// @param messageContentClass 消息content
-(void) registerCellClass:(Class)cellClass forMessageContntClass:(Class)messageContentClass;


/// 注册消息
/// @param cellClass 消息cell
/// @param contentType 消息正文类型
-(void) registerCellClass:(Class)cellClass contentType:(NSInteger)contentType;


/// 获取消息的cell
/// @param contentType <#contentType description#>
-(Class) getMessageCell:(NSInteger)contentType;
/**
 加载图片

 @param name 图片名称
 @param moduleID 模块唯一ID
 @return <#return value description#>
 */
-(UIImage*) loadImage:(NSString*)name moduleID:(NSString*)moduleID;

/**  获取某个module的资源bundle*/
-(NSBundle*) resourceBundle:(NSString*)moduleID;

-(NSBundle*) resourceBundleWithClass:(Class)cls;


/// 获取完整的图片路径
/// @param path 路径
-(NSURL*) getImageFullUrl:(NSString*)path;


/// 获取文件的完整路径
/// @param path <#path description#>
-(NSURL*) getFileFullUrl:(NSString*)path;


/// 添加允许转发的消息（添加后在聊天页面长按将不会显示“转发”选项）
/// @param contentType <#contentType description#>
-(void) addMessageAllowForward:(NSInteger)contentType;


/// 添加允许复制的消息（添加后在聊天页面长按将不会显示"复制"选项）
/// @param contentType <#contentType description#>
-(void) addMessageAllowCopy:(NSInteger)contentType;

/// 添加允许收藏的消息（添加后在聊天页面长按将不会显示"收藏"选项）
/// @param contentType <#contentType description#>
-(void) addMessageAllowFavorite:(NSInteger)contentType;


/// 是否允许转发
/// @param contentType <#contentType description#>
-(BOOL) allowMessageForward:(NSInteger)contentType;


/// 是否允许复制
/// @param contentType <#contentType description#>
-(BOOL) allowMessageCopy:(NSInteger)contentType;


/// 是否允许收藏
/// @param contentType <#contentType description#>
-(BOOL) allowMessageFavorite:(NSInteger)contentType;

// 计算视频缓存目录大小
- (unsigned long long)calculateVideoCachedSizeWithError:(NSError **)error;

// 清空视频缓存
-(void) cleanVideoCache;


// 跳到聊天页面
-(void) pushConversation:(QCChannel*)channel;

- (UIWindow*) findWindow;


// 添加频道头像更新通知
-(void) addChannelAvatarUpdateNotify:(id)observer selector:(SEL)sel;

// 移除频道头像更新通知
-(void) removeChannelAvatarUpdateNotify:(id)observer;

// 通知频道头像更新
-(void) notifyChannelAvatarUpdate:(QCChannel*)channel;

// 加载当前用户收藏的表情
-(AnyPromise*) loadCollectStickers;

// 按需加载当前用户收藏的表情
-(AnyPromise*) loadCollectStickersIfNeed;

// 是否是系统账号(系统通知和文件助手)
-(BOOL) isSystemAccount:(NSString*)uid;

@end

NS_ASSUME_NONNULL_END


 
FOUNDATION_EXPORT QCChannelExtraKey const _Nullable  QCChannelExtraKeyShortNo; // 短编号
FOUNDATION_EXPORT QCChannelExtraKey const _Nullable  QCChannelExtraKeyScreenshot; // 截屏通知
FOUNDATION_EXPORT QCChannelExtraKey const _Nullable  QCChannelExtraKeyForbiddenAddFriend; // 禁止互加好友
FOUNDATION_EXPORT QCChannelExtraKey const _Nullable  QCChannelExtraKeyRevokeRemind; // 撤回通知
FOUNDATION_EXPORT QCChannelExtraKey const _Nullable  QCChannelExtraKeyJoinGroupRemind; // 进群通知
FOUNDATION_EXPORT QCChannelExtraKey const _Nullable  QCChannelExtraKeyChatPwd; // 聊天密码

FOUNDATION_EXPORT QCChannelExtraKey const _Nullable  QCChannelExtraKeySource; // 来源
FOUNDATION_EXPORT QCChannelExtraKey const _Nullable QCChannelExtraKeyVercode; // 加好友验证码

FOUNDATION_EXPORT QCChannelExtraKey const _Nullable QCChannelExtraKeyAllowViewHistoryMsg; // 允许新成员查看群历史消息

FOUNDATION_EXPORT QCChannelExtraKey const _Nullable QCChannelExtraKeyRemark; // 备注

