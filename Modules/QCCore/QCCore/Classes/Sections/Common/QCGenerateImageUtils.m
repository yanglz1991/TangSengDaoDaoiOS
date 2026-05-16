//
//  QCGenerateImageUtils.m
//  QCCore
//
//  Created by tt on 2022/6/21.
//

#import "QCGenerateImageUtils.h"
#import  <QCCore/QCCore-Swift.h>
@implementation QCGenerateImageUtils


+ (UIImage * _Nullable)generateTintedImgWithImage:(UIImage * _Nullable)image color:(UIColor * _Nonnull)color backgroundColor:(UIColor * _Nullable)backgroundColor  {
    return  [GenerateImageUtils generateTintedImgWithImage:image color:color backgroundColor:backgroundColor];
}

@end
