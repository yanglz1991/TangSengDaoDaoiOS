//
//  QCLogicView.h
//  QCAuth
//
//  Created by tt on 2019/12/2.
//

#import <UIKit/UIKit.h>
#import <QCCore/QCCore.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^onLogin)(NSString*mobile,NSString*password,NSString *country);
@interface QCLoginView : UIView

@property(nonatomic,copy) onLogin onLogin;

@property(nonatomic,strong) NSString *country;
@property(nonatomic,strong) NSString *mobile;

- (void)viewConfigChange:(QCViewConfigChangeType)type;
@end

NS_ASSUME_NONNULL_END
