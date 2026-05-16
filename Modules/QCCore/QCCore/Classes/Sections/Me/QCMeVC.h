//
//  QCMeVC2.h
//  QCCore
//
//  Created by tt on 2020/6/9.
//

#import <QCCore/QCCore.h>
#import "QCMeVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMeVC : QCBaseTableVC<QCMeVM*>

@end

@interface WKeHeader : UIView
-(void) reloadData;
@end


NS_ASSUME_NONNULL_END
