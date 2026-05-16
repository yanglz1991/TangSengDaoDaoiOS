//
//  QCTextView.h
//  WuKongBase
//
//  Created by tt on 2020/2/2.
//

#import <UIKit/UIKit.h>
#import "UITextView+QCPlaceholder.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCTextView : UITextView

@property(nonatomic,weak,nullable) UIResponder * overrideNextResponder;

@end

NS_ASSUME_NONNULL_END
