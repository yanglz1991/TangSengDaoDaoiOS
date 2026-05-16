//
//  QCSDImageLottieCoder.m
//  WuKongBase
//
//  Created by tt on 2021/9/27.
//

#import "QCSDImageLottieCoder.h"
#import <GZIP/GZIP.h>

@implementation QCSDImageLottieCoder

- (instancetype)initWithAnimatedImageData:(NSData *)data options:(SDImageCoderOptions *)options {
    BOOL isgzip =  [data isGzippedData];
    if(isgzip) {
        data = [data gunzippedData];
    }
    return [super initWithAnimatedImageData:data options:options];
}

+ (QCSDImageLottieCoder *)sharedCoder {
    static dispatch_once_t onceToken;
    static QCSDImageLottieCoder *coder;
    dispatch_once(&onceToken, ^{
        coder = [[QCSDImageLottieCoder alloc] init];
    });
    return coder;
}

- (BOOL)canDecodeFromData:(NSData *)data {
    if(!data) {
        return nil;
    }
   BOOL isgzip =  [data isGzippedData];
    if(isgzip) {
        return isgzip;
    }
    return [super canDecodeFromData:data];
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(SDImageCoderOptions *)options {
    if(!data) {
        return nil;
    }
    BOOL isgzip =  [data isGzippedData];
     if(isgzip) {
         data = [data gunzippedData];
     }
    if(!data) {
        return nil;
    }
    return [super decodedImageWithData:data options:options];
}

@end
