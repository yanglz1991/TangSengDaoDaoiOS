//
//  QCFilePreviewVC.h
//  WuKongFile
//
//  Created by tt on 2020/7/16.
//

#import <WuKongBase/WuKongBase.h>
#import <QuickLook/QuickLook.h>
NS_ASSUME_NONNULL_BEGIN
@interface QCPreviewFileItem : NSObject <QLPreviewItem>

@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong) NSURL *url;

@end

@interface QCFilePreviewVC : QLPreviewController
@property(nonatomic, copy) NSString *fileName;

@property(nonatomic, strong) NSURL *url;
@end

NS_ASSUME_NONNULL_END
