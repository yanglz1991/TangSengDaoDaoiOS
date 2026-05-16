//
//  QCConversationPosition.m
//  WuKongBase
//
//  Created by tt on 2021/8/11.
//

#import "QCConversationPosition.h"

@implementation QCConversationPosition

+(QCConversationPosition*) orderSeq:(uint32_t)orderSeq offset:(int)offset type:(QCConversationPositionType)type{
    QCConversationPosition *position = [QCConversationPosition new];
    position.orderSeq = orderSeq;
    position.offset = offset;
    position.positionType = type;
    return position;
}

+(QCConversationPosition*) orderSeq:(uint32_t)orderSeq offset:(int)offset {
    return [self orderSeq:orderSeq offset:offset type:QCConversationPositionTypeUnreadFirst];
}

@end

@interface QCConversationPositionManager ()

@property(nonatomic,strong) NSMutableDictionary<QCChannel*,NSMutableArray<QCConversationPosition*>*> *positions;

@end

@implementation QCConversationPositionManager

static QCConversationPositionManager *_instance = nil;

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone ];
    });
    return _instance;
}

+(instancetype) shared{
    if (_instance == nil) {
        _instance = [[super alloc]init];
    }
    return _instance;
}

-(void) reload {
    [self.positions removeAllObjects];
}

- (NSMutableDictionary *)positions {
    if(!_positions) {
        _positions = [NSMutableDictionary dictionary];
    }
    return _positions;
}

-(void) channel:(QCChannel*)channel position:(QCConversationPosition*)position{
    if(!position) {
        return;
    }
    NSMutableArray *positions = self.positions[channel];
    if(!positions) {
        positions = [NSMutableArray array];
    }
    [positions addObject:position];
    self.positions[channel] = positions;
    
}

-(void) removePositions:(QCChannel*)channel {
    [self.positions removeObjectForKey:channel];
}

-(void) removePositions:(QCChannel*)channel type:(QCConversationPositionType)type{
    NSArray<QCConversationPosition*> *positions = [self.positions objectForKey:channel];
    NSMutableArray *newPositions = [NSMutableArray array];
    if(positions&&positions.count>0) {
        for (QCConversationPosition *position in positions) {
            if(position.positionType != type) {
                [newPositions addObject:position];
            }
        }
    }
    [self.positions setObject:newPositions forKey:channel];
}


-(NSArray<QCConversationPosition*>*) position:(QCChannel*)channel {
    
    return self.positions[channel];
}

@end
