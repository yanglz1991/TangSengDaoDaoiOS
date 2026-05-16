//
//  QCContactsSelectVC.m
//  QCContacts
//
//  Created by tt on 2019/12/7.
//

#import "QCContactsSelectVC.h"
#import "QCContactsSelectCell.h"
#import "QCChineseSort.h"
#import "QCContactsManager.h"
#import "QCBarUserSearchView.h"
#import "QCContacts.h"
#import  "UIBarButtonItem+WK.h"
//头部视图高度
#define HEAD_VIEW_HEIGHT 50

@interface QCContactsSelectVC ()<UITableViewDataSource,UITableViewDelegate,QCContactsManagerDelegate>

@property(nonatomic,strong) NSArray *sectionTitleArr; //排序后的出现过的拼音首字母数组
@property(nonatomic,strong) NSMutableArray<NSArray*> *items;
/// 默认被选中的用户集合
@property(nonatomic, strong) NSMutableArray<QCContactsSelect*> *selectedArray;

@property(nonatomic, strong) QCBarUserSearchView *searchBar;

@property(nonatomic,strong) UIView *mentionAllHeader;

@property(nonatomic,assign) BOOL notGetChannel; // 不去获取频道的名字

@end

@implementation QCContactsSelectVC

-(instancetype) init {
    self = [super init];
    if(self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.showBack) {
        [self.navigationBar setShowBackButton:YES];
    }
    
    self.items = [NSMutableArray array];
    
    [self refreshRightItem];
    //添加搜索bar
    [self.view addSubview:self.searchBar];
   
    [self requestData];
    
    [self parseData:self.data];
    if (!self.maxSelectMembers) {
        self.maxSelectMembers = self.data.count;
    }
}

- (NSString *)langTitle {
    return self.title;
}

-(void) requestData {
    if(!self.data) {
        self.data = [[QCApp shared] invoke:QCPOINT_CONTACTS_SELECT_DATA param:nil];
    }
    if(self.data && self.data.count>0) {
        for (QCContactsSelect *contactsSelect in self.data) {
            contactsSelect.selected = self.selecteds?[self.selecteds containsObject:contactsSelect.uid]:contactsSelect.selected;
            contactsSelect.disable = self.disables?[self.disables containsObject:contactsSelect.uid]:contactsSelect.disable;
            contactsSelect.mode = self.mode;
        }
    }
}

// 请求有效联系人数据
-(void) parseData:(NSArray<QCContactsSelect*>*) data {
    self.items = [NSMutableArray array];
    self.sectionTitleArr = @[];
    if(data) {
        NSMutableArray *newData = [NSMutableArray array];
        for (QCContactsSelect *contactsSelect in data) {
            if(self.hiddenUsers && [self.hiddenUsers containsObject:contactsSelect.uid]) {
                continue;
            }
            [newData addObject:contactsSelect];
            
            if(!self.notGetChannel) {
               QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:[QCChannel personWithChannelID:contactsSelect.uid]]; // TODO: 成员多了 这里可能会影响性能
                if(channelInfo) {
                    contactsSelect.displayName = channelInfo.displayName;
                }
            }
        }
        [self sortAndGroup:newData];
    }
}

- (QCBarUserSearchView *)searchBar {
    if(!_searchBar) {
        _searchBar = [[QCBarUserSearchView alloc] initWithFrame:CGRectMake(0, self.navigationBar.lim_bottom, QCScreenWidth, HEAD_VIEW_HEIGHT)];
        [_searchBar setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
        __weak typeof(self) weakSelf = self;
        [_searchBar setRemoveIconBlock:^(QCBarUserSearchModel *model) {
            if(weakSelf.selectedArray) {
                for (QCContactsSelect *contactsSelect in weakSelf.selectedArray) {
                    if([contactsSelect.uid isEqualToString:model.sid]) {
                        contactsSelect.selected = false;
                        [weakSelf removeOrAddSelectedContacts:contactsSelect];
                        [weakSelf refreshRightItem];
                        [weakSelf.tableView reloadData];
                        break;
                    }
                }
            }
        }];
        [_searchBar setSearchDidChangeBlock:^(NSString *keyword) {
            [weakSelf searchTextChange:keyword];
        }];
    }
    return _searchBar;
}

-(void) searchTextChange:(NSString*)text {
    NSArray *data;
    if([text isEqualToString:@""]) {
        data = self.data;
    }else {
        data = [self.data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[c] %@ OR displayName CONTAINS[c] %@",text,text]];
    }
    
    [self parseData:data];
}

// 联系人排序和分组
-(void) sortAndGroup:(NSArray<QCContactsSelect*>*)items{
    __weak typeof(self) weakSelf = self;
    [QCChineseSort sortAndGroup:items key:@"displayName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if(isSuccess && weakSelf) {
            weakSelf.sectionTitleArr = sectionTitleArr;
            [weakSelf.items addObjectsFromArray:sortedObjArr];
            [weakSelf.tableView reloadData];
        }
    }];
}


-(void) backPressed {
    if(_showBack) {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [[QCNavigationManager shared] popViewControllerAnimated:YES];
        }
    }
    else{
        [[QCNavigationManager shared] popViewControllerAnimated:YES];
    }
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
        if(self.mentionAll) {
            _tableView.tableHeaderView = self.mentionAllHeader;
        }
        [_tableView registerClass:QCContactsSelectCell.class forCellReuseIdentifier:[QCContactsSelectCell cellId]];
        
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

