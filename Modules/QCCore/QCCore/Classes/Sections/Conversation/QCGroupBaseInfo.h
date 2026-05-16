//
//  QCGroupBaseInfo.h
//  QCCore
//
//  Created by tt on 2022/8/31.
//

#import <Foundation/Foundation.h>
#import <QCIM/QCIM.h>
#import "QCModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCGroupBaseInfo : QCModel

@property(nonatomic,assign) BOOL quit; // 是否已退出

@property(nonatomic,assign) NSInteger memberCount; // 成员总数量

@property(nonatomic,assign) NSInteger onlineCount; // 在线成员数量

@property(nonatomic,assign) QCMemberRole role; // 成员角色

@end

NS_ASSUME_NONNULL_END
