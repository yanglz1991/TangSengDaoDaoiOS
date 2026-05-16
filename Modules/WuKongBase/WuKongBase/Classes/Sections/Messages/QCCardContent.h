//
//  QCCardContent.h
//  WuKongBase
//
//  Created by tt on 2020/5/5.
//

#import <WuKongIMSDK/WuKongIMSDK.h>
#import "QCConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCCardContent : QCMessageContent


/// 初始化
/// @param uid 用户唯一ID
/// @param name 用户名称
/// @param avatar 用户头像
+(QCCardContent*) cardContent:(NSString*)vercode uid:(NSString*)uid name:(NSString*)name avatar:(NSString*)avatar;

@property(nonatomic,copy) NSString *avatar; // 用户头像
@property(nonatomic,copy) NSString *name; // 用户名称
@property(nonatomic,copy) NSString *uid; // 用户uid
@property(nonatomic,copy) NSString *vercode; // 加好友验证码

@end

NS_ASSUME_NONNULL_END
