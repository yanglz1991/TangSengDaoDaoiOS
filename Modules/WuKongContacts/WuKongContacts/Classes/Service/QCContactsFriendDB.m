//
//  QCContactsFriendDB.m
//  WuKongContacts
//
//  Created by tt on 2021/9/22.
//

#import "QCContactsFriendDB.h"

@implementation QCContactsFriendDBModel


@end

@implementation QCContactsFriendDB


static QCContactsFriendDB *_instance = nil;
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone ];
    });
    return _instance;
}

+(instancetype) shared{
    if (_instance == nil) {
        _instance = [[super alloc]init];
    }
    return _instance;
}


-(NSArray<QCContactsFriendDBModel*>*) queryAll {
    NSMutableArray<QCContactsFriendDBModel*> *items = [NSMutableArray array];
    [[QCKitDB shared].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"select * from contacts_friend"];
        while (resultSet.next) {
            QCContactsFriendDBModel *model = [QCContactsFriendDBModel new];
            model.name = [resultSet stringForColumn:@"name"];
            model.phone = [resultSet stringForColumn:@"phone"];
            [items addObject:model];
        }
        [resultSet close];
    }];
    return items;
}


-(void) save:(NSArray<QCContactsFriendDBModel*>*) models {
    if(!models || models.count==0) {
        return;
    }
    [[QCKitDB shared].dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if(models && models.count>0) {
            for (QCContactsFriendDBModel *model in models) {
                [db executeUpdate:@"update contacts_friend set name=?,phone=?",model.name,model.phone];
            }
        }
    }];
}


@end
