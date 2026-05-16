//
//  QCLoginPhoneCheckVC.h
//  QCAuth
//
//  Created by tt on 2020/10/26.
//

#import <QCCore/QCCore.h>
#import "QCLoginPhoneCheckVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCLoginPhoneCheckVC : QCBaseTableVC<QCLoginPhoneCheckVM*>

@property(nonatomic,copy) NSString *phone;
@property(nonatomic,copy) NSString *uid;

@end

NS_ASSUME_NONNULL_END
