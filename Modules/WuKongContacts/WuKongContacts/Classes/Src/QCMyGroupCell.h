//
//  QCMyGroupCell.h
//  WuKongContacts
//
//  Created by tt on 2020/7/16.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCMyGroupModel : QCFormItemModel
@property(nonatomic,copy) NSString *groupNo;
@property(nonatomic,copy) NSString *name;
@end

@interface QCMyGroupCell : QCFormItemCell

@end


NS_ASSUME_NONNULL_END
