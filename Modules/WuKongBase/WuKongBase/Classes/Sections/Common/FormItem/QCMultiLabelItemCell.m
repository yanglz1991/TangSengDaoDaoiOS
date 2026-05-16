//
//  QCMulitLabelItemCell.m
//  WuKongBase
//
//  Created by tt on 2020/1/30.
//

#import "QCMultiLabelItemCell.h"
#import "QCResource.h"
#import "QCApp.h"
@implementation QCMultiLabelItemModel

- (Class)cell {
    return QCMultiLabelItemCell.class;
}

@end

@interface QCMultiLabelItemCell ()

@property(nonatomic,strong) UILabel *labelLbl;
@property(nonatomic,strong) UILabel *valueLbl;

@property(nonatomic,strong) QCMultiLabelItemModel *multilModel;

@end

#define QCMultiValueFontSize 15.0f
#define QCMultiLabelFontSize 17.0f

#define QCMultiValueMaxWidth QCScreenWidth - 40.0f

#define QCMultiValueMaxWidthWithLeftRight 240.0f

#define QCMultiLabelTopSpace 10.0f
#define QCMultiValueTopSpace 10.0f
#define QCMultiValueBottomSpace 10.0f

#define WKultiValueMaxHeight 70.0f


@implementation QCMultiLabelItemCell

+(CGSize) sizeForModel:(QCMultiLabelItemModel*)model{
    CGSize labelSize = [self getTextSize:model.label maxWidth:QCScreenWidth maxHeight:MAXFLOAT fontSize:QCMultiLabelFontSize];
    if(model.value) {
        CGFloat maxWidth = QCMultiValueMaxWidth;
       
        if(model.mode && [model.mode integerValue] == QCMultiLabelItemModeLeftRight) {
            maxWidth = QCMultiValueMaxWidthWithLeftRight;
            
        }
        CGSize valueSize = [self getTextSize:model.value?:@"" maxWidth:maxWidth maxHeight:WKultiValueMaxHeight fontSize:QCMultiValueFontSize];
        
        CGFloat height = QCMultiLabelTopSpace + labelSize.height + QCMultiValueTopSpace + valueSize.height + QCMultiValueBottomSpace+4.0f;
        if(model.mode && [model.mode integerValue] == QCMultiLabelItemModeLeftRight) {
            height = valueSize.height + 20.0f;
        }
        
        return CGSizeMake(QCScreenWidth,MAX(height, model.cellHeight));
    }
    return  CGSizeMake(QCScreenWidth, 54.0f);
   
}

- (void)setupUI {
    [super setupUI];
    self.labelLbl = [[UILabel alloc] init];
    [self.labelLbl setFont:[[QCApp shared].config appFontOfSize:16.0f]];
    [self addSubview:self.labelLbl];
    
    self.valueLbl = [[UILabel alloc] init];
    [self.valueLbl setFont:[[QCApp shared].config appFontOfSize:QCMultiValueFontSize]];
    self.valueLbl.numberOfLines = 3;
    self.valueLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.valueLbl setTextColor:[UIColor grayColor]];
    [self addSubview:self.valueLbl];
    
}

-(void) refresh:(QCMultiLabelItemModel *)model {
    [super refresh:model];
    self.multilModel = model;
    self.labelLbl.text = model.label;
    [self.labelLbl sizeToFit];
    
    [self.labelLbl setTextColor:[QCApp shared].config.defaultTextColor];
    
    self.valueLbl.text = model.value;
    
}

-(QCMultiLabelItemMode) getMode {
    if(!self.multilModel.mode) {
        return QCMultiLabelItemModeUpDown;
    }
    return [self.multilModel.mode integerValue];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat labelLeft = 15.0f;
    
    self.labelLbl.lim_left = labelLeft;
    
    if([self getMode] == QCMultiLabelItemModeLeftRight) {
        self.labelLbl.lim_centerY_parent = self.contentView;
    }else {
        self.labelLbl.lim_top = QCMultiLabelTopSpace;
    }
    
    CGFloat arrowRight = 10.0f;
    self.arrowImgView.lim_left = self.lim_width - arrowRight - self.arrowImgView.lim_width;
    
    

    if([self getMode] == QCMultiLabelItemModeLeftRight) {
        CGFloat valueTop = QCMultiValueTopSpace;
        
        self.valueLbl.lim_centerY_parent = self.contentView;
        self.valueLbl.lim_width = QCMultiValueMaxWidthWithLeftRight;
        [self.valueLbl sizeToFit];
        self.valueLbl.lim_left = self.contentView.lim_width - self.valueLbl.lim_width - 15.0f;
    }else{
        CGFloat valueTop = QCMultiValueTopSpace;
        self.valueLbl.lim_left = self.labelLbl.lim_left;
        self.valueLbl.lim_top = self.labelLbl.lim_bottom + valueTop;
        self.valueLbl.lim_width = QCMultiValueMaxWidth;
        [self.valueLbl sizeToFit];
    }
    
    self.arrowImgView.lim_top = self.valueLbl.lim_top +  ( self.valueLbl.lim_height/2.0f - self.arrowImgView.lim_height/2.0f);
    
}


-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}

+ (CGSize) getTextSize:(NSString*) text maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight fontSize:(CGFloat)fontSize{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:style}];
    CGSize size =  [string boundingRectWithSize:CGSizeMake(maxWidth, maxHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size;
}

@end
