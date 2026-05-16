//
//  QCFuncItemButton.h
//  WuKongBase
//
//  Created by tt on 2020/2/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCFuncItemButton : UIButton

@property(nonatomic,copy) void(^onSelected)(void);

@end

NS_ASSUME_NONNULL_END
