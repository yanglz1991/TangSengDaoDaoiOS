//
//  QCFuncGroupView.h
//  QCCore
//
//  Created by tt on 2022/5/3.
//

#import <UIKit/UIKit.h>
#import "QCConversationInputPanel.h"
#import "QCFuncItemButton.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCFuncGroupView : UIView

@property(nonatomic,assign) CGFloat scaleZoom; // 放大倍数
@property(nonatomic,assign) BOOL startScroll; // 是否开始滚动
@property(nonatomic,copy) void(^onLayout)(void); // 布局

- (instancetype)initWithFrame:(CGRect)frame inputPanel:(QCConversationInputPanel*)inputPanel;


// 取消所有选中的item
-(void) unSelectedItems;

-(void) stopZoom; // 停止放大

-(BOOL) isZooming; // 是否是放大状态

@end


@interface QCFuncGroupItemView : UIView

-(instancetype) initWithButton:(QCFuncItemButton*)btn scaleZoom:(CGFloat)scaleZoom;

@property(nonatomic,assign) BOOL changeToBig; // 变大

@property(nonatomic,assign) BOOL selected;

@property(nonatomic,assign) BOOL showSplit; // 显示分割线

@property(nonatomic,copy) void(^onClick)(QCFuncGroupItemView *itemView);

-(void) triggerClick;

@end

NS_ASSUME_NONNULL_END
