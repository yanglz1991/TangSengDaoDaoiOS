//
//  QCLoginPhoneCheckVM.h
//  WuKongLogin
//
//  Created by tt on 2020/10/26.
//

#import <WuKongBase/WuKongBase.h>
@class QCLoginPhoneCheckVM;
NS_ASSUME_NONNULL_BEGIN

@protocol QCLoginPhoneCheckVMDelegate <NSObject>

@optional

// 发送验证码
-(void) loginPhoneCheckVMDidSend:(QCLoginPhoneCheckVM*)vm;


///  ok按钮点击
/// @param vm <#vm description#>
-(void) loginPhoneCheckVMDidOk:(QCLoginPhoneCheckVM*)vm;

@end

@interface QCLoginPhoneCheckVM : QCBaseTableVM

@property(nonatomic,weak) id<QCLoginPhoneCheckVMDelegate> delegate;

@property(nonatomic,copy) NSString *phone;

@property(nonatomic,copy) NSString *sendBtnTitle;
@property(nonatomic,assign) BOOL sendBtnDisable;


/// 发送登录检查验证吗
/// @param uid <#uid description#>
-(AnyPromise*) sendLoginCheckCode:(NSString*)uid;


/// 通过检查验证吗登录
/// @param uid <#uid description#>
/// @param code <#code description#>
-(AnyPromise*) loginCheckPhone:(NSString*)uid code:(NSString*)code;

// 获取输入的验证吗
-(NSString*) getCode;


@end

NS_ASSUME_NONNULL_END
