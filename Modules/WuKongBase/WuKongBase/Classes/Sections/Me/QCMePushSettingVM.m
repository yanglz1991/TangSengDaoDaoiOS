//
//  QCMePushSettingVM.m
//  WuKongBase
//
//  Created by tt on 2020/6/19.
//

#import "QCMePushSettingVM.h"
#import "QCTableSectionUtil.h"
#import "QCLabelItemCell.h"
#import "QCSwitchItemCell.h"
#import "QCMySettingManager.h"
@implementation QCMePushSettingVM


- (NSArray<NSDictionary *> *)tableSectionMaps {

    BOOL newMsgNotice = [QCMySettingManager shared].newMsgNotice; // 新消息通知
    if(newMsgNotice == NO) {
        return @[
            [self newMsgItem:newMsgNotice],
        ];
    }
    BOOL msgShowDetail = [QCMySettingManager shared].msgShowDetail; // 通知是否显示详情
    BOOL voiceOn = [QCMySettingManager shared].voiceOn; // 声音开启
    BOOL shockOn = [QCMySettingManager shared].shockOn; // 震动开启
    
    return @[
            [self newMsgItem:newMsgNotice],
              @{
                  @"height":@(15.0f),
                  @"items":@[
                          @{
                              @"class":QCSwitchItemModel.class,
                              @"label":LLang(@"通知显示消息详情"),
                              @"on":@(msgShowDetail),
                              @"onSwitch":^(BOOL on){
                                   [[QCMySettingManager shared] msgShowDetail:on];
                              }
                          },
                  ],
              },
              @{
                  @"height":@(15.0f),
                  @"remark": [NSString stringWithFormat:LLang(@"在%@运行时，您可以设置是否需要声音或震动"),[QCApp shared].config.appName],
                  @"items":@[
                          @{
                              @"class":QCSwitchItemModel.class,
                              @"label":LLang(@"声音"),
                              @"on":@(voiceOn),
                              @"onSwitch":^(BOOL on){
                                  [[QCMySettingManager shared] voiceOn:on];
                              }
                          },
                          @{
                              @"class":QCSwitchItemModel.class,
                              @"label":LLang(@"震动"),
                              @"on":@(shockOn),
                              @"onSwitch":^(BOOL on){
                                  [[QCMySettingManager shared] shockOn:on];
                              }
                          },
                  ],
              },
          ];
}

-(NSDictionary*) newMsgItem:(BOOL) newMsgNotice{
    __weak typeof(self) weakSelf = self;
    return @{
        @"height":@(15.0f),
        @"remark": LLang(@"关闭后，手机将不再收到新消息通知"),
        @"items":@[
                @{
                    @"class":QCSwitchItemModel.class,
                    @"label":LLang(@"新消息通知"),
                    @"on":@(newMsgNotice),
                    @"onSwitch":^(BOOL on){
                        [[QCMySettingManager shared] newMsgNotice:on];
                        [weakSelf reloadData];
                    }
                },
        ],
    };
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}

@end
