//
//  QCViewItemCell.m
//  WuKongBase
//
//  Created by tt on 2020/1/21.
//

#import "QCViewItemCell.h"
#import "QCLabelItemCell.h"
#import "QCResource.h"
#import "QCApp.h"
@implementation QCViewItemModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bottomLeftSpace  = @(20.0f);
    }
    return self;
}

- (Class)cell {
    return QCViewItemCell.class;
}


@end

@interface QCViewItemCell ()



@end

@implementation QCViewItemCell

- (void)setupUI {
    [super setupUI];
    self.labelLbl = [[UILabel alloc] init];
    [self.labelLbl setFont:[[QCApp shared].config appFontOfSize:16.0f]];
    [self.contentView addSubview:self.labelLbl];
    
    self.valueView = [[UIView alloc] init];
    [self.contentView addSubview:self.valueView];
}

- (void)refresh:(QCViewItemModel *)model {
    [super refresh:model];
    self.labelLbl.text = model.label;
    [self.labelLbl sizeToFit];

    if(model.labelColor) {
        [self.labelLbl setTextColor:model.labelColor];
    }else{
        [self.labelLbl setTextColor:[QCApp shared].config.defaultTextColor];
    }
    
   
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat labelLeft = 15.0f;
    self.labelLbl.lim_top = self.lim_height/2.0f - self.labelLbl.lim_height/2.0f;
    self.labelLbl.lim_left = labelLeft;
    
    CGFloat valueLeft = 10.0f;
    self.valueView.lim_height = self.lim_height;
    CGFloat arrowRight = 10.0f;
    self.valueView.lim_width = self.lim_width - ( self.labelLbl.lim_left + self.labelLbl.lim_width) - valueLeft - self.arrowImgView.lim_width - arrowRight - 10.0f;
    self.valueView.lim_left = self.labelLbl.lim_right + valueLeft;

}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}
@end
