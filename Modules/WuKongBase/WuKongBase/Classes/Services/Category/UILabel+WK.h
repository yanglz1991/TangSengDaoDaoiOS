//
//  UILabel+WK.h
//  WuKongBase
//
//  Created by tt on 2021/7/27.
//

#import <UIKit/UIKit.h>
#import "NSMutableAttributedString+WK.h"
#import "QCRichTextParseService.h"
NS_ASSUME_NONNULL_BEGIN

@interface UILabel (WK)

@property(nonatomic,strong) NSArray<id<QCMatchToken>> *tokens;

-(void) onClick:(void(^)(id<QCMatchToken>))click;

- (BOOL)didTapAttributedTextInLabel:(UITapGestureRecognizer *)tapGesture inRange:(NSRange)targetRange;

-( id<QCMatchToken>) matchDidTapAttributedTextInLabelWithPoint:(CGPoint)locationOfTouchInLabel;
-(void) onTap:(UITapGestureRecognizer*)gesture;
@end

NS_ASSUME_NONNULL_END
