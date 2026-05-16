//
//  QCFormSection.m
//  WuKongBase
//
//  Created by tt on 2020/1/21.
//

#import "QCFormSection.h"

@implementation QCFormSection

+(instancetype) withItems:(NSArray<QCFormItemModel*>*)items height:(CGFloat)height {
    return [QCFormSection withItems:items height:height headView:nil];
}
+(instancetype) withItems:(NSArray<QCFormItemModel*>*)items height:(CGFloat)height headView:(UIView*)headView{
    QCFormSection *section = [QCFormSection new];
    section.items = items;
    section.height = height;
    section.headView = headView;
    return section;
}

@end
