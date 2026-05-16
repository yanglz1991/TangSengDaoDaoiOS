//
//  QCChannelMessageSearchVM.h
//  WuKongBase
//
//  Created by tt on 2020/8/10.
//

#import "QCBaseVM.h"
#import "QCFormSection.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCChannelMessageSearchVM : QCBaseTableVM
@property(nonatomic,strong) QCChannel *channel;
@property(nonatomic,copy) NSString *keyword;

@end

NS_ASSUME_NONNULL_END
