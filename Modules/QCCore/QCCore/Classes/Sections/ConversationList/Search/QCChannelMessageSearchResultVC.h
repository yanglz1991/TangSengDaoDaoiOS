//
//  QCChannelSearchResultVC.h
//  QCCore
//
//  Created by tt on 2020/8/10.
//

#import <QCCore/QCCore.h>
#import "QCChannelMessageSearchVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCChannelMessageSearchResultVC : QCBaseTableVC<QCChannelMessageSearchVM*>
@property(nonatomic,strong) QCChannel *channel;
@property(nonatomic,copy) NSString *keyword;
@end

NS_ASSUME_NONNULL_END
