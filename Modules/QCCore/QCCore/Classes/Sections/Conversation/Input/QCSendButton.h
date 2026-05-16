//
//  QCSendButton.h
//  QCCore
//
//  Created by tt on 2021/10/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCSendButton : UIButton

@property(nonatomic,assign) BOOL show;

@property(nonatomic,copy) void(^onSend)(void);

@end

NS_ASSUME_NONNULL_END
