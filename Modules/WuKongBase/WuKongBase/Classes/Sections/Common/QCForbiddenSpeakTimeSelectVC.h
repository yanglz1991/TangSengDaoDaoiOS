//
//  QCForbiddenSpeakTimeSelectVC.h
//  WuKongBase
//
//  Created by tt on 2022/3/25.
//

#import <WuKongBase/WuKongBase.h>
#import "QCForbiddenSpeakTimeSelectVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCForbiddenSpeakTimeSelectVC : QCBaseTableVC<QCForbiddenSpeakTimeSelectVM*>

@property(nonatomic,copy) NSString *uid; // 禁言的用户uid
@property(nonatomic,strong) QCChannel *channel; // 用户所在频道


@end

NS_ASSUME_NONNULL_END