-(UIView*) mentionAllHeader {
    if(!_mentionAllHeader) {
        _mentionAllHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCScreenWidth, 60.0f)];
        _mentionAllHeader.backgroundColor = [QCApp shared].config.cellBackgroundColor;
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 45.0f)];
        [icon setImage:[self imageName:@"Conversation/Panel/MentionAll"]];
        
        [_mentionAllHeader addSubview:icon];
        icon.lim_centerY_parent = _mentionAllHeader;
        icon.lim_left = 15.0f;
        
        UILabel *nameLbl = [[UILabel alloc] init];
        nameLbl.text = LLang(@"@所有人");
        nameLbl.textColor = [QCApp shared].config.defaultTextColor;
        [nameLbl sizeToFit];
        
        nameLbl.lim_centerY_parent = _mentionAllHeader;
        nameLbl.lim_left = icon.lim_right + 10.0f;
        [_mentionAllHeader addSubview:nameLbl];
        
        _mentionAllHeader.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMentionAllTap)];
        [_mentionAllHeader addGestureRecognizer:tap];
    }
    return  _mentionAllHeader;
}

-(void) onMentionAllTap {
    if(self.onFinishedSelect) {
        self.onFinishedSelect(@[@"all"]);
    }
}

-(void) loadView{
    [super loadView];
    [self.view addSubview:self.tableView];
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

- (NSMutableArray *)selectedArray {
    NSMutableArray *items = [NSMutableArray array];
    for (QCContactsSelect *contact in self.data) {
        if(contact.selected) {
            [items addObject:contact];
        }
    }
    return items;
}

-(void) selectContacts:(QCContactsSelect*) contacts {
    
    [self removeOrAddSelectedContacts:contacts];
    [self removeOrAddBarUser:contacts];
    [self refreshRightItem];
    
}

-(void) refreshRightItem {
    if(self.mode == QCContactsModeSingle) {
        return;
    }
    if ([[self selectedArray] count] > 0) {
        NSString *rightTitle =
        [NSString stringWithFormat:@"%@(%i)", LLang(@"完成"),
         (int)[[self selectedArray] count]];
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

-(void) removeOrAddSelectedContacts:(QCContactsSelect*) contacts {
    if (self.selectedArray.count >= _maxSelectMembers+1) {
        contacts.selected = false;
        [self.tableView reloadData];
        NSString * alertString = [NSString stringWithFormat:@"最多选择%ld人!",(long)_maxSelectMembers];
        [self.view showMsg:alertString];
        return;
    }
}

-(void) removeOrAddBarUser:(QCContactsSelect*) contacts {
    QCBarUserSearchModel *barmodel =
    [[QCBarUserSearchModel alloc] initWithSid:contacts.uid];
    barmodel.icon = contacts.avatar;
    if (contacts.selected) {
        [self.searchBar addModel:barmodel];
    } else {
        [self.searchBar removeModel:barmodel];
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
// 下一步点击
-(void) nextBtnPress  {
    NSMutableArray *uids = [NSMutableArray array];
    if(self.selectedArray) {
        for (QCContactsSelect *contactsSelect in self.selectedArray) {
            [uids addObject:contactsSelect.uid];
        }
    }
    if(self.onFinishedSelect) {
        self.onFinishedSelect(uids);
    }
}

#pragma mark UITableDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.items[section].count;;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id model =  self.items[indexPath.section][indexPath.row];
    QCContactsSelectCell *cell =  [tableView dequeueReusableCellWithIdentifier:[QCContactsSelectCell cellId]];
    QCContactsSelect *contactsSelectModel = (QCContactsSelect*)model;
    contactsSelectModel.first = indexPath.row == 0;
    contactsSelectModel.last = self.items[indexPath.section].count-1 == indexPath.row;
    contactsSelectModel.mode = self.mode;
    [cell refreshWithModel:model];
    __weak typeof(self) weakSelf =self;
    [cell setStateChangeCheckBk:^(QCContactsSelect * _Nonnull model) {
        [weakSelf clearSearch];
        [weakSelf selectContacts:model];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  60.0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 20.0f;
}
-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSString *title = [self.sectionTitleArr objectAtIndex:section];
    return [self headView:title headHeight:20.0f color:[UIColor grayColor]];
}

//点击右侧索引表项时调用 索引与section的对应关系
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}
//
//section右侧index数组
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.sectionTitleArr;
}
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionTitleArr.count;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QCContactsSelect *model =  self.items[indexPath.section][indexPath.row];
    if(model.mode == QCContactsModeSingle) {
        if(model && !model.disable) {
            if(self.onFinishedSelect) {
                self.onFinishedSelect(@[model.uid]);
            }
        }
       
    }else {
        if(model && !model.disable) {
            [self clearSearch];
           
            model.selected = !model.selected;
            [self.tableView reloadData];
            [self selectContacts:model];
           
        }
    }
   
}

-(void) clearSearch {
    if(![self.searchBar.searchFd.text isEqualToString:@""]) {
        self.searchBar.searchFd.text = @"";
        [self searchTextChange:@""];
    }
}

//- (UITabBarItem *)tabBarItem {
//    UITabBarItem *tabbarItem = [super tabBarItem];
//    int count = [[QCContactsManager shared] getFriendRequestUnreadCount];
//    if(count>0) {
//        tabbarItem.badgeValue = [NSString stringWithFormat:@"%d", [[QCContactsManager shared] getFriendRequestUnreadCount]];
//    }
//    return tabbarItem;
//}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//    return [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}

- (void)dealloc {
    NSLog(@"QCContactsSelectVC dealloc");
    if(self.onDealloc) {
        self.onDealloc();
    }
}
@end
