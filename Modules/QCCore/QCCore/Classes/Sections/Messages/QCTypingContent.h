//
//  QCTypingContent.h
//  QCCore
//
//  Created by tt on 2020/8/13.
//

#import <QCIM/QCIM.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCTypingContent : QCMessageContent

@property(nonatomic,copy) NSString *typingUID; // 输入者UID
@property(nonatomic,copy) NSString *typingName; // 输入者名称

@end

NS_ASSUME_NONNULL_END
