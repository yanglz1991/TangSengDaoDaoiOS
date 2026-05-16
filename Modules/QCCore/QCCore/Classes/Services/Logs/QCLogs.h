//
//  ViewController.h
//  TalkClient3
//
//  Created by tt on 2018/9/3.
//  Copyright © 2018年 aiti. All rights reserved.
//
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <UIKit/UIKit.h>

// 日志等级
static  DDLogLevel ddLogLevel = DDLogLevelAll;

@interface QCLogsManager : NSObject

+(void) setup:(nullable NSString*)logsDirectory;

@end

#ifndef __OPTIMIZE__ // DEBUG模式
    #define QCLogInfo(fmt,...)  NSLog(fmt,##__VA_ARGS__)
    #define QCLogDebug(fmt,...)  NSLog(fmt,##__VA_ARGS__)
    //#define QCLogVerbose(fmt,...)  DDLogVerbose(fmt,##__VA_ARGS__)
    #define QCLogError(fmt,...)  NSLog(fmt,##__VA_ARGS__)
    #define QCLogWarn(fmt,...)  NSLog(fmt,##__VA_ARGS__)
#else
    #define QCLogInfo(fmt,...)  NSLog(fmt,##__VA_ARGS__)
    #define QCLogDebug(fmt,...)  NSLog(fmt,##__VA_ARGS__)
    //#define QCLogVerbose(fmt,...)  DDLogVerbose(fmt,##__VA_ARGS__)
    #define QCLogError(fmt,...)  NSLog(fmt,##__VA_ARGS__)
    #define QCLogWarn(fmt,...)  NSLog(fmt,##__VA_ARGS__)
#endif
