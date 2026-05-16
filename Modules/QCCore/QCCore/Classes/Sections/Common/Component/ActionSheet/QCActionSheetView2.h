//
//  QCActionSheetView2.h
//  QCCore
//
//  Created by tt on 2020/6/21.
//

#import <UIKit/UIKit.h>
#import "QCActionSheetItem2.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCActionSheetView2 : UIView

@property(nonatomic,copy) void(^onHide)(void);

/// 初始化
/// @param tip 提示内容
+(QCActionSheetView2*) initWithTip:(NSString* __nullable)tip;


/// 初始化
/// @param tip 提示内容
/// @param cancelBtnTitle 取消标题
+(QCActionSheetView2*) initWithTip:(NSString* __nullable)tip cancel:(NSString* __nullable)cancelBtnTitle;


/// 初始化
/// @param cancelBtnTitle 取消标题
+(QCActionSheetView2*) initWithCancel:(NSString* __nullable)cancelBtnTitle;


/// 添加item
/// @param item <#item description#>
-(void) addItem:(QCActionSheetItem2*)item;

/// 显示
-(void) show;
///  隐藏
-(void) hide;



@end

NS_ASSUME_NONNULL_END
