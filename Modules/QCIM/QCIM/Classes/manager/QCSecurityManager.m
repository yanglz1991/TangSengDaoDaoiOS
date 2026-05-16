//
//  QCSecurityManager.m
//  QCIM
//
//  Created by tt on 2021/2/24.
//

#import "QCSecurityManager.h"
#import "Curve25519.h"
#import<CommonCrypto/CommonDigest.h>
#import "QCAESUtil.h"
@interface QCSecurityManager ()

@property(nonatomic,strong) ECKeyPair *curve25519Key;
@property(nonatomic,copy) NSString *aesKey;
@property(nonatomic,copy) NSString *aesIV;
@end

@implementation QCSecurityManager

static QCSecurityManager *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCSecurityManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(void) generateDHPair {
    self.curve25519Key = [Curve25519 generateKeyPair];
}

-(NSString*) getDHPubKey {
    return [self.curve25519Key.publicKey base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

-(void) generateAesKey:(NSString*)pubKey salt:(NSString*)salt {
    NSData *pubKeyData = [[NSData alloc] initWithBase64EncodedString:pubKey options:NSDataBase64DecodingIgnoreUnknownCharacters];
   NSData *sharedKeyData = [Curve25519 generateSharedSecretFromPublicKey:pubKeyData andKeyPair:self.curve25519Key];
    
    self.sharedKey =  [sharedKeyData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSString *aesKeyFull = [self md5:self.sharedKey];
    self.aesKey = [aesKeyFull substringToIndex:16];
    
    if(salt && salt.length>16) {
        self.aesIV = [salt substringToIndex:16];
    }else{
        self.aesIV = salt;
    }
}


- (NSString *)md5:(NSString *)input{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];

    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
           [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

-(NSString*) encryption:(NSString*)data {
    return [QCAESUtil aesEncrypt:data key:self.aesKey iv:self.aesIV];
}

-(NSString*) decryption:(NSString*)data {
    return [QCAESUtil aesDecrypt:data key:self.aesKey iv:self.aesIV];
}

@end
