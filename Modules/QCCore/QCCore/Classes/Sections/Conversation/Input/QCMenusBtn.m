//
//  QCMenusBtn.m
//  QCCore
//
//  Created by tt on 2021/10/14.
//

#import "QCMenusBtn.h"
#import "QCApp.h"
#import <Lottie/Lottie.h>

@interface QCMenusBtn ()


@property(nonatomic,strong) LOTAnimationView *animationView;

@end

@implementation QCMenusBtn

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self addTarget:self action:@selector(onPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void) setupUI {
//    [self changeStatus];
    self.animationView = [LOTAnimationView animationNamed:@"Other/robot_menu" inBundle:[QCApp.shared resourceBundle:@"QCCore"]];
    self.animationView.loopAnimation = NO;
    self.animationView.animationSpeed = 3.0f;
    self.animationView.frame = self.bounds;
    self.animationView.center = self.center;
    self.animationView.contentMode = UIViewContentModeScaleAspectFit;
    self.animationView.userInteractionEnabled = NO;
    [self addSubview:self.animationView];
    
}

-(UIImage*) imageName:(NSString*)name {
//    return [currentModule ImageForResource:name];
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//   return  [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}

-(void) onPressed {
    self.openMenus = !self.openMenus;
    [self changeStatus];
    if(self.onClick) {
        self.onClick(self.openMenus);
    }
}

-(void) changeStatus {
//    if(!self.imageView.image) {
//        [self setImage:[self imageName:@"icon_btn_menus"] forState:UIControlStateNormal];
//        return;
//    }
    
    [self animation:self.openMenus completion:nil];
    if(self.openMenus) {
        [self.animationView playToProgress:0.5f withCompletion:^(BOOL animationFinished) {
            
        }];
    }else {
        [self.animationView playFromProgress:0.5f toProgress:1.0f withCompletion:^(BOOL animationFinished) {
            
        }];
    }
    
}

-(void) animation:(BOOL)openMenus completion:(void(^)(BOOL finished ))completion{
    
    self.layer.transform = CATransform3DMakeScale(1, 1, 1);
    [UIView animateWithDuration:0.1f animations:^{
        self.layer.transform = CATransform3DMakeScale(0.8f, 0.8f, 1);

    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f animations:^{
            self.layer.transform = CATransform3DMakeScale(1, 1, 1);

        } completion:^(BOOL finished) {
            
        }];
    }];
}

@end
