//
//  QCTimeHeaderView.h
//  QCCore
//
//  Created by tt on 2021/7/26.
//

#import <UIKit/UIKit.h>
#import "QCCore.h"
#import "QCTipLabel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCTimeHeaderView : UITableViewHeaderFooterView
@property(nonatomic,strong) QCTipLabel *dateLbl;

+(CGFloat) height;

+(NSString*) reuseId;

@end

NS_ASSUME_NONNULL_END
