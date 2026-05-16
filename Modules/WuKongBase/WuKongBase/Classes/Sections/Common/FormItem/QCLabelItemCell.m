//
//  QCLabelItemCell.m
//  WuKongBase
//
//  Created by tt on 2020/1/21.
//

#import "QCLabelItemCell.h"
#import "QCResource.h"
#import "QCApp.h"
#import "UIView+WK.h"
#import "QCConstant.h"

@interface QCLabelItemModel ()

@end

@implementation QCLabelItemModel

+(instancetype) initWith:(NSString*)label value:(NSString*) value onClick:(void(^)(QCFormItemModel* model,NSIndexPath *indexPath))onClick {
    QCLabelItemModel *model = [QCLabelItemModel new];
    model.label = label;
    model.value = value;
    model.onClick = onClick;
    return model;
}

+(instancetype) initWith:(NSString*)label value:(NSString*) value {
    ;
    return [self initWith:label value:value];
}

- (Class)cell {
    return QCLabelItemCell.class;
}

- (UIFont *)valueFont {
    if(!_valueFont) {
        _valueFont =[[QCApp shared].config appFontOfSize:16.0f];
    }
    return _valueFont;
}

@end


@interface QCLabelItemCell ()


@end

@implementation QCLabelItemCell

- (void)setupUI {
    [super setupUI];
  
    self.valueLbl = [[QCCopyLabel alloc] init];
    self.valueLbl.textAlignment = NSTextAlignmentRight;
    [self.valueLbl setTextColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f]];
    
    [self.valueView addSubview:self.valueLbl];
}

- (void)refresh:(QCLabelItemModel *)model {
    [super refresh:model];
    
    [self.valueLbl setFont:model.valueFont];
    self.valueLbl.text = model.value;
    self.valueLbl.copyEnabled = model.valueCopy;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.valueLbl.lim_size = self.valueView.lim_size;
    
}

@end
