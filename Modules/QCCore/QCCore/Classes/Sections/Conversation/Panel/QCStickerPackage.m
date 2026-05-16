//
//  QCStickerPackage.m
//  QCCore
//
//  Created by tt on 2021/9/28.
//

#import "QCStickerPackage.h"




@implementation QCSticker

+ (QCModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCSticker *resp = [QCSticker new];
    resp.path = dictory[@"path"];
    resp.width = dictory[@"width"];
    resp.height = dictory[@"height"];
    resp.format = dictory[@"format"];
    resp.sortNum = dictory[@"sort_num"];
    resp.category = dictory[@"category"];
    resp.placeholder = dictory[@"placeholder"];
    return resp;
}

- (NSDictionary *)toMap:(ModelMapType)type {
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    paramDict[@"path"] = self.path?:@"";
    paramDict[@"width"] = self.width?:@(0);
    paramDict[@"height"] = self.height?:@(0);
    paramDict[@"format"] = self.format?:@"";
    paramDict[@"sort_num"] = self.sortNum?:@(0);
    paramDict[@"category"] = self.category?:@"";
    paramDict[@"placeholder"] = self.placeholder?:@"";
    return paramDict;
}

@end



@implementation QCStickerPackage

+ (QCModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {

    QCStickerPackage *package = [QCStickerPackage new];
    package.title = dictory[@"title"]?:@"";
    package.desc = dictory[@"desc"]?:@"";
    package.category = dictory[@"category"]?:@"";
    package.cover = dictory[@"cover"]?:@"";
    package.added = [dictory[@"added"] boolValue];
    
   NSArray *stickerDicts =  dictory[@"list"];
    if(stickerDicts && stickerDicts.count>0) {
        NSMutableArray *stickers = [NSMutableArray array];
        for (NSDictionary *stickerDict in stickerDicts) {
            [stickers addObject:[QCSticker fromMap:stickerDict type:type]];
        }
        package.list = stickers;
    }
    return package;
}

@end
