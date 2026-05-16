//
//  QCContactsVC.h
//  QCContacts
//
//  Created by tt on 2019/12/7.
//

#import <UIKit/UIKit.h>
#import <QCCore/QCCore.h>
#import "QCContacts.h"
NS_ASSUME_NONNULL_BEGIN

@protocol QCContactsDelegate <NSObject>

-(NSArray<QCContacts*>*) contactsData;

@end

@interface QCContactsVC : QCBaseVC

@property(nonatomic,weak) id<QCContactsDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
