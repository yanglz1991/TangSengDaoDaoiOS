//
//  QCChannelSearchResultVC.h
//  WuKongBase
//
//  Created by tt on 2020/8/10.
//

#import <WuKongBase/WuKongBase.h>
#import "QCChannelMessageSearchVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCChannelMessageSearchResultVC : QCBaseTableVC<QCChannelMessageSearchVM*>
@property(nonatomic,strong) QCChannel *channel;
@property(nonatomic,copy) NSString *keyword;
@end

NS_ASSUME_NONNULL_END
