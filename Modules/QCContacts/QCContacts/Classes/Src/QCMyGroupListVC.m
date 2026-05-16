//
//  QCMyGroupListVC.m
//  QCContacts
//
//  Created by tt on 2020/7/16.
//

#import "QCMyGroupListVC.h"

@interface QCMyGroupListVC ()

@property(nonatomic,strong) UIButton *groupCreateBtn;

@end

@implementation QCMyGroupListVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCMyGroupListVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setRightView:self.groupCreateBtn];
}

- (UIButton *)groupCreateBtn {
    if(!_groupCreateBtn) {
        _groupCreateBtn = [[UIButton alloc] init];
        [_groupCreateBtn setTitle:LLang(@"新建群聊") forState:UIControlStateNormal];
        [_groupCreateBtn setTitleColor:[QCApp shared].config.navBarButtonColor forState:UIControlStateNormal];
        [_groupCreateBtn sizeToFit];
        [_groupCreateBtn addTarget:self action:@selector(groupCreatePressed) forControlEvents:UIControlEventTouchUpInside];
        [[_groupCreateBtn titleLabel] setFont:[[QCApp shared].config appFontOfSize:14.0f]];
    }
    return _groupCreateBtn;
}

-(void) groupCreatePressed {
    QCAppRemoteConfig *rc = [QCApp shared].remoteConfig;
    if(rc && rc.disableGroupMessageOn) {
        NSString *tip = (rc.muteTextOfGroup && rc.muteTextOfGroup.length>0) ? rc.muteTextOfGroup : LLang(@"群聊禁言中");
        [QCAlertUtil alert:tip];
        return;
    }
    [[QCApp shared] invoke:QCPOINT_CONVERSATION_STARTCHAT param:nil];
}

- (NSString *)langTitle {
    
    return LLang(@"保存的群聊");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
        
    QCMyGroupResp *groupResp = self.viewModel.groups[indexPath.row];
    if(groupResp) {
        [[QCChannelSettingManager shared] group:groupResp.groupNo save:NO];
    }
}

@end
