//
//  QCMentionUserCell.h
//  QCCore
//
//  Created by tt on 2021/11/3.
//

#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCMentionUserCellModel : QCFormItemModel

@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,strong) NSURL *avatarURL;
@property(nonatomic,assign) BOOL robot;

+(instancetype) uid:(NSString*)uid name:(NSString*)name avatarURL:(NSURL * __nullable)avatarURL robot:(BOOL)robot;
+(instancetype) uid:(NSString*)uid name:(NSString*)name;

@end

@interface QCMentionUserCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
