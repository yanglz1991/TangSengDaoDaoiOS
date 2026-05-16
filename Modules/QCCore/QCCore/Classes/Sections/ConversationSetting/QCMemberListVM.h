//
//  QCMemberListVM.h
//  QCCore
//
//  Created by tt on 2022/8/31.
//

#import "QCBaseVM.h"
#import "QCContactsSelectVC.h"
#import <QCIM/QCIM.h>
#import "QCUserOnlineResp.h"
NS_ASSUME_NONNULL_BEGIN

@protocol QCMemberListVMDelegate <NSObject>

-(void) reload;

@end

@interface QCMemberListVM : QCBaseVM

@property(nonatomic,weak) id<QCMemberListVMDelegate> delegate;

@property(nonatomic,strong) QCChannel *channel;
@property(nonatomic,strong) NSArray<NSString*> *headerTitles;
@property(nonatomic,strong) NSArray<NSArray<QCChannelMember*>*> *items;

@property(nonatomic,strong) NSMutableSet<QCChannelMember*> *selectedMembers; // 被选中的成员

@property(nonatomic,copy) NSString *keyword;

@property(nonatomic,assign) BOOL loading;

@property(nonatomic,assign) BOOL showSelf; // 是否显示自己
@property(nonatomic,strong) NSArray<NSString*> *hiddenUsers; // 不显示的用户

@property(nonatomic,strong) NSMutableArray<QCUserOnlineResp*> *onlineMembers; // 在线成员

-(void) didLoad;

-(void) didMore:(void(^)(BOOL more))moreBlock;

-(BOOL) isChecked:(QCChannelMember*)member;

-(void) makeChecked:(QCChannelMember*)member;

-(QCChannelMember*) memberFromSelecteds:(NSString*)uid;

-(QCUserOnlineResp*) onlineMember:(NSString*)uid;

@end

NS_ASSUME_NONNULL_END
