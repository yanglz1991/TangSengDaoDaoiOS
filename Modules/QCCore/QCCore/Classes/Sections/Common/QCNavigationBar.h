//
//  QCNavigationBar.h
//  QCCore
//
//  Created by tt on 2020/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    QCNavigationBarStyleDefault, // 默认样式
    QCNavigationBarStyleWhite, // 白色样式
    QCNavigationBarStyleDark, // 深色模式
} QCNavigationBarStyle;

@interface QCNavigationBar : UIView

@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *subtitleLabel;
@property(nonatomic,strong) UIButton *backButton;

/// 导航栏标题
@property(nonatomic,copy) NSString *title;


/// 子标题
@property(nonatomic,copy,nullable) NSString *subtitle;

/// 右边视图
@property(nonatomic,strong) UIView *rightView;


/// 右边视图frame
@property(nonatomic,assign) CGRect rightViewFrame;


/// 显示返回按钮
@property(nonatomic,assign) BOOL showBackButton;


/// 是否开启大标题模式
@property(nonatomic,assign) BOOL largeTitle;

// 样式
@property(nonatomic,assign) QCNavigationBarStyle style;


/// 返回点击
@property(nonatomic,strong) void(^onBack)(void);

@end

NS_ASSUME_NONNULL_END
