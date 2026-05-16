//
//  QCRobot.h
//  QCIM
//
//  Created by tt on 2021/10/19.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    QCRobotStatusDisable,
    QCRobotStatusEnable,
} QCRobotStatus;

@class QCRobotMenus;
NS_ASSUME_NONNULL_BEGIN

@interface QCRobot : NSObject

@property (nonatomic, copy) NSString *robotID;

@property (nonatomic, copy) NSString *username; // 机器人username

@property (nonatomic, assign) long version;

@property(nonatomic,assign) QCRobotStatus status;

@property(nonatomic,assign) BOOL inlineOn; // 是否支持行内搜索
@property(nonatomic,copy) NSString *placeholder; // 如果支持行内搜索 则占位字符内容

@property (nonatomic, strong) NSArray<QCRobotMenus*> *menus;

@end

@interface QCRobotMenus : NSObject
@property (nonatomic, copy) NSString *robotID;
@property (nonatomic, copy) NSString *cmd;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
