//
//  QCLabelItemSelectCell.m
//  QCCore
//
//  Created by tt on 2020/12/11.
//

#import "QCLabelItemSelectCell.h"
#import "QCApp.h"

@implementation QCLabelItemSelectModel

- (NSNumber *)showArrow {
    return @(NO);
}

- (Class)cell {
    return QCLabelItemSelectCell.class;
}

@end

@interface QCLabelItemSelectCell ()

@property(nonatomic,strong) UIImageView *selectImgView;

@end

@implementation QCLabelItemSelectCell

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.selectImgView];
}

- (void)refresh:(QCLabelItemSelectModel *)model {
    [super refresh:model];
    self.selectImgView.hidden = !model.selected;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.selectImgView.lim_centerY_parent = self.contentView;
    self.selectImgView.lim_left = self.contentView.lim_width - self.selectImgView.lim_width - 15.0f;
}

- (UIImageView *)selectImgView {
    if(!_selectImgView) {
        _selectImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 16.0f)];
        _selectImgView.image = [self getImageName:@"Common/Index/Tick"];
    }
    return _selectImgView;
}


-(UIImage*) getImageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//    return [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}

@end
