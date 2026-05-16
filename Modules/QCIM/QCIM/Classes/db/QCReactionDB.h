//
//  QCReactionDB.h
//  QCIM
//
//  Created by tt on 2021/9/13.
//

#import <Foundation/Foundation.h>
#import <fmdb/FMDB.h>
#import "QCReaction.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCReactionDB : NSObject

+ (QCReactionDB *)shared;


/**
 获取某个消息的回应
 */
-(NSArray<QCReaction*>*) getReactions:(NSArray<NSNumber*>*) messageIDs;

/**
  获取以消息ID为key 回应集合为值的字典
 */
-(  NSDictionary<NSString*,NSArray<QCReaction*>*> *) getReactionDictionary:(NSArray<NSNumber*>*) messageIDs;


/**
 插入回应
 */
-(BOOL) insertOrUpdateReactions:(NSArray<QCReaction*>*)reactions;

-(BOOL) insertOrUpdateReactions:(NSArray<QCReaction*>*)reactions db:(FMDatabase*)db;

/**
 获取某个频道的最大版本号
 */
-(uint64_t) maxVersion:(QCChannel*) channel;

@end

NS_ASSUME_NONNULL_END
