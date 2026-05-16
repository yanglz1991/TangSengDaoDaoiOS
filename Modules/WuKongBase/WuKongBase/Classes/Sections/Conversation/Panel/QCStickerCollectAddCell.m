//
//  QCStickerCollectAddCell.m
//  WuKongBase
//
//  Created by tt on 2021/10/28.
//

#import "QCStickerCollectAddCell.h"
#import "WuKongBase.h"
@implementation QCStickerCollectAddCellModel



@end

@interface QCStickerCollectAddCell ()

@property(nonatomic,strong) UIImageView *addImgView;

@end

@implementation QCStickerCollectAddCell

+(NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.addImgView];
    }
    return self;
}



- (UIImageView *)addImgView {
    if(!_addImgView) {
        _addImgView = [[UIImageView alloc] initWithFrame:self.frame];
        _addImgView.image = [self imageName:@"Conversation/Panel/CollectionAdd"];
    }
    return _addImgView;
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}

@end
