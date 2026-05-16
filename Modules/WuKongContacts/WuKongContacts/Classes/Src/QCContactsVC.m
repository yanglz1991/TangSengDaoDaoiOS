//
//  QCContactsVC.m
//  WuKongContacts
//
//  Created by tt on 2019/12/7.
//

#import "QCContactsVC.h"
#import "QCContactsCell.h"
#import <Masonry/Masonry.h>
#import "QCChineseSort.h"
#import "QCContactsHeaderItemCell.h"
#import "QCContactsManager.h"
#import "QCContactsSync.h"
#import "QCAvatarUtil.h"
#import "QCSearchbarView.h"
#import "QCGlobalSearchResultController.h"

@interface QCContactsVC ()<UITableViewDataSource,UITableViewDelegate,QCContactsManagerDelegate,QCChannelManagerDelegate>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *sectionTitleArr; //排序后的出现过的拼音首字母数组
@property(nonatomic,strong) NSMutableArray<NSMutableArray*> *items;
@property(nonatomic,strong) UILabel *titleLbl;
@property(nonatomic,strong) QCSearchbarView *searchbarView;
@property(nonatomic,strong) UIView *tableHeader;

@property(nonatomic,strong) UILabel *contactsCountLbl; // 联系人数量

@end

@implementation QCContactsVC

-(instancetype) init {
    self = [super init];
    if(self) {
        [[QCContactsManager shared] addDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTaBarItemBadgeValue) name:WK_NOTIFY_CONTACTS_TAB_REDDOT_UPDATE object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [NSMutableArray array];
    // Do any additional setup after loading the view.
    
    self.navigationBar.title = LLang(@"联系人");
    [self requestData];
    
    [[QCSDK shared].channelManager addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsUpdate:) name:WK_NOTIFY_CONTACTS_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContactsHeader) name:WK_NOTIFY_CONTACTS_HEADER_UPDATE object:nil];
   
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationBar.title = LLang(@"联系人");
    [self.tableView reloadData]; // 视图展示时刷新table（主要是刷新离线时间）
}



- (void)dealloc {
    NSLog(@"QCContactsVC dealloc...");
    [[QCSDK shared].channelManager removeDelegate:self];
    [[QCContactsManager shared] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WK_NOTIFY_CONTACTS_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WK_NOTIFY_CONTACTS_HEADER_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WK_NOTIFY_CONTACTS_TAB_REDDOT_UPDATE object:nil];
}

// 开启大标题模式
- (BOOL)largeTitle {
    return true;
}

- (QCSearchbarView *)searchbarView {
    if(!_searchbarView) {
        _searchbarView = [[QCSearchbarView alloc] initWithFrame:CGRectMake(15.0f, 10.0f, QCScreenWidth - 30.0f, 36.0f)];
        _searchbarView.placeholder = LLang(@"搜索");
        _searchbarView.onClick = ^{
            QCGlobalSearchResultController *vc = [QCGlobalSearchResultController new];
            [[QCNavigationManager shared] pushViewController:vc animated:NO];
        };
    }
    return _searchbarView;
}

// 联系人数据更新
-(void) contactsUpdate:(NSNotification*)notify {
    [self requestData];
   
}

-(void) refreshContactsHeader {
    if(self.items.count>0) {
        NSArray *headerItems = [[QCApp shared] invokes:QCPOINT_CATEGORY_CONTACTSITEM param:nil];
        if(self.items.count>0) {
            [self.items replaceObjectAtIndex:0 withObject:[NSMutableArray arrayWithArray:headerItems]];
        }
        [self.tableView reloadData];
    }
    [self refreshTaBarItemBadgeValue:self.tabBarItem];
}

- (void)viewConfigChange:(QCViewConfigChangeType)type {
    [super viewConfigChange:type];
    if(type == QCViewConfigChangeTypeLang || type == QCViewConfigChangeTypeModule) {
        [self refreshContactsHeader];
    }
}

