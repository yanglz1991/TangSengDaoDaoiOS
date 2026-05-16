//
//  QCConversationListVC.h
//  WuKongBase
//
//  Created by tt on 2019/12/15.
//

#import <UIKit/UIKit.h>
#import "QCBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCConversationListVC : QCBaseVC

-(instancetype) initWithTitle:(NSString*)title;

-(void) setCustomTitle:(NSString*)title;
@end

NS_ASSUME_NONNULL_END
