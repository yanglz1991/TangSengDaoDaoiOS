//
//  QCCMDManager.h
//  WuKongIMSDK
//
//  Created by tt on 2020/10/7.
//

#import <Foundation/Foundation.h>
#import "QCSyncConversationModel.h"
@class QCCMDManager;
NS_ASSUME_NONNULL_BEGIN

@protocol QCCMDManagerDelegate <NSObject>

@optional


/// 收到命令
/// @param manager <#manager description#>
/// @param model <#model description#>
-(void) cmdManager:(QCCMDManager*)manager onCMD:(QCCMDModel*)model;

@end

@interface QCCMDManager : NSObject

// 设置验证cmd的公钥
@property(nonatomic,copy) NSString *pubKey;


/**
 添加cmd委托
 
 @param delegate <#delegate description#>
 */
-(void) addDelegate:(id<QCCMDManagerDelegate>) delegate;


/**
 移除cmd委托
 
 @param delegate <#delegate description#>
 */
-(void)removeDelegate:(id<QCCMDManagerDelegate>) delegate;


/// 调用接受命令委托
/// @param model <#model description#>
-(void) callOnCMDDelegate:(QCCMDModel*)model;

// 拉取cmd消息
-(void) pullCMDMessages;

@end

NS_ASSUME_NONNULL_END
