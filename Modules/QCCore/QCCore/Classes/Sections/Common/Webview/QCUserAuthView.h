//
//  QCUserAuthVC.h
//  QCCore
//
//  Created by tt on 2023/9/12.
//

#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCUserAuthView : UIView

@property(nonatomic,copy) NSString *appLogo;
@property(nonatomic,copy) NSString *appName;

@property(nonatomic,assign) BOOL show;

@property(nonatomic,copy) void(^onClose)(void);

@property(nonatomic,copy) void (^onAllow)(void);

@end

NS_ASSUME_NONNULL_END
