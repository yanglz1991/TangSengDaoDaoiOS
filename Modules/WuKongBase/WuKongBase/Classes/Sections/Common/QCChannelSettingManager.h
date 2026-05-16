//
//  QCChannelSettingManager.h
//  WuKongBase
//
//  Created by tt on 2021/8/10.
//

#import <Foundation/Foundation.h>
#import <WuKongIMSDK/WuKongIMSDK.h>
#import <PromiseKit/PromiseKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCChannelSettingManager : NSObject

+ (instancetype _Nonnull )shared;

// 免打扰
-(void) channel:(QCChannel*)channel mute:(BOOL) on;
-(BOOL) mute:(QCChannel*)channel;

// 置顶
-(void) channel:(QCChannel*)channel stick:(BOOL) on;
-(BOOL) stick:(QCChannel*) channel;

// 消息回执
-(void) channel:(QCChannel*)channel receipt:(BOOL) on;
-(BOOL) receipt:(QCChannel*)channel;

// 聊天密码开关
-(void) channel:(QCChannel*)channel chatPwdOn:(BOOL)on;
-(BOOL)chatPwdOn:(QCChannel*)channel;

// 截屏通知
-(void) channel:(QCChannel*)uid screenshot:(BOOL) on;
-(BOOL)screenshot:(QCChannel*)channel;

// 保存到通讯录
-(void) group:(NSString*)groupNo save:(BOOL) on;
-(BOOL) save:(QCChannel*)channel;


// 撤回提醒
-(void) channel:(QCChannel*)channel revokeRemind:(BOOL)on;
-(BOOL)revokeRemind:(QCChannel*)channel;

// 进群提醒
-(void) channel:(QCChannel*)channel joinGroupRemind:(BOOL)on;
-(BOOL) joinGroupRemind:(QCChannel*)channel;


// 备注设置
-(AnyPromise*) channel:(QCChannel*)channel remark:(NSString*)remark;

// 阅后即焚
-(void) channel:(QCChannel*)channel flame:(BOOL) on;

// 阅后即焚时间
-(void) channel:(QCChannel*)channel flameSecond:(NSInteger) flameSecond;

-(NSString*) remark:(QCChannel*)channel;
@end

NS_ASSUME_NONNULL_END
