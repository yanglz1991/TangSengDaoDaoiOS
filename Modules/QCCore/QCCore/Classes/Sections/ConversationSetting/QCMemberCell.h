//
//  QCMemberCell.h
//  QCCore
//
//  Created by tt on 2022/8/31.
//

#import "QCCell.h"
#import <QCIM/QCIM.h>
#import "QCUserOnlineResp.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMemberCell : QCCell

@property(nonatomic,assign) BOOL edit;

@property(nonatomic,assign) BOOL disable;

@property(nonatomic,copy) void(^onCheck)(BOOL check);

- (void)refresh:(QCChannelMember*)member checkOn:(BOOL)checkOn online:(QCUserOnlineResp*)online;

@end

NS_ASSUME_NONNULL_END