// 请求有效联系人数据
-(void) requestData{
    self.items = [NSMutableArray array];
    self.sectionTitleArr = [NSMutableArray array];
    NSArray *headerItems = [[QCApp shared] invokes:QCPOINT_CATEGORY_CONTACTSITEM param:nil];
    [self.items insertObject:[NSMutableArray arrayWithArray:headerItems] atIndex:0];
   
    NSArray<QCChannelInfo*> *channelInfos = [[QCChannelInfoDB shared] queryChannelInfosWithStatusAndFollow:QCChannelStatusNormal follow:QCChannelInfoFollowFriend];
    if(channelInfos) {
        self.contactsCountLbl.text = [NSString stringWithFormat:LLang(@"%ld个朋友"),(long)channelInfos.count];
    }
    NSMutableArray *items = [NSMutableArray array];
    if(channelInfos) {
        for (NSInteger i=0; i<channelInfos.count; i++) {
            QCChannelInfo *channelInfo =channelInfos[i];
            QCContactsCellModel *contactsCellModel = [self toContactsCellModel:channelInfo];
           
            [items addObject:contactsCellModel];
        }
    }
    if(items.count>0) {
        [self sortAndGroup:items];
    }
    
}

-(QCContactsCellModel*) toContactsCellModel:(QCChannelInfo*)channelInfo {
    QCContactsCellModel *contactsCellModel = [[QCContactsCellModel alloc] init];
    contactsCellModel.uid =channelInfo.channel.channelId;
    contactsCellModel.name = channelInfo.displayName;
    contactsCellModel.online = channelInfo.online;
    contactsCellModel.lastOffline = channelInfo.lastOffline;
    contactsCellModel.channelInfo = channelInfo;
    
    if(channelInfo.logo) {
        NSString *avatarURL = [[NSURL URLWithString:[QCAvatarUtil getFullAvatarWIthPath:channelInfo.logo]] absoluteString];
        contactsCellModel.avatar =avatarURL;
    }
    return contactsCellModel;
}

// 联系人排序和分组
-(void) sortAndGroup:(NSArray*)items{
    __weak typeof(self) weakSelf = self;
    [QCChineseSort sortAndGroup:items key:@"name" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if(isSuccess) {
            weakSelf.sectionTitleArr = sectionTitleArr;
            [weakSelf.items addObjectsFromArray:sortedObjArr];
            [weakSelf.tableView reloadData];
        }
    }];
}



#pragma mark - table

-(UIView*) tableHeader {
    if(!_tableHeader) {
        CGFloat emptyHeight = 15.0f;
        CGFloat emptyToSearchbarSpace = 10.0f;
        CGFloat searchbarViewTopSpace = 10.0f;
        _tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCScreenWidth, self.searchbarView.frame.size.height+emptyHeight + emptyToSearchbarSpace + searchbarViewTopSpace)];
        [_tableHeader addSubview:self.searchbarView];
        
        
        UIView *bottomEmptyView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.searchbarView.lim_bottom + emptyToSearchbarSpace, QCScreenWidth, emptyHeight)];
        [bottomEmptyView setBackgroundColor:QCApp.shared.config.cellBackgroundColor];
        [_tableHeader addSubview:bottomEmptyView];
    }
    return _tableHeader;
}

-(UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:[self visibleRect] style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        UIEdgeInsets separatorInset   = _tableView.separatorInset;
        separatorInset.right          = 0;
        _tableView.separatorInset = separatorInset;
        _tableView.backgroundColor=[UIColor clearColor];
        
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
//        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.sectionHeaderHeight = 0.0f;
        _tableView.sectionFooterHeight = 0.0f;
        _tableView.sectionIndexColor = QCApp.shared.config.themeColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:QCContactsCell.class forCellReuseIdentifier:[QCContactsCell cellId]];
        [_tableView registerClass:QCContactsHeaderItemCell.class forCellReuseIdentifier:[QCContactsHeaderItemCell cellId]];
        
         _tableView.tableHeaderView = self.tableHeader;
        
        _tableView.tableFooterView = [self tableFooterView];
        
    }
    return _tableView;
}

-(void) loadView{
    [super loadView];
    [self.view addSubview:self.tableView];
}

-(UIView*) tableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.lim_width, 44.0f)];
    [footerView addSubview:self.contactsCountLbl];
    self.contactsCountLbl.frame = footerView.frame;
    footerView.backgroundColor = QCApp.shared.config.backgroundColor;
    return footerView;
}

