//
//  QCFilePreviewVC.m
//  WuKongFile
//
//  Created by tt on 2020/7/16.
//

#import "QCFilePreviewVC.h"

@implementation QCPreviewFileItem

- (NSString *)previewItemTitle {

  return _title;
}

- (NSURL *)previewItemURL {
  return _url;
}



@end

@interface QCFilePreviewVC ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>
@property(nonatomic,strong) QCNavigationBar *navigationBar;
@end

@implementation QCFilePreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    self.navigationController.navigationBar.hidden = NO;
//    self.navigationBar.title = self.fileName;
//    self.navigationBar.showBackButton = YES;
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}


#pragma mark QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:
    (QLPreviewController *)controller {

  return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller
                    previewItemAtIndex:(NSInteger)index {
  QCPreviewFileItem *item = [[QCPreviewFileItem alloc] init];
  item.title = self.fileName;
  item.url = self.url;
  
  return item;
}


@end
