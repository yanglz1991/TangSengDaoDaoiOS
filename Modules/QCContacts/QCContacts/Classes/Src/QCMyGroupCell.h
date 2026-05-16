//
//  QCMyGroupCell.h
//  QCContacts
//
//  Created by tt on 2020/7/16.
//

#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCMyGroupModel : QCFormItemModel
@property(nonatomic,copy) NSString *groupNo;
@property(nonatomic,copy) NSString *name;
@end

@interface QCMyGroupCell : QCFormItemCell

@end


NS_ASSUME_NONNULL_END
