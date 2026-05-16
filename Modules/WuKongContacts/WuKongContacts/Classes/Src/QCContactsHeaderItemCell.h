//
//  QCContactsHeaderItemCell.h
//  WuKongContacts
//
//  Created by tt on 2020/1/4.
//

#import <UIKit/UIKit.h>
#import "QCContactsHeaderItem.h"
#import <WuKongBase/WuKongBase.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCContactsHeaderItemCell : QCCell

-(void)refresh:(QCContactsHeaderItem*)model;

@end

NS_ASSUME_NONNULL_END
