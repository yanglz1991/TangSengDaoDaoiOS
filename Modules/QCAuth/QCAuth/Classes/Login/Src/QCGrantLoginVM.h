//
//  QCGrantLoginVM.h
//  QCAuth
//
//  Created by tt on 2020/4/18.
//

#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCGrantLoginVM : QCBaseVM
// 授权码
@property(nonatomic,copy) NSString *authCode;
// base64加密的公钥
@property(nonatomic,copy) NSString *pubkeyBase64Enc;

+(id) initWithAuthCode:(NSString*)authCode pubkeyBase64Enc:(NSString*)pubkeyBase64Enc;


/// 授权登录
-(AnyPromise*) grantLogin;

@end

NS_ASSUME_NONNULL_END
