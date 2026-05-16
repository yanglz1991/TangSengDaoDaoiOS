//
//  QCButton.h
//  QCCore
//
//  Created by tt on 2019/12/2.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    QCButtonStyleDefault,
} QCButtonStyle;

NS_ASSUME_NONNULL_BEGIN

@interface QCButton : UIButton
-(instancetype) initWithStyle:(QCButtonStyle)style;
@end

NS_ASSUME_NONNULL_END
