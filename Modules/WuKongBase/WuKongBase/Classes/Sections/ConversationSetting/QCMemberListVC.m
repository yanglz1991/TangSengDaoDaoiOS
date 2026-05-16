//
//  QCMemberListVC.m
//  WuKongBase
//
//  Created by tt on 2022/8/31.
//

#import "QCMemberListVC.h"
#import "WuKongBase.h"
#import "QCBarUserSearchView.h"
#import "QCMemberCell.h"
#import <MJRefresh/MJRefresh.h>
//头部视图高度
#define HEAD_VIEW_HEIGHT 50
@interface QCMemberListVC ()<UITableViewDelegate,UITableViewDataSource,QCMemberListVMDelegate>

@property(nonatomic, strong) QCBarUserSearchView *searchBar;

@property(nonatomic,strong) UITableView *tableView;





@end

@implementation QCMemberListVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCMemberListVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    
    self.viewModel.channel = self.channel;
    self.viewModel.hiddenUsers = self.hiddenUsers;
    
    [super viewDidLoad];
    
    self.title = LLang(@"群成员");
    
    [self refreshRightItem];
    
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    
    [self.viewModel didLoad];
   
}


- (QCBarUserSearchView *)searchBar {
    if(!_searchBar) {
        _searchBar = [[QCBarUserSearchView alloc] initWithFrame:CGRectMake(0, self.navigationBar.lim_bottom, QCScreenWidth, HEAD_VIEW_HEIGHT) searchByReturn:true];
        [_searchBar setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
        __weak typeof(self) weakSelf = self;
        [_searchBar setRemoveIconBlock:^(QCBarUserSearchModel *model) {
            QCChannelMember *member = [weakSelf.viewModel memberFromSelecteds:model.sid];
            if(member) {
                [weakSelf.viewModel.selectedMembers removeObject:member];
                [weakSelf.tableView reloadData];
                
                [weakSelf refreshRightItem];
            }
        }];
        [_searchBar setSearchDidChangeBlock:^(NSString *keyword) {
            [weakSelf search:keyword];
        }];
    }
    return _searchBar;
}

-(void) search:(NSString*)keyword {
    [self.tableView.mj_footer setHidden:NO];
    self.viewModel.keyword = keyword;
    [self.viewModel didLoad];
}

-(void) refreshRightItem {
    if(!self.edit) {
        return;
    }
    NSInteger selectCount = [self.viewModel.selectedMembers count];
    if (selectCount > 0) {
        NSString *rightTitle =
        [NSString stringWithFormat:@"%@(%ld)", LLang(@"完成"),
         selectCount];
        [self setRightBarItem:rightTitle
               withDisable:false];
    } else {
        [self setRightBarItem:LLang(@"完成") withDisable:true];
    }
}

- (void) setRightBarItem:(NSString *)title
          withDisable:(BOOL)disable {
    
    if(disable) {
        self.rightView =
        [self barButtonItemWithTitle:title
                          titleColor:[[QCApp shared].config.navBarButtonColor colorWithAlphaComponent:0.5f] action:nil];
    }else {
        self.rightView =
        [self barButtonItemWithTitle:title
                          titleColor:[QCApp shared].config.navBarButtonColor
                              action:@selector(nextBtnPress)];
    }
}

// 下一步点击
-(void) nextBtnPress  {
    NSMutableArray *uids = [NSMutableArray array];
    if(self.viewModel.selectedMembers) {
        for (QCChannelMember *channelMember in self.viewModel.selectedMembers) {
            [uids addObject:channelMember.memberUid];
        }
    }
    if(self.onFinishedSelect) {
        self.onFinishedSelect(uids);
    }
}


//带标题的按钮样式
- (UIButton *)barButtonItemWithTitle:(NSString *)title
                                 titleColor:(UIColor *)titleColor
                                     action:(SEL)selector {
//    UIBarButtonItem *barBtnItem =
//    [UIBarButtonItem itemWithTarget:self
//                             action:selector
//                              title:title
//                         titleColor:titleColor
//                    titleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    return barBtnItem;
    UIButton *barBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [barBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [barBtn setTitle:title forState:UIControlStateNormal];
    [barBtn setTitleColor:titleColor forState:UIControlStateNormal];
//    [barBtn setBackgroundColor:[UIColor redColor]];
    [barBtn sizeToFit];
    return barBtn;
}


#pragma mark - table
-(UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,HEAD_VIEW_HEIGHT+[self visibleRect].origin.y, self.view.lim_width, [self visibleRect].size.height - HEAD_VIEW_HEIGHT) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        UIEdgeInsets separatorInset = _tableView.separatorInset;
        separatorInset.right = 0;
        _tableView.separatorInset = separatorInset;
        _tableView.backgroundColor=[UIColor clearColor];
        _tableView.sectionIndexColor = [UIColor blackColor];
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.sectionHeaderHeight = 0.0f;
        _tableView.sectionFooterHeight = 0.0f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f,  UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom, 0.0f)];

        [_tableView registerClass:QCMemberCell.class forCellReuseIdentifier:[QCMemberCell cellId]];
        
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        __weak typeof(self) weakSelf = self;
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf.tableView.mj_footer beginRefreshing];
            [weakSelf.viewModel didMore:^(BOOL more) {
                [weakSelf.tableView.mj_footer endRefreshing];
                if(!more) {
                    [weakSelf.tableView.mj_footer setHidden:YES];
                }
            }];
        }];
        footer.refreshingTitleHidden = YES;
        footer.stateLabel.hidden  = YES;
        _tableView.mj_footer = footer;
    }
    return _tableView;
}

