//
//  QCContactsFriendRequestCell.h
//  WuKongContacts
//
//  Created by tt on 2020/1/5.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCContactsFriendRequestCell : QCCell

@property(nonatomic,assign) BOOL last;
@property(nonatomic,assign) BOOL first;

-(void)refresh:(QCFriendRequestDBModel*)model;


/**
 确认通过好友
 */
@property(nonatomic,copy) void(^onPass)(QCFriendRequestDBModel*model);

@end

NS_ASSUME_NONNULL_END
