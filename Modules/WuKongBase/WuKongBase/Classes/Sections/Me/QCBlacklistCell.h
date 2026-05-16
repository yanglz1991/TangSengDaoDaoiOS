//
//  QCBlacklistCell.h
//  WuKongBase
//
//  Created by tt on 2020/6/26.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCBlacklistModel : NSObject
@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *name;

@end

@interface QCBlacklistCell : QCCell

@end

NS_ASSUME_NONNULL_END
