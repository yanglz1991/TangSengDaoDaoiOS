//
//  QCRecvPacket.m
//  QCIM
//
//  Created by tt on 2019/11/27.
//

#import "QCRecvPacket.h"
#import "QCConst.h"
#import "QCData.h"
#import "QCSDK.h"
#import "QCSecurityManager.h"
@implementation QCRecvPacket


-(QCPacketType) packetType {
    return WK_RECV;
}
- (QCSetting *)setting {
    if(!_setting) {
        _setting = [QCSetting new];
    }
    return  _setting;
}

-(QCPacket*) decode:(NSData*) body header:(QCHeader*)header {
    return [self decodeLM:body header:header];
}

-(QCPacket*) decodeLM:(NSData*) body header:(QCHeader*)header {
    QCRecvPacket *packet = [QCRecvPacket new];
    packet.header = header;
    QCDataRead *reader = [[QCDataRead alloc] initWithData:body];
    uint8_t setting = [reader readUint8];
    packet.setting = [QCSetting fromUint8:setting];
    NSString *msgKey = [reader readString];
    packet.fromUid = [reader readString];
    packet.channelId = [reader readString];
    packet.channelType = [reader readUint8];
    if(QCSDK.shared.options.protoVersion>=3) {
        packet.expire =  [reader readUint32];
    }
    
    packet.clientMsgNo = [reader readString];
    if(packet.setting.streamOn) {
        packet.streamNo = [reader readString];
        packet.streamSeq = [reader readUint32];
        packet.streamFlag = [reader readUint8];
    }
    packet.messageId = [reader readUint64];
    packet.messageSeq = [reader readUint32];
    packet.timestamp = [reader readUint32];
    
    if(packet.setting.topic) {
        packet.topic = [reader readString];
    }
    
    packet.payload = [reader remainingData];
    
    NSString *exceptMsgKey = [[QCSecurityManager shared] encryption:[packet veritifyString]];
     exceptMsgKey= [[QCSecurityManager shared] md5:exceptMsgKey];
     if(![exceptMsgKey isEqualToString:msgKey]) {
         NSLog(@"消息不合法！期望的MsgKey:%@ 实际的MsgKey:%@",exceptMsgKey,msgKey);
         return nil;
     }
    NSString *payloadEnc = [[QCSecurityManager shared] decryption:[[NSString alloc] initWithData:packet.payload encoding:NSUTF8StringEncoding]];
    packet.payload = [payloadEnc dataUsingEncoding:NSUTF8StringEncoding];
    
    return packet;
}


-(NSData*) encode:(QCRecvPacket*)packet{
    return nil;
}

-(NSString*) veritifyString {
    NSString *payloadStr = [[NSString alloc] initWithData:self.payload encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%llu%u%@%u%@%@%u%@",self.messageId,self.messageSeq?:0,self.clientMsgNo?:@"",self.timestamp,self.fromUid?:@"",self.channelId?:@"",self.channelType,payloadStr?:@""];
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"RECV Header:%@ Setting:%@ fromUid:%@ messageId:%llu messageSeq:%u clientMsgNo:%@ streamNo:%@ streamSeq:%llu streamFlag:%lu timestamp:%u channelId:%@ channelType:%i topic:%@ payload: %@",self.header ,self.setting,       self.fromUid,self.messageId,self.messageSeq,self.clientMsgNo,self.streamNo,self.streamSeq,(unsigned long)self.streamFlag,self.timestamp,self.channelId,self.channelType,self.topic?:@"",[[NSString alloc] initWithData:self.payload encoding:NSUTF8StringEncoding]];
}

@end
