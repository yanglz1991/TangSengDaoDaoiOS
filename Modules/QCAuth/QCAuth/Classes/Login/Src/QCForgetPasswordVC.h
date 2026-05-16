//
//  QCForgetPasswordVC.h
//  QCAuth
//
//  Created by tt on 2020/10/27.
//

#import <QCCore/QCCore.h>
#import "QCForgetPasswordVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCForgetPasswordVC : QCBaseVC<QCForgetPasswordVM*>

@property(nonatomic,strong) NSString *country;
@property(nonatomic,copy) NSString *mobile;


@end

NS_ASSUME_NONNULL_END
