//
//  QCLanguageVC.m
//  QCCore
//
//  Created by tt on 2020/12/25.
//

#import "QCLanguageVC.h"

@interface QCLanguageVC ()

@end

@implementation QCLanguageVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCLanguageVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)langTitle {
    return LLang(@"多语言");
}


@end
