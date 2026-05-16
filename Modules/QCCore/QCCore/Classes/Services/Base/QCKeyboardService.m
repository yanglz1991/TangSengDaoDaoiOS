//
//  QCKeyboardService.m
//  QCCore
//
//  Created by tt on 2022/9/25.
//

#import "QCKeyboardService.h"
#import "QCNavigationManager.h"

@interface QCKeyboardService ()



@end

@implementation QCKeyboardService

static QCKeyboardService *_instance;
+ (QCKeyboardService *)shared {
    if (_instance == nil) {
        _instance = [[super alloc]init];
    }
    return _instance;
}

-(void) setup {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center  addObserver:self selector:@selector(keyboardDidShow)  name:UIKeyboardDidShowNotification  object:nil];
    [center addObserver:self selector:@selector(keyboardDidHide)  name:UIKeyboardWillHideNotification object:nil];
    [center addObserver:self selector:@selector(keyboardChangeFrame)  name:UIKeyboardDidChangeFrameNotification object:nil];
}

-(void) keyboardChangeFrame {
  
}

- (void)keyboardDidShow{
    self.keyboardIsVisible = YES;
    
}
 
- (void)keyboardDidHide{
     self.keyboardIsVisible = NO;
}

@end
