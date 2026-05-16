//
//  QCCMDContent.m
//  QCIM
//
//  Created by tt on 2020/1/31.
//

#import "QCCMDContent.h"

@implementation QCCMDContent


- (void)decodeWithJSON:(NSDictionary *)contentDic {
    self.cmd = contentDic[@"cmd"];
    self.param = contentDic[@"param"];
    self.sign = contentDic[@"sign"]?:@"";
}


- (NSDictionary *)encodeWithJSON {
    if(self.param) {
         return @{@"cmd":self.cmd?:@"",@"param":self.param};
    }
    return @{@"cmd":self.cmd?:@""};
   
}

+(NSNumber*) contentType {
    return @(WK_CMD);
}


@end
