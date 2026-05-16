//
//  QCViewedManager.m
//  QCIM
//
//  Created by tt on 2022/8/17.
//

#import "QCFlameManager.h"
#import "QCMessageDB.h"
#import "QCSDK.h"
@implementation QCFlameManager


static QCFlameManager *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCFlameManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(void) didViewed:(NSArray<QCMessage*>*) messages {
    if(!messages || messages.count == 0) {
        return;
    }
    messages = [[QCMessageDB shared] updateViewed:messages];
    
    for (QCMessage *message in messages) {
        [QCSDK.shared.chatManager callMessageUpdateDelegate:message];
    }
}

-(NSArray<QCMessage*>*) getMessagesOfNeedFlame {
    return [QCMessageDB.shared getMessagesOfNeedFlame];
}

@end
