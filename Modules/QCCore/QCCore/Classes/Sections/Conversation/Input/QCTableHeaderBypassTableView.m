//
//  QCTableHeaderBypassTableView.m
//  QCCore
//
//  Created by tt on 2021/11/3.
//

#import "QCTableHeaderBypassTableView.h"

@implementation QCTableHeaderBypassTableView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
   UIView *hitTest = [super hitTest:point withEvent:event];
    if([hitTest isDescendantOfView:self.tableHeaderView]) {
        return nil;
    }
    return hitTest;
}

@end
