//
//  QCFuncGroupEditItemModel.m
//  WuKongBase
//
//  Created by tt on 2022/5/6.
//

#import "QCFuncGroupEditItemModel.h"


@interface QCFuncGroupEditItemModel ()


@end

@implementation QCFuncGroupEditItemModel

-(instancetype) initWithFuncItem:(id<QCPanelFuncItemProto>)funcItem {
    QCFuncGroupEditItemModel *model = [QCFuncGroupEditItemModel new];
    model.channelType = funcItem.channelType;
    model.sid = funcItem.sid;
    model.itemIcon = funcItem.itemIcon;
    model.title = [funcItem title];
    model.allowEdit = [funcItem allowEdit];
    model.sort = [funcItem sort];
    model.disable = [funcItem disable];
    return model;
}

@end

