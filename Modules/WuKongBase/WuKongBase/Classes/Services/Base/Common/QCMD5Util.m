//
//  QCMD5Util.m
//  WuKongBase
//
//  Created by tt on 2021/8/16.
//

#import "QCMD5Util.h"
#import <CommonCrypto/CommonDigest.h>

@implementation QCMD5Util
+ (NSString* )md5HexDigest:(NSString* )input {
    const char* str =[input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString* ret = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH];
    for(int i=0; i< CC_MD5_DIGEST_LENGTH; i++){
        [ret appendFormat:@"%02x", result[i]];
    }
    return ret;
}

@end
