//
//  QCActionSheetItem2.h
//  QCCore
//
//  Created by tt on 2020/6/21.
//

#import <UIKit/UIKit.h>
#import "UIView+WK.h"
typedef void(^onItemClick)(void);
NS_ASSUME_NONNULL_BEGIN

@interface QCActionSheetItem2 : UIView
// 是否显示底部线条
@property(nonatomic,assign) BOOL showBottomLine;

@end

@interface QCActionSheetTipItem2 : QCActionSheetItem2

@property(nonatomic,strong) UILabel *tipLbl;

+(QCActionSheetTipItem2*) initWithTip:(NSString*)tip;

@end

@interface QCActionSheetButtonItem2 : QCActionSheetItem2
@property(nonatomic,strong) onItemClick onItemClick;
+(QCActionSheetButtonItem2*) initWithTitle:(NSString*)title onClick:(onItemClick)onItemClick;
+ (QCActionSheetButtonItem2 *)initWithAlertTitle:(NSString *)alertTitle onClick:(onItemClick)onItemClick;

@end

@interface QCActionSheetButtonSubtitleItem2 : QCActionSheetItem2
@property(nonatomic,strong) onItemClick onItemClick;
+(QCActionSheetButtonItem2*) initWithTitle:(NSString*)title subtitle:(NSString*)subtitle onClick:(onItemClick)onItemClick;

@end

@interface QCActionSheetCancelItem2 : QCActionSheetItem2
+ (QCActionSheetCancelItem2 *)initWithTitle:(NSString *)title onClick:(onItemClick)onItemClick;
@end


NS_ASSUME_NONNULL_END
