//
//  NIMKitMediaFetcher.h
//  NIMKit
//
//  Created by chris on 2016/11/12.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

typedef void(^QCLibraryFetchResult)(UIImage *img,NSString *path,bool isSelectOriginalPhoto, PHAssetMediaType type,NSInteger left);

typedef void(^QCCameraFetchResult)(NSString *path, UIImage *image);

@interface QCMediaFetcher : NSObject

@property (nonatomic,assign) NSInteger limit;

@property (nonatomic,strong) NSArray *mediaTypes; //kUTTypeMovie,kUTTypeImage

// 默认为YES，如果设置为NO, 用户将不能拍摄照片
@property (nonatomic, assign) BOOL allowTakePicture;

- (void)fetchPhotoFromLibrary:(QCLibraryFetchResult)result cancel:(void(^)(void))cancel;

- (void)fetchPhotoFromLibrary:(QCLibraryFetchResult)result;

/**
  提取多媒体文件（包含压缩）
 */
- (void)fetchPhotoFromLibraryOfCompress:(void(^)(NSData *imageData,NSString *path,bool isSelectOriginalPhoto, PHAssetMediaType type,NSInteger left))result cancel:(void (^)(void))cancel;

- (void)fetchMediaFromCamera:(QCCameraFetchResult)result;

@end
