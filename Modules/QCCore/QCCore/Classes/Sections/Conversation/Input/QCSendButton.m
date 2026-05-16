//
//  QCSendButton.m
//  QCCore
//
//  Created by tt on 2021/10/26.
//

#import "QCSendButton.h"
#import "QCCore.h"

@interface QCSendButton ()

@property(nonatomic,assign) CGSize oldSize;

@end

@implementation QCSendButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.oldSize = frame.size;
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.frame.size.height/2.0f;
        self.backgroundColor = [QCApp shared].config.themeColor;
        [self setImage:[self imageName:@"Conversation/Panel/SendButton"] forState:UIControlStateNormal];
        
        [self addTarget:self action:@selector(sendPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void) sendPressed {
    if(self.onSend) {
        self.onSend();
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    if(self.show) {
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.oldSize.width, self.oldSize.height);
//    } else {
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 0.0f, 0.0f);
//    }
//    self.layer.cornerRadius = self.frame.size.height/2.0f;

}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//   return  [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}

@end
