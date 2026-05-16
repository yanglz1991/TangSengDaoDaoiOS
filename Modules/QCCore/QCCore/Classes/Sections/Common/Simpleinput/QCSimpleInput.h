//
//  QCSimpleInput.h
//  QCMoment
//
//  Created by tt on 2020/11/17.
//

#import <UIKit/UIKit.h>
#import "QCGrowingTextView.h"
@class QCSimpleInput;
NS_ASSUME_NONNULL_BEGIN

@protocol QCSimpleInputDelegate <NSObject>

@optional
// 输入框弹起
- (void)simpleInputUp:(QCSimpleInput *)input up:(BOOL)up;

// 输入框高度发生改变
-(void) simpleInput:(QCSimpleInput*) input heightChange:(CGFloat)height;
// 发送文本
-(void) simpleInput:(QCSimpleInput*) input sendText:(NSString*)text;

@end

@interface QCSimpleInput : UIView

@property(nonatomic,weak) id<QCSimpleInputDelegate> delegate;

@property(nonatomic,strong) QCGrowingTextView *textView;

@property (assign, nonatomic) CGFloat keyboardHeight; // 键盘高度
@property(nonatomic,assign,readonly) CGFloat inputTotalHeight; //当前输入框总高度

@property(nonatomic,assign,readonly) CGFloat inputTextViewMinHeight; //当前输入框最小高度

@property(nonatomic,copy) NSString *placeholder; // 占位


- (void)becomeFirstResponder;



@end

NS_ASSUME_NONNULL_END