-(UILabel*) contactsCountLbl {
    if(!_contactsCountLbl) {
        _contactsCountLbl = [[UILabel alloc] init];
        _contactsCountLbl.textColor = QCApp.shared.config.tipColor;
        _contactsCountLbl.font = [QCApp.shared.config appFontOfSize:QCApp.shared.config.footerTipFontSize];
        [_contactsCountLbl setTextAlignment:NSTextAlignmentCenter];
    }
    return _contactsCountLbl;
}


// 头部字母部分
-(UIView*) headView:(NSString*)title headHeight:(CGFloat)headHheght color:(UIColor*)color{
    
    UIView *headView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, QCScreenWidth, headHheght)];
    [headView setBackgroundColor: QCApp.shared.config.cellBackgroundColor];
    UILabel  *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, headView.lim_width, headView.lim_height)];
    [titleLbl setFont:[[QCApp shared].config appFontOfSize:12.0f]];
    [titleLbl setTextColor:color];
    [titleLbl setText:title];
    [headView addSubview:titleLbl];

//    UIView *lineView = [[UIView alloc] init];
//    lineView.lim_left = 15.0f;
//    lineView.lim_height = 1.0f;
//    lineView.lim_width = self.view.lim_width-15.0f;
//    [lineView setBackgroundColor:[UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f]];
//    lineView.lim_top = headHheght - 1;
//    [headView addSubview:lineView];
    return headView;
}

#pragma mark UITableDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.items[section].count;;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.items.count<=indexPath.section || self.items[indexPath.section].count<=indexPath.row) {
        return [[UITableViewCell alloc] init];
    }
    id model =  self.items[indexPath.section][indexPath.row];
    if([model isKindOfClass:[QCContactsCellModel class]]) {
        QCContactsCellModel *contactsCellModel = (QCContactsCellModel*)model;
        if(indexPath.row == 0) {
            NSString *title = [self.sectionTitleArr objectAtIndex:indexPath.section-1];
            contactsCellModel.first = indexPath.row == 0;
            contactsCellModel.firstLetter = title;
        }
        contactsCellModel.last = self.items[indexPath.section].count-1 == indexPath.row;
        QCContactsCell *cell =  [tableView dequeueReusableCellWithIdentifier:[QCContactsCell cellId]];
        [cell refresh:contactsCellModel];
        return cell;
    } else if([model isKindOfClass:[QCContactsHeaderItem class]]) {
        QCContactsHeaderItemCell *cell =  [tableView dequeueReusableCellWithIdentifier:[QCContactsHeaderItemCell cellId]];
        QCContactsHeaderItem *headerItem =  model;
        [cell refresh:headerItem];
        return cell;
    }
    return [[UITableViewCell alloc] init];
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0) {
        return 70.0f;
    }
    
    return  70.0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return 0.0f;
    }
    return 20.0f;
}
-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0) {
        return nil;
    }
    if (!self.sectionTitleArr || self.sectionTitleArr.count == 0) {
        return nil;
    }
    NSString *title = [self.sectionTitleArr objectAtIndex:section-1];
    return [self headView:title headHeight:20.0f color:QCApp.shared.config.themeColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
   if(section == 0) {
       return 10.0f;
    }
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if(section == 0) {
       UIView *footer = [[UIView alloc] init];
        [footer setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
       return footer;
    }
    return nil;
}

//点击右侧索引表项时调用 索引与section的对应关系
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index+1;
}
//
//section右侧index数组
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.sectionTitleArr;
}


