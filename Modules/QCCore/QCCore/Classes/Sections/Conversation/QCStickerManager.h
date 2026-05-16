//
//  QCStickerManager.h
//  QCCore
//
//  Created by tt on 2021/9/27.
//

#import <Foundation/Foundation.h>
#import "QCModel.h"
#import <PromiseKit/PromiseKit.h>
NS_ASSUME_NONNULL_BEGIN

@class QCStickerManager;
@class QCStickerUserCategoryResp;

@protocol QCStickerProvider <NSObject>

// 请求用户的贴图分类列表 应该返回 WKStickerUserCategoryResp对象的集合
-(void) requestUserCategory:(void(^)(NSArray<QCStickerUserCategoryResp*>*data,NSError * __nullable error))callback;

// 请求添加用户的贴图分类
-(void) requestAddStickerCategory:(NSString*)category callback:(void(^)(NSError * __nullable error))callback;

// 移除用户的贴图分类
-(void) requestRemoveStickerCategory:(NSString*)category callback:(void(^)(NSError * __nullable error))callback;

@end

@protocol QCStickerManagerDelegate <NSObject>

@optional

// 用户贴图类别加载完成
-(void) stickerUserCategoryLoadFinished:(QCStickerManager*)manager;

@end

@interface QCStickerManager : NSObject


+ (instancetype _Nonnull )shared;

@property(nonatomic,strong) id<QCStickerProvider> stickerProvider;

// 用户的贴图
@property(nonatomic,copy) NSArray<QCStickerUserCategoryResp*> *stickerUserCategoryResps;

/**
 添加连接委托
 
 @param delegate delegate description
 */
-(void) addDelegate:(id<QCStickerManagerDelegate>) delegate;

/**
 移除连接委托
 
 @param delegate <#delegate description#>
 */
-(void)removeDelegate:(id<QCStickerManagerDelegate>) delegate;
-(void) setupIfNeed;

-(void) loadUserCategory;

/**
 添加贴图
 */
-(void) addStickerWithCategory:(NSString*)category callback:(void(^__nullable)(NSError * __nullable error))callback;

/**
 移除贴图
 */
-(void) removeStickerWithCategory:(NSString*)category callback:(void(^__nullable)(NSError * __nullable error))callback;

@end

@interface QCStickerUserCategoryResp : QCModel

@property(nonatomic,copy) NSString *category;
@property(nonatomic,copy) NSString *cover;
@property(nonatomic,assign) NSNumber *sortNum;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *desc;

@end

NS_ASSUME_NONNULL_END
