//
//  QCWebViewVC.h
//  WuKongBase
//
//  Created by tt on 2020/4/3.
//

#import "QCBaseVC.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCWebViewVC : QCBaseVC

@property(nonatomic,strong) NSURL *url;

// 频道对象，如果是从聊天页面跳转到web请给channel赋值
@property(nonatomic,strong,nullable) QCChannel *channel;
@end

NS_ASSUME_NONNULL_END
