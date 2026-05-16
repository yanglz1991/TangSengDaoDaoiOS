//
//  QCBaseVC.h
//  WuKongBase
//
//  Created by tt on 2019/12/1.
//

#import <UIKit/UIKit.h>
#import "QCBaseVM.h"
#import "QCNavigationBar.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    QCViewConfigChangeTypeUnknown, // 未知
    QCViewConfigChangeTypeStyle, // 样式 （深色模式，亮色模式）
    QCViewConfigChangeTypeLang, // 多语言
    QCViewConfigChangeTypeModule, // 模块发生改变
} QCViewConfigChangeType;

@interface QCFinishButton : UIButton

@end

@interface QCBaseVC<__covariant ObjectType:QCBaseVM*> : UIViewController

@property(nonatomic,strong) QCNavigationBar *navigationBar; // 自定义的导航栏

@property(nonatomic,strong,nullable) UIView *rightView; // 导航栏右边视图

@property(nonatomic,strong) QCFinishButton *finishBtn; // 完成按钮

@property(nonatomic,assign,readonly) BOOL largeTitle; // 是否开启大标题模式

-(instancetype) initWithViewModel:(QCBaseVM*)vm;

@property(nonatomic,strong) ObjectType viewModel;

@property(nonatomic,strong) QCBaseVM *baseVM;


/// 获取导航栏底部距离
-(CGFloat) getNavBottom;
// 可视区域的frame
-(CGRect) visibleRect;


/// 返回点击
-(void) backPressed;


/// 视图配置发送变化
/// @param type 变化类型
-(void) viewConfigChange:(QCViewConfigChangeType)type;


/// 多语言标题 ，当多语言发送变化的时候会调用此标题
-(NSString*) langTitle;
@end

NS_ASSUME_NONNULL_END
