//
//  QCGrantLoginVC.h
//  QCAuth
//
//  Created by tt on 2020/4/18.
//

#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCGrantLoginVC : QCBaseVC
// 授权码
@property(nonatomic,copy) NSString *authCode;

// base64加密的公钥
@property(nonatomic,copy) NSString *pubkeyBase64Enc;
@end

NS_ASSUME_NONNULL_END
