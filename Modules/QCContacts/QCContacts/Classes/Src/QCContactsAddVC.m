//
//  QCContactsAddVC.m
//  QCContacts
//
//  Created by tt on 2019/12/31.
//

#import "QCContactsAddVC.h"
#import <QCCore/QCCore.h>
#import <QCCore/QCSearchController.h>
#import "QCContactsVM.h"
#import "QCContactsInfoVC.h"
#import "QCSearchbarView.h"
#import "QCContactsSearchVC.h"
@interface QCContactsAddVC ()
@property(nonatomic,strong) QCSearchbarView *searchbarView;
@end

@implementation QCContactsAddVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCContactsVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = self.searchbarView;
    
}

- (NSString *)langTitle {
    return LLang(@"添加朋友");
}

- (QCSearchbarView *)searchbarView {
    if(!_searchbarView) {
        _searchbarView = [[QCSearchbarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCScreenWidth, 40.0f)];
        _searchbarView.placeholder = LLang(@"搜索");
        _searchbarView.onClick = ^{
            [[QCNavigationManager shared] pushViewController:[QCContactsSearchVC new] animated:NO];
        };
        
    }
    return _searchbarView;
}


//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    __weak typeof(self) weakSelf = self;
//    [self.contactsVM searchFriend:searchBar.text].then(^(QCUserSearchResp *resp){
//        if(!resp.exist) {
//            [weakSelf.view showMsg:@"用户不存在！"];
//            return;
//        }
//        [[QCApp shared] invoke:QCPOINT_CONTACTSINFO_SHOW param:@{@"uid":resp.user.uid}];
//    });
//}

@end
