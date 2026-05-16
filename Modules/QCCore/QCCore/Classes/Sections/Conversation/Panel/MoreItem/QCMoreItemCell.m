//
//  QCMoreItem.m
//  QCCore
//
//  Created by tt on 2020/1/12.
//

#import "QCMoreItemCell.h"

@interface QCMoreItemCell ()


@end

@implementation QCMoreItemCell

+(NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

-(void) refresh:(QCMoreItemModel*)model{
    
}

@end
