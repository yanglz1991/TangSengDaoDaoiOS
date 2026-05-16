//
//  QCUserAvatar.h
//  QCCore
//
//  Created by tt on 2020/6/19.
//

#import <UIKit/UIKit.h>
#import "QCImageView.h"

#define QCDefaultAvatarSize CGSizeMake(50.0f,50.0f)

NS_ASSUME_NONNULL_BEGIN

@interface QCUserAvatar : UIView

@property(nonatomic,copy) NSString *url;

@property(nonatomic,copy) NSString *uid;

@property(nonatomic,assign) CGFloat borderWidth;

@property(nonatomic,strong) QCImageView *avatarImgView;


@end

NS_ASSUME_NONNULL_END
