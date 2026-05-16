//
//  QCCountdownFormItemCell.m
//  QCCore
//
//  Created by tt on 2022/11/21.
//

#import "QCCountdownFormItemCell.h"
#import "QCCore.h"
@implementation QCCountdownFormItemModel

- (Class)cell {
    return QCCountdownFormItemCell.class;
}

@end

@interface QCCountdownFormItemCell ()

@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) QCCountdownFormItemModel *countdownFormItemModel;

@end

@implementation QCCountdownFormItemCell

- (void)setupUI {
    [super setupUI];
    
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
}

- (void)refresh:(QCCountdownFormItemModel *)model {
    [super refresh:model];
    self.countdownFormItemModel = model;
    [self updateCountdown];
    __weak typeof(self) weakSelf = self;
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf updateCountdown];
     }];
    

}

-(void) updateCountdown {
    if(!self.countdownFormItemModel) {
        return;
    }
    NSString *secondStr = [QCTimeTool formatCountdownTime:self.countdownFormItemModel.second];
    if([secondStr isEqualToString:@""]) {
        self.valueLbl.text = self.countdownFormItemModel.value;
    }else {
        self.valueLbl.text = [NSString stringWithFormat:@"%@（%@）",self.countdownFormItemModel.value,secondStr];
    }
}


- (void)dealloc {
    NSLog(@"QCCountdownFormItemCell dealloc");
    [self.timer invalidate];
    self.timer = nil;
}

@end
