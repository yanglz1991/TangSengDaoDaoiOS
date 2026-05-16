//
//  QCMeVC2.h
//  WuKongBase
//
//  Created by tt on 2020/6/9.
//

#import <WuKongBase/WuKongBase.h>
#import "QCMeVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMeVC : QCBaseTableVC<QCMeVM*>

@end

@interface WKeHeader : UIView
-(void) reloadData;
@end


NS_ASSUME_NONNULL_END
