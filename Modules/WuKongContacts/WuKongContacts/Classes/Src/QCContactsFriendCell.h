//
//  QCContactsFriendCell.h
//  WuKongContacts
//
//  Created by tt on 2021/9/22.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@class QCContactsFriendCell;
@class QCContactsFriendModel;

@protocol QCContactsFriendCellDelegate <NSObject>

@optional

-(void) contactsFriendCell:(QCContactsFriendCell*)cell action:(QCContactsFriendModel*)model;

@end

@interface QCContactsFriendModel : QCContactsSelect

@property(nonatomic,copy) NSString *phone;
@property(nonatomic,copy) NSString *vercode;
@property(nonatomic,assign) BOOL isFriend;
@end

@interface QCContactsFriendCell : QCContactsSelectCell

@property(nonatomic,weak) id<QCContactsFriendCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
