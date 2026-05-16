//
//  QCGroupManagerVC.h
//  QCCore
//
//  Created by tt on 2020/3/1.
//

#import <UIKit/UIKit.h>
#import "QCBaseTableVC.h"
#import "QCGroupManagerVM.h"
#import <QCIM/QCIM.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCGroupManagerVC : QCBaseTableVC<QCGroupManagerVM*>

@property(nonatomic,strong) QCChannel *channel;

@end

NS_ASSUME_NONNULL_END