-(BOOL) isDisable:(NSString*)uid {
    if(!self.disableUsers) {
        return false;
    }
    return [self.disableUsers containsObject:uid];
}

#pragma mark -- UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.viewModel.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.viewModel.items[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  70.0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 20.0f;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSString *title = [self.viewModel.headerTitles objectAtIndex:section];
    return [self headView:title headHeight:20.0f color:[UIColor grayColor]];
}


// 头部字母部分
-(UIView*) headView:(NSString*)title headHeight:(CGFloat)headHheght color:(UIColor*)color{
    
    UIView *headView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, QCScreenWidth, headHheght)];
    [headView setBackgroundColor: [QCApp shared].config.backgroundColor];
    UILabel  *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, headView.lim_width, headView.lim_height)];
    [titleLbl setFont:[[QCApp shared].config appFontOfSize:14.0f]];
    [titleLbl setTextColor:color];
    [titleLbl setText:title];
    [headView addSubview:titleLbl];
    return headView;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QCChannelMember *model =  self.viewModel.items[indexPath.section][indexPath.row];
    QCMemberCell *cell =  [tableView dequeueReusableCellWithIdentifier:[QCMemberCell cellId]];
    cell.edit = self.edit;
    cell.disable = [self isDisable:model.memberUid];
    QCUserOnlineResp *onlineResp = [self.viewModel onlineMember:model.memberUid];
    [cell refresh:model checkOn:[self.viewModel isChecked:model] online:onlineResp];
    __weak typeof(self) weakSelf = self;
    [cell setOnCheck:^(BOOL check) {
        [weakSelf makeChecked:model];
    }];
    return cell;
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QCChannelMember *member =  self.viewModel.items[indexPath.section][indexPath.row];
    if(self.edit) {
        if([self isDisable:member.memberUid]) {
            return;
        }
        self.searchBar.searchFd.text = @"";
        [self search:@""];
        [self makeChecked:member];
        [self.tableView reloadData];
        return;
    }
    
   
    
    NSString *vercode = @"";
    if(member && member.extra && member.extra[@"vercode"]) {
        vercode = member.extra[@"vercode"];
    }
    [[QCApp shared] invoke:QCPOINT_USER_INFO param:@{
        @"channel":self.channel,
        @"uid": member.memberUid?:@"",
        @"vercode": vercode,
    }];
    
}

-(void)makeChecked:(QCChannelMember*)member {
    [self.viewModel makeChecked:member];
    QCBarUserSearchModel *searchModel = [[QCBarUserSearchModel alloc] initWithSid:member.memberUid];
    searchModel.icon = [[QCApp shared] getImageFullUrl:member.memberAvatar].absoluteString;
    if([self.viewModel isChecked:member]) {
       
        [self.searchBar addModel:searchModel];
    }else{
        [self.searchBar removeModel:searchModel];
    }
    
    [self refreshRightItem];
}

#pragma mark -- QCMemberListVMDelegate

- (void)reload {
    [self.tableView reloadData];
}


@end
