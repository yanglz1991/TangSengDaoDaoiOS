//
//  QCContactsFriendRequestVC.m
//  QCContacts
//
//  Created by tt on 2020/1/5.
//

#import "QCContactsFriendRequestVC.h"
#import "QCContactsFriendRequestCell.h"
#import "QCContactsSync.h"
@interface QCContactsFriendRequestVC ()<UITableViewDataSource,UITableViewDelegate,QCContactsManagerDelegate>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray<QCFriendRequestDBModel*> *items;
@property(nonatomic,strong) UIButton *addFriendBtn;

@end

@implementation QCContactsFriendRequestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.items =  [NSMutableArray arrayWithArray:[[QCContactsManager shared] getAllFriendRequest]];
    self.rightView = self.addFriendBtn;
    
    [[QCContactsManager shared] addDelegate:self];
}

- (void)dealloc{
    [[QCContactsManager shared] removeDelegate:self];
}

- (NSString *)langTitle {
    return LLang(@"新的朋友");
}

// 右上角更多按钮
-(UIButton*) addFriendBtn {
    if(!_addFriendBtn) {
        _addFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addFriendBtn addTarget:self action:@selector(addFriendPressed) forControlEvents:UIControlEventTouchUpInside];
        _addFriendBtn.frame = CGRectMake(0 , 0, 110, 44);
        [_addFriendBtn setTitle:LLang(@"添加朋友") forState:UIControlStateNormal];
        [[_addFriendBtn titleLabel] setFont:[[QCApp shared].config appFontOfSize:15.0f]];
        [_addFriendBtn setTitleColor:[QCApp shared].config.navBarButtonColor forState:UIControlStateNormal];
//       _moreButtonItem =[[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _addFriendBtn;
}

-(void) addFriendPressed {
    [[QCApp shared] invoke:QCPOINT_CONVERSATION_ADDCONTACTS param:nil];
}

// 确认邀请
-(void) requestFriendSure:(QCFriendRequestDBModel*)model {
    __weak typeof(self) weakSelf = self;
    [[QCAPIClient sharedClient] POST:@"friend/sure" parameters:@{@"token":model.token}].then(^(){
        // 更新状态
        [[QCContactsManager shared] updateFriendRequestStatus:model.uid status:QCFriendRequestStatusSured];
        [weakSelf startSyncContacts:model.uid];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }).catch(^(NSError *err){
        [weakSelf.view showMsg:err.domain];
    });
}

// 开始同步联系人
-(void) startSyncContacts:(NSString*)uid {
    [[[QCContactsSync alloc] init] sync:^(NSError *error) {
        [[QCSDK shared].channelManager fetchChannelInfo:[QCChannel personWithChannelID:uid]];
    }];
}

#pragma mark - table
-(UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:[self visibleRect]];
        [_tableView setBackgroundColor:[UIColor redColor]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        UIEdgeInsets separatorInset   = _tableView.separatorInset;
        separatorInset.right          = 0;
        _tableView.separatorInset = separatorInset;
        _tableView.backgroundColor=[UIColor clearColor];
        
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerClass:QCContactsFriendRequestCell.class forCellReuseIdentifier:[QCContactsFriendRequestCell cellId]];
        
    }
    return _tableView;
}

- (void)viewConfigChange:(QCViewConfigChangeType)type {
    [super viewConfigChange:type];
    if(type == QCViewConfigChangeTypeStyle) {
        [self.addFriendBtn setTitleColor:[QCApp shared].config.defaultTextColor forState:UIControlStateNormal];
    }
}

#pragma mark -- QCContactsManagerDelegate

-(void) contactsManager:(QCContactsManager*)manager lastFriendRequest:(QCFriendRequestDBModel*)friendRequestDBModel {
    self.items =  [NSMutableArray arrayWithArray: [[QCContactsManager shared] getAllFriendRequest]];
    [self.tableView reloadData];
}

-(void) contactsManager:(QCContactsManager *)manager friendAccepted:(NSDictionary*)param {
    NSString *toUID = param[@"to_uid"];
    if(!toUID || [toUID isEqualToString:@""]) {
        return;
    }
    self.items =  [NSMutableArray arrayWithArray:[[QCContactsManager shared] getAllFriendRequest]];
    for (QCFriendRequestDBModel *model in self.items) {
        if([model.uid isEqualToString:toUID]) {
            model.status = QCFriendRequestStatusSured;
            model.readed = 1;
        }
    }
    [self.tableView reloadData];
    
}


#pragma mark - UITableViewDataSource,UITableViewDelegate

#pragma mark UITableDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.items.count;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QCFriendRequestDBModel *model = self.items[indexPath.row];
    QCContactsFriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:[QCContactsFriendRequestCell cellId]];
    cell.first = indexPath.row == 0;
    cell.last = self.items.count-1 == indexPath.row;
    __weak typeof(self) weakSelf = self;
    [cell setOnPass:^(QCFriendRequestDBModel * _Nonnull model) {
        [weakSelf requestFriendSure:model];
    }];
    [cell refresh:model];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  80.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        QCFriendRequestDBModel *model = self.items[indexPath.row];
        [[QCFriendRequestDB shared] deleteFriendRequest:model.uid];
        [self.items removeObject:model];
        [self.tableView reloadData];
        
    }
}

@end
