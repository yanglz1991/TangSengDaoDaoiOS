//
//  QCStickerBigViewModal.h
//  QCCore
//
//  Created by tt on 2021/10/20.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImage.h>
#import "QCStickerPackage.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCStickerBigViewModal : NSObject

@property(nonatomic,strong) NSString *path;

+(QCStickerBigViewModal*) focusedView:(UIView*)focusedView sticker:(QCSticker*)sticker;

-(void) presentOnWindow:(UIWindow*)window;

@end

NS_ASSUME_NONNULL_END
