//
//  QCImageView.m
//  QCCore
//
//  Created by tt on 2019/12/2.
//

#import "QCImageView.h"
#import <SDWebImage/SDWebImage.h>
#import "QCResource.h"
#import "QCApp.h"
#import "UIImageView+WK.h"

@implementation QCImageView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void) loadImage:(NSURL*)url placeholderImage:(UIImage*)placeholderImage{
    [self lim_setImageWithURL:url placeholderImage:placeholderImage];
    
}

-(void) loadImage:(NSURL*)url{
    UIImage *placeholdeImg =   [QCApp.shared loadImage:@"Common/Index/Placeholder" moduleID:@"QCCore"];
    
    [self lim_setImageWithURL:url placeholderImage:placeholdeImg];
}
@end
