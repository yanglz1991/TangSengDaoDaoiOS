//
//  QCPanel.m
//  QCCore
//
//  Created by tt on 2020/1/11.
//

#import "QCPanel.h"
#import "UIView+CornerRadius.h"
#import "QCCore.h"

#define cornerRadiHeight 15.0f
@interface QCPanel ()

@end

@implementation QCPanel

-(instancetype) initWithContext:(id<QCConversationContext>) context {
    self = [super init];
    if(self) {
        self.context = context;
        self.backgroundColor =[QCApp shared].config.backgroundColor;
        self.contentView.backgroundColor = [QCApp shared].config.backgroundColor;
        [self addSubview:self.contentView];
    }
    return self;
}

-(void) inputInsertText:(NSString *)text {
    [self.context inputInsertText:text];
}

-(void) layoutPanel:(CGFloat)height {
    self.frame = CGRectMake(0, 0, QCScreenWidth,height);
    self.contentView.frame = CGRectMake(0.0f, cornerRadiHeight/2.0f, QCScreenWidth, height - cornerRadiHeight/2.0f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self clipCornerWithView:YES andTopRight:YES andBottomLeft:false andBottomRight:false cornerRadii:CGSizeMake(cornerRadiHeight, cornerRadiHeight)];
}


- (UIView *)contentView {
    if(!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

@end
