//
//  QCRobotMenusListView.m
//  WuKongBase
//
//  Created by tt on 2021/10/18.
//

#import "QCRobotMenusListView.h"
#import "WuKongBase.h"
#define menusItemHeight 40.0f

@interface QCRobotMenusItemCell ()

@property(nonatomic,strong) QCUserAvatar *iconImgView;
@property(nonatomic,strong) UILabel *cmdLbl;
@property(nonatomic,strong) UILabel *remarkLbl;

@property(nonatomic,strong) QCRobotMenusItem *item;

@end

@implementation QCRobotMenusItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

-(void) onTap {
    if(self.item.onClick) {
        self.item.onClick();
    }
}

-(void) setupUI {
    [self.contentView addSubview:self.iconImgView];
    [self.contentView addSubview:self.cmdLbl];
    [self.contentView addSubview:self.remarkLbl];
}

-(void) refresh:(QCRobotMenusItem*)item {
    self.item = item;
    self.iconImgView.url = item.iconURL;
    
    self.cmdLbl.text = item.cmd;
    [self.cmdLbl sizeToFit];
    self.remarkLbl.text = item.remark;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconImgView.lim_centerY_parent = self.contentView;
    self.iconImgView.lim_left = 15.0f;
    
    self.cmdLbl.lim_left = self.iconImgView.lim_right + 15.0f;
    self.cmdLbl.lim_centerY_parent = self.contentView;
    
    CGFloat remarkLeftSpace = 10.0f;
    
    
    self.remarkLbl.lim_width = self.contentView.lim_width - self.cmdLbl.lim_right - remarkLeftSpace - 20.0f;
    self.remarkLbl.lim_height = self.contentView.lim_height;
    self.remarkLbl.lim_left = self.cmdLbl.lim_right + remarkLeftSpace;
}

- (QCUserAvatar *)iconImgView {
    if(!_iconImgView) {
        _iconImgView = [[QCUserAvatar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    }
    return _iconImgView;
}

- (UILabel *)cmdLbl {
    if(!_cmdLbl) {
        _cmdLbl = [[UILabel alloc] init];
        _cmdLbl.font = [[QCApp shared].config appFontOfSizeMedium:16.0f];
    }
    return _cmdLbl;
}

- (UILabel *)remarkLbl {
    if(!_remarkLbl) {
        _remarkLbl = [[UILabel alloc] init];
        _remarkLbl.font = [[QCApp shared].config appFontOfSizeMedium:12.0f];
        _remarkLbl.textColor = [QCApp shared].config.tipColor;
        _remarkLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _remarkLbl;
}

@end

@implementation QCRobotMenusItem

+(QCRobotMenusItem*) cmd:(NSString*)cmd iconURL:(NSString*)iconURL remark:(NSString*)remark onClick:(void(^)(void)) onClick{
    QCRobotMenusItem *item = [QCRobotMenusItem new];
    item.cmd = cmd;
    item.iconURL = iconURL;
    item.remark = remark;
    item.onClick = onClick;
    return item;
}

@end

@interface QCRobotMenusListView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) NSArray<QCRobotMenusItem*>* items;

@property(nonatomic,strong) UITableView *tableView;

@end

@implementation QCRobotMenusListView

+(instancetype) initItems:(NSArray<QCRobotMenusItem*>*)items {
    QCRobotMenusListView *listView = [[QCRobotMenusListView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, items.count*menusItemHeight)];
    listView.items = items;
    return listView;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
    }
    return self;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        [_tableView registerClass:QCRobotMenusItemCell.class forCellReuseIdentifier:@"QCRobotMenusItemCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

#pragma mark -- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QCRobotMenusItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QCRobotMenusItemCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    QCRobotMenusItem *item =  self.items[indexPath.row];
     [(QCRobotMenusItemCell*)cell refresh:item];
}



@end
