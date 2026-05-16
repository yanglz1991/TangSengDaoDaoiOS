//
//  QCTouchTableView.m
//  WuKongMoment
//
//  Created by tt on 2020/11/18.
//

#import "QCTouchTableView.h"

@implementation QCTouchTableView


-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if ([_touchTableViewDelegate conformsToProtocol:@protocol(QCTouchTableViewDelegate)] &&
        [_touchTableViewDelegate respondsToSelector:@selector(tableView:touchesBegan:withEvent:)]){
        [_touchTableViewDelegate tableView:self touchesBegan:touches withEvent:event];
    }
}


@end
