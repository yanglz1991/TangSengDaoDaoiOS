//
//  QCLottieStickerContent.h
//  QCCore
//
//  Created by tt on 2021/8/26.
//

#import <QCIM/QCIM.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCLottieStickerContent : QCMessageContent

@property(nonatomic,copy) NSString *url; // lottie贴图地址

@property(nonatomic,copy) NSString *category; // 贴图类别
@property(nonatomic,copy) NSString *placeholder;

@property(nonatomic,copy) NSString *format;

@end

NS_ASSUME_NONNULL_END
