//
//  QCMD5Util.h
//  QCCore
//
//  Created by tt on 2021/8/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCMD5Util : NSObject

+ (NSString* )md5HexDigest:(NSString* )input;

@end

NS_ASSUME_NONNULL_END
