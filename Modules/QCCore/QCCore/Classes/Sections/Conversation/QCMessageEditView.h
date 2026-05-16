//
//  QCMessageEditView.h
//  QCCore
//
//  Created by tt on 2022/4/15.
//

#import <UIKit/UIKit.h>
#import <QCIM/QCIM.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCMessageEditView : UIView

+(instancetype) message:(QCMessage*)message;

@property(nonatomic,copy) void(^onClose)(void);

@end

NS_ASSUME_NONNULL_END
