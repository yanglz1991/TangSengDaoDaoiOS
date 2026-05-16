//
//  QCContacts.m
//  QCCore
//
//  Created by tt on 2019/12/8.
//

#import "QCContacts.h"

@implementation QCContacts

- (NSString *)displayName {
    if(_displayName) {
        return _displayName;
    }
    return self.name;
}

@end


