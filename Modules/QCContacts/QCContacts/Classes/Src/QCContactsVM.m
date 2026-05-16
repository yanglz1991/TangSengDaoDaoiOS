//
//  QCContactsVM.m
//  QCContacts
//
//  Created by tt on 2019/12/7.
//

#import "QCContactsVM.h"
#import "QCContactsAddFunctionItemCell.h"
#import "QCContactsAddMyShortCell.h"
#import "QCMeQRCodeVC.h"
#import "QCScanVC.h"
#import "QCContactsFriendVC.h"
@implementation QCContactsVM

-(AnyPromise*) searchFriend:(NSString*)keyword {
    return [[QCAPIClient sharedClient] GET:@"user/search" parameters:@{@"keyword":keyword} model:QCUserSearchResp.class];
}

- (NSArray<NSDictionary *> *)tableSectionMaps {
    return @[
        @{
            @"height":@(5.0f),
            @"items": @[
                    @{
                        @"class": QCContactsAddMyShortModel.class,
                        @"value": [QCApp shared].loginInfo.extra[@"short_no"]?:@"",
                        @"onQRCode":^{
                            [[QCNavigationManager shared] pushViewController:[QCMeQRCodeVC new] animated:YES];
                        },
                    }
            ]
        },
        @{
            @"height":@(30.0f),
            @"items": @[
                    @{
                        @"class": QCContactsAddFunctionItemModel.class,
                        @"title": LLang(@"扫一扫"),
                        @"subtitle":LLang(@"扫描二维码名片"),
                        @"icon": [self imageName:@"Contacts/Others/Scan"],
                        @"onClick":^{
                            [[QCNavigationManager shared] pushViewController:[QCScanVC new] animated:YES];
                        },
                    }
            ]
        },
        @{
            @"height":@(0.0f),
            @"items": @[
                    @{
                        @"class": QCContactsAddFunctionItemModel.class,
                        @"title": LLang(@"手机联系人"),
                        @"subtitle":LLang(@"添加通讯录中的朋友"),
                        @"icon": [self imageName:@"Contacts/Others/Contacts"],
                        @"onClick":^{
                            QCContactsFriendVC *vc = [QCContactsFriendVC new];
                            [[QCNavigationManager shared] pushViewController:vc animated:YES];
                        },
                    }
            ]
        }
    ];
}

-(UIImage*) imageName:(NSString*)name {
    return [[QCApp shared] loadImage:name moduleID:@"QCContacts"];
}


@end

@implementation QCUserSearchResp

+(QCUserSearchResp*) fromMap:(NSDictionary*)dictory type:(ModelMapType)type {
    QCUserSearchResp *resp = [QCUserSearchResp new];
    
     NSInteger exist =  [dictory[@"exist"] integerValue];
    resp.exist = exist==1;
    if(resp.exist) {
        resp.user = (QCUserResp*)[QCUserResp fromMap:dictory[@"data"] type:type];
    }
    return resp;
}

@end

@implementation QCUserResp

+(QCUserResp*) fromMap:(NSDictionary*)dictory type:(ModelMapType)type {
    QCUserResp *resp = [QCUserResp new];
    resp.uid = dictory[@"uid"];
    resp.name = dictory[@"name"];
    resp.vercode = dictory[@"vercode"];
    resp.avatar = dictory[@"avatar"];
    return resp;
}

@end
