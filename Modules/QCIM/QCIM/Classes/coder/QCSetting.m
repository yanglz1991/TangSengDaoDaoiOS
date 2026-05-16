//
//  QCSetting.m
//  QCIM
//
//  Created by tt on 2021/4/9.
//

#import "QCSetting.h"

@implementation QCSetting


-(uint8_t) toUint8 {
    return self.receiptEnabled<<7  | self.topic << 3 | self.streamOn << 2;
}

+ (QCSetting *)fromUint8:(uint8_t)v {
    QCSetting *setting = [QCSetting new];
    setting.receiptEnabled = ((v >> 7) & 0x01) > 0;
    setting.topic = ((v >> 3) & 0x01) > 0;
    setting.streamOn = ((v >> 2) & 0x01) > 0;
    return  setting;
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"SETTING receiptEnabled:%d topic:%d streamOn:%d",self.receiptEnabled?1:0,self.topic?1:0,self.streamOn?1:0];
}

@end
