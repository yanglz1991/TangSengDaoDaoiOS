//
//  QCEmojiCollectionTitleHeader.m
//  QCCore
//
//  Created by tt on 2021/10/22.
//

#import "QCEmojiCollectionTitleHeader.h"
#import "QCCore.h"
@interface QCEmojiCollectionTitleHeader ()



@end

@implementation QCEmojiCollectionTitleHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLbl];
    }
    return self;
}

- (void)layoutSubviews {
    
    self.titleLbl.lim_centerY_parent = self;
    self.titleLbl.lim_left = 10.0f;
}


- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = [[QCApp shared].config appFontOfSize:14.0f];
    }
    return _titleLbl;
}

@end
