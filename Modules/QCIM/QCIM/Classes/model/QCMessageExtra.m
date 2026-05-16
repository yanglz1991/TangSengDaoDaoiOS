//
//  QCMessageExtra.m
//  QCIM
//
//  Created by tt on 2022/4/12.
//

#import "QCMessageExtra.h"

@implementation QCMessageExtra

- (BOOL)isEdit {
    if(self.editedAt>0) {
        return true;
    }
    return false;
}

@end
