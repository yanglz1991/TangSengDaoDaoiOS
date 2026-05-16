//
//  QCContactsInfoVC.h
//  QCContacts
// 联系人信息
//  Created by tt on 2019/12/31.
//

#import <Foundation/Foundation.h>
#import <QCCore/QCCore.h>
#import "QCContactsInfoVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCContactsInfoVC : QCBaseVC

@property(nonatomic,copy) NSString *uid; // 用户uid

@end

// 联系人信息头部
@interface QCContactsInfoHeader : UIView

-(void) refresh:(QCUserInfoResp*)model;

@end

// 联系人信息底部
@interface QCContactsInfoFooter : UIView

-(void) refresh:(QCUserInfoResp*)model;

@end

NS_ASSUME_NONNULL_END