//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionTitleArr.count+1;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id model =  self.items[indexPath.section][indexPath.row];
    if([model isKindOfClass:[QCContacts class]]) {
        QCContacts *contacts = model;
        // 显示聊天UI
        [[QCApp shared] pushConversation:[[QCChannel alloc] initWith:contacts.uid channelType:WK_PERSON]];
    }else if([model isKindOfClass:[QCContactsHeaderItem class]]) {
        QCContactsHeaderItem *headerItem = model;
        if(headerItem.onClick) {
            headerItem.onClick();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.items.count<=indexPath.section || self.items[indexPath.section].count <= indexPath.row) {
        return false;
    }
    id model =  self.items[indexPath.section][indexPath.row];
    if([model isKindOfClass:[QCContacts class]]) {
        return true;
    }
    return false;
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self)weakSelf = self;
    QCContacts *contacts =  self.items[indexPath.section][indexPath.row];
    UITableViewRowAction *settingRemarkAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"设置备注" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf toSettingRemark:contacts];

    }];
    if(QCApp.shared.config.style == QCSystemStyleDark) {
        settingRemarkAction.backgroundColor = [QCApp shared].config.backgroundColor;
    } else {
        settingRemarkAction.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    }
    

    return @[settingRemarkAction];
}

-(void) toSettingRemark:(QCContacts*)contacts {
    QCInputVC *inputVC = [QCInputVC new];
    inputVC.title = LLang(@"修改备注");
    inputVC.maxLength = 10;
    QCChannel *channel = [QCChannel personWithChannelID:contacts.uid];
    NSString *name = contacts.name;
    inputVC.defaultValue = name;
    [inputVC setOnFinish:^(NSString * _Nonnull value) {
        
        [[QCChannelSettingManager shared] channel:channel remark:value?:@""];
        [[QCNavigationManager shared] popViewControllerAnimated:YES];
    }];
    [[QCNavigationManager shared] pushViewController:inputVC animated:YES];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark  -- QCContactsManagerDelegate
-(void) contactsManager:(QCContactsManager*)manager lastFriendRequest:(QCFriendRequestDBModel*)friendRequestDBModel {
   
}
-(void) contactsManager:(QCContactsManager*)manager friendRequestUnreadCount:(int)unreadCount {
    [self refreshContactsHeader];
}

// 好友邀请被接受
-(void) contactsManager:(QCContactsManager *)manager friendAccepted:(NSDictionary*)param {
    NSString *toUID = param[@"to_uid"];
    if(toUID) {
        // 更新状态
        [[QCContactsManager shared] updateFriendRequestStatus:toUID status:QCFriendRequestStatusSured];
        
        [self refreshTaBarItemBadgeValue];
    }
    // 开始同步联系人
    [[[QCContactsSync alloc] init] sync:^(NSError *error) {
        if(!error) {
            NSString *fromUID = param[@"from_uid"];
            if(fromUID) {
                [[QCSDK shared].channelManager fetchChannelInfo:[QCChannel personWithChannelID:fromUID]];
            }
        }
        
    }];
}

-(void) refreshTaBarItemBadgeValue {
    [self refreshTaBarItemBadgeValue:self.tabBarItem];
}

-(void) refreshTaBarItemBadgeValue:(UITabBarItem*)tabbarItem {
    int count = [[QCContactsManager shared] getFriendRequestUnreadCount];
    NSArray<NSNumber*> *reddots = [[QCApp shared] invokes:WK_CONTACTS_CATEGORY_TAB_REDDOT param:nil];
    BOOL hasReddot = false;
    if(reddots && reddots.count>0) {
        for (NSNumber *number in reddots) {
            if(number.intValue== - 1) {
                hasReddot = true;
            }else{
                count += number.intValue;
            }
        }
    }
    if (@available(iOS 10.0, *)) {
        tabbarItem.badgeColor = [UIColor redColor];
        [tabbarItem setBadgeTextAttributes:nil forState:UIControlStateNormal];
    }
    if(count>0) {
        tabbarItem.badgeValue = [NSString stringWithFormat:@"%d",count];
    }else if(hasReddot) {
        tabbarItem.badgeValue = @"●";
        if (@available(iOS 10.0, *)) {
            tabbarItem.badgeColor = [UIColor clearColor];
            [tabbarItem setBadgeTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateNormal];
        }else{
            tabbarItem.badgeValue = @"";
        }
    }else{
        tabbarItem.badgeValue = nil;
    }
}

- (UITabBarItem *)tabBarItem {
    UITabBarItem *tabbarItem = [super tabBarItem];
    [self refreshTaBarItemBadgeValue:tabbarItem];
    return tabbarItem;
}

-(void) addOrUpdateContactsWithChannelInfo:(QCChannelInfo*)channelInfo {
    if(self.items.count<=1) {
        return;
    }
    
    QCContactsCellModel *existCellModel;
    NSIndexPath *existIndexPath;
    for (NSInteger i=1; i<self.items.count; i++) {
        NSMutableArray *contactsItems = self.items[i];
        NSInteger k = 0;
        for (QCContactsCellModel *cellModel in contactsItems) {
            if([channelInfo.channel.channelId isEqualToString:cellModel.uid]) {
                existCellModel = cellModel;
                existIndexPath = [NSIndexPath indexPathForRow:k inSection:i];
                break;
            }
            k++;
        }
    }
    
   
    if(!existCellModel) {
        [self addContactsWithChannelInfo:channelInfo];
        [self.tableView reloadData];
        return;
    }
    BOOL hasChange = false;
    if(![channelInfo.displayName isEqualToString:existCellModel.name]) { // 改变了名字
        [self requestData];
    }
    
    if(channelInfo.online != existCellModel.online || channelInfo.lastOffline != existCellModel.lastOffline || channelInfo.deviceFlag !=existCellModel.channelInfo.deviceFlag) { // 上线或离线状态改变
        existCellModel.online = channelInfo.online;
        existCellModel.lastOffline = channelInfo.lastOffline;
        existCellModel.channelInfo = channelInfo;
        hasChange = true;
    }
    if(hasChange) {
        [self.tableView reloadData];
    }
   
    
}

-(void) addContactsWithChannelInfo:(QCChannelInfo*)channelInfo {
    NSInteger i= 0;
    NSString *newFirstLetter = [QCChineseSort getFirstLetter:channelInfo.displayName];
    if(!newFirstLetter) {
        newFirstLetter = @"#";
    }
    BOOL has = false;
    for (NSString *letter in self.sectionTitleArr) {
        if([newFirstLetter isEqualToString:letter]) {
           NSMutableArray *items = self.items[i+1];
            [items insertObject:[self toContactsCellModel:channelInfo] atIndex:0];
            has = true;
            break;
        }
        i++;
    }
    if(!has) { // 没有添加成功应该是没有对应的字母索引，所以这里直接重新请求
        [self requestData];
    }
}

-(void) removeContacts:(NSString*)uid {
    if(!uid || self.items.count<=1) {
        return;
    }
    NSIndexPath *existIndexPath;
    for (NSInteger i=1; i<self.items.count; i++) {
        NSMutableArray *contactsItems = self.items[i];
        NSInteger k = 0;
        for (QCContactsCellModel *cellModel in contactsItems) {
            if([uid isEqualToString:cellModel.uid]) {
                existIndexPath = [NSIndexPath indexPathForRow:k inSection:i];
                break;
            }
            k++;
        }
    }
    if(existIndexPath) {
        NSMutableArray *contactsItems = self.items[existIndexPath.section];
        if(contactsItems.count>existIndexPath.row) {
            [contactsItems removeObjectAtIndex:existIndexPath.row];
        }
        if(contactsItems.count == 0) {
            if(self.items.count>existIndexPath.section) {
                [self.items removeObjectAtIndex:existIndexPath.section];
            }
            if(self.sectionTitleArr.count>existIndexPath.section-1) {
                [self.sectionTitleArr removeObjectAtIndex:existIndexPath.section-1];
            }
            [self.tableView reloadData];
        }
    }
    
}

#pragma mark - QCChannelManagerDelegate

- (void)channelInfoUpdate:(QCChannelInfo *)channelInfo oldChannelInfo:(QCChannelInfo *)oldChannelInfo {
    if(channelInfo.channel.channelType == WK_PERSON && channelInfo.follow == QCChannelInfoFollowFriend) {
        [self addOrUpdateContactsWithChannelInfo:channelInfo];
    }
}

- (void)channelInfoDelete:(QCChannel *)channel oldChannelInfo:(QCChannelInfo *)oldChannelInfo {
    if(channel.channelType == WK_PERSON && oldChannelInfo.follow == QCChannelInfoFollowFriend) {
        [self removeContacts:channel.channelId];
    }
}

@end
