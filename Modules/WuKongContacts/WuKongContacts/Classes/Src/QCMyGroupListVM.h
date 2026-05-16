//
//  QCMyGroupListVM.h
//  WuKongContacts
//
//  Created by tt on 2020/7/16.
//

#import <WuKongBase/WuKongBase.h>
@class QCMyGroupResp;
NS_ASSUME_NONNULL_BEGIN

@interface QCMyGroupListVM : QCBaseTableVM

@property(nonatomic,strong) NSArray<QCMyGroupResp*>* groups;

@end

@interface QCMyGroupResp : QCModel

@property(nonatomic,copy) NSString *groupNo;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *remark;
@property(nonatomic,copy,readonly) NSString *displayName;



@end

NS_ASSUME_NONNULL_END
