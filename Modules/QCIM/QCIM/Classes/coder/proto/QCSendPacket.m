//
//  QCSendPacket.m
//  QCIM
//
//  Created by tt on 2019/11/27.
//

#import "QCSendPacket.h"
#import "QCConst.h"
#import "QCData.h"
#import "QCSDK.h"
#import "QCSecurityManager.h"
@implementation QCSendPacket


- (QCSetting *)setting {
    if(!_setting) {
        _setting = [QCSetting new];
    }
    return  _setting;
}

-(QCPacketType) packetType {
    return WK_SEND;
}

-(QCPacket*) decode:(NSData*) body header:(QCHeader*)header {
    
    return nil;
}
-(NSData*) encode:(QCSendPacket*)packet {
    return [self encodeLM:packet];
}

-(NSData*) encodeLM:(QCSendPacket*)packet{
    QCDataWrite  *writer = [[QCDataWrite alloc] init];
    
    uint8_t setting = [packet.setting toUint8];
    [writer writeUint8:setting];
    
    NSString *payloadStr = [[NSString alloc] initWithData:packet.payload encoding:NSUTF8StringEncoding];
    NSString *payloadEnc = [[QCSecurityManager shared] encryption:payloadStr];
    
    packet.payload = [payloadEnc dataUsingEncoding:NSUTF8StringEncoding];
    
    
    // 消息序列号(客户端维护)
    [writer writeUint32:packet.clientSeq];
    // 客户端唯一消息编号
    [writer writeVariableString:packet.clientMsgNo];
    //  频道ID
    [writer writeVariableString:packet.channelId];
    // 频道类型
    [writer writeUint8:packet.channelType];
    if(QCSDK.shared.options.protoVersion>=3) {
        // expire
        [writer writeUint32:(uint32_t)packet.expire];
    }
   
    NSString *signStr = [packet veritifyString];
    NSString *msgKey = [[QCSecurityManager shared] encryption:signStr];
    [writer writeVariableString:[[QCSecurityManager shared] md5:msgKey]];
    
    
    if(packet.setting.topic) {
        [writer writeVariableString:packet.topic?:@""];
    }
    // 消息内容
    [writer writeData:packet.payload];
   
    
    return [writer toData];
}


-(NSString*) veritifyString {
    NSString *payloadStr = [[NSString alloc] initWithData:self.payload encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%d%@%@%d%@",self.clientSeq,self.clientMsgNo?:@"",self.channelId?:@"",self.channelType,payloadStr?:@""];
}

@end
