//
//  QCMultiplePanel.h
//  WuKongBase
//  多选面板
//  Created by tt on 2020/10/11.
//

#import <UIKit/UIKit.h>
@class QCMultiplePanel;
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    QCMultipActionNone,
    QCMultipActionDelete, // 删除
    QCMultipActionForward, // 逐条转发
    QCMultipActionMergeForward, // 合并转发
    
} QCMultipAction;

@protocol QCMultiplePanelDelegate <NSObject>

@optional


/// 多选面板行为
/// @param panel <#panel description#>
/// @param action <#action description#>
-(void) multiplePanel:(QCMultiplePanel*)panel action:(QCMultipAction)action;

@end

@interface QCMultiplePanel : UIView

@property(nonatomic,weak) id<QCMultiplePanelDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
