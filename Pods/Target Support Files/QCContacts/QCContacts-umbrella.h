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

#import "QCContactsModule.h"
#import "QCContactsFriendDB.h"
#import "QCContactsSync.h"
#import "QCContactsAddFunctionItemCell.h"
#import "QCContactsAddMyShortCell.h"
#import "QCContactsAddVC.h"
#import "QCContactsCell.h"
#import "QCContactsFriendCell.h"
#import "QCContactsFriendRequestCell.h"
#import "QCContactsFriendRequestVC.h"
#import "QCContactsFriendVC.h"
#import "QCContactsFriendVM.h"
#import "QCContactsHeaderItemCell.h"
#import "QCContactsInfoVC.h"
#import "QCContactsInfoVM.h"
#import "QCContactsSearchVC.h"
#import "QCContactsVC.h"
#import "QCContactsVM.h"
#import "QCMyGroupCell.h"
#import "QCMyGroupListVC.h"
#import "QCMyGroupListVM.h"

FOUNDATION_EXPORT double QCContactsVersionNumber;
FOUNDATION_EXPORT const unsigned char QCContactsVersionString[];

