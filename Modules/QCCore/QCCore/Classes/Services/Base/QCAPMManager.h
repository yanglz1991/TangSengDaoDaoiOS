//
//  QCAPMManager.h
//  QCCore
//
//  Created by tt on 2022/5/6.
//

#import <Foundation/Foundation.h>
#import "QCFuncGroupEditItemModel.h"
@class QCAPMManager;
NS_ASSUME_NONNULL_BEGIN

@interface QCAPMSortInfo : NSObject // apm应用排序信息
@property(nonatomic,copy) NSString *apmID;
@property(nonatomic,assign) NSInteger sort;
@property(nonatomic,assign) BOOL disable;
@property(nonatomic,assign) QCFuncGroupEditItemType type; // 区域 0. 个人收藏 1.更多app

@end

@protocol QCAPMManagerDelegate <NSObject>

@optional

-(void) apmManagerSortInfoChange:(QCAPMManager*)manager; // 排序信息发生改变

@end

@interface QCAPMManager : NSObject

@property(nonatomic,strong) NSArray<QCAPMSortInfo*> *apmSorts;

+ (QCAPMManager *)shared;


-(void) saveAPMSorts;

-(void) addDelegate:(id<QCAPMManagerDelegate>) delegate;

-(void) removeDelegate:(id<QCAPMManagerDelegate>) delegate;

@end

NS_ASSUME_NONNULL_END
