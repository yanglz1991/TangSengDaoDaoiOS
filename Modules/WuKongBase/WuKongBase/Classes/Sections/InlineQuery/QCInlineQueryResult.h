//
//  QCInlineQueryResult.h
//  WuKongBase
//
//  Created by tt on 2021/11/9.
//

#import <Foundation/Foundation.h>
#import "WuKongBase.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCInlineQueryResult : QCModel

@property(nonatomic,copy) NSString *id;
@property(nonatomic,copy) NSString *inlineQuerySid;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,strong) NSArray *results;
@property(nonatomic,copy) NSString *nextOffset;

@end

@interface QCGifResult : QCModel

@property(nonatomic,copy) NSString *url;
@property(nonatomic,assign) NSInteger width;
@property(nonatomic,assign) NSInteger height;

@end

NS_ASSUME_NONNULL_END
