//
//  QCCircularProgressView.h
//  WuKongBase
//
//  Created by tt on 2021/4/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCCircularProgressView : UIView

@property (nonatomic, assign) float progress;

@property(nonatomic,strong) UIColor *circularFillColor;
@property(nonatomic,strong) UIColor *circularBorderColor;

@end

NS_ASSUME_NONNULL_END
