//
//  ContactsHeaderItem.m
//  QCCore
//
//  Created by tt on 2020/1/4.
//

#import "QCContactsHeaderItem.h"

@implementation QCContactsHeaderItem

+(QCContactsHeaderItem*) initWithSid:(NSString*)sid title:(NSString*)title icon:(NSString*)icon moduleID:(NSString*)moduleID onClick:(QCContactsHeaderItemClick)onClick{
    QCContactsHeaderItem *item = [[QCContactsHeaderItem alloc] init];
    item.sid = sid;
    item.title = title;
    item.icon = icon;
    item.moduleID = moduleID;
    item.onClick = onClick;
    return item;
}
@end
