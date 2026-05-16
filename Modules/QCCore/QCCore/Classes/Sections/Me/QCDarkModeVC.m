//
//  QCDarkModeVC.m
//  QCCore
//
//  Created by tt on 2020/12/11.
//

#import "QCDarkModeVC.h"

@interface QCDarkModeVC ()

@end

@implementation QCDarkModeVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCDarkModeVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (NSString *)langTitle {
    return LLang(@"深色模式");
}

@end
