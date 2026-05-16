//
//  QCUserInfoVC.h
//  WuKongBase
//
//  Created by tt on 2020/6/19.
//

#import "QCBaseTableVC.h"
#import "QCUserInfoVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCUserInfoVC : QCBaseTableVC<QCUserInfoVM*>

@property(nonatomic,strong) NSString *uid; // 用户的唯一ID

@property(nonatomic,copy) NSString *vercode; // 加好友的验证码

@property(nonatomic,strong,nullable) QCChannel *fromChannel; // 从那个频道进入的用户信息页面

@end

@interface QCUserFieldView : UIView


-(instancetype) initWithField:(NSString*)field;

@property(nonatomic,copy) NSString *value;

@end

NS_ASSUME_NONNULL_END
