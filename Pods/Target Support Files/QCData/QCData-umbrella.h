#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "QCChannelDataManagerDelegateImp.h"
#import "QCDataSourceModel.h"
#import "QCDataSourceModule.h"
#import "QCFileDownloadTask.h"
#import "QCFileUploadTask.h"
#import "QCGroupManagerDelegateImp.h"
#import "QCMessageManagerDelegateImp.h"

FOUNDATION_EXPORT double QCDataVersionNumber;
FOUNDATION_EXPORT const unsigned char QCDataVersionString[];

