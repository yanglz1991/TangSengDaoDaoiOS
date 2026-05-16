//
//  QCOfficialTag.m
//  WuKongBase
//
//  Created by tt on 2020/9/15.
//

#import "QCOfficialTag.h"
#import "QCApp.h"
@implementation QCOfficialTag

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0.0f, 0.0f, 18.0f, 18.0f);
    }
    return self;
}


-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}
@end
