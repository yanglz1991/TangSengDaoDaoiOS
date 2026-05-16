//
//  QCModuleManager.m
//  WuKongBase
//
//  Created by tt on 2019/12/1.
//

#import "QCModuleManager.h"
#import "QCApp.h"
#import <WuKongBase/WuKongBase-Swift.h>
@interface QCModuleManager ()
@property(nonatomic,strong) NSMutableDictionary<NSString*,id<QCModuleProtocol>> *moduleMap;
@property(nonatomic,strong) NSLock *lock;
@property(nonatomic,strong) QCModuleContext *moduleContext;
@end

@implementation QCModuleManager

static QCModuleManager *_instance;


+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCModuleManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.moduleMap = [NSMutableDictionary dictionary];
        _instance.lock = [[NSLock alloc] init];
        
    });
    return _instance;
}

-(void) registerModule:(id<QCModuleProtocol>) moduleProtocol{
    [self.lock lock];
    NSString *moduleId = [moduleProtocol moduleId];
    [self.moduleMap setObject:moduleProtocol forKey:moduleId];
    [self.lock unlock];
}

-(NSArray<id<QCModuleProtocol>>*) getAllModules {
    [self.lock lock];
    NSArray<id<QCModuleProtocol>>* objcModules = self.moduleMap.allValues;
    
    
    NSMutableArray *modules = [[NSMutableArray alloc] init];
    [modules addObjectsFromArray:objcModules];
    
    
    // 资源模块排到最前
   NSArray<id<QCModuleProtocol>> *newmodules = [modules sortedArrayUsingComparator:^NSComparisonResult(id<QCModuleProtocol>  _Nonnull obj1, id<QCModuleProtocol>  _Nonnull obj2) {
        
        if([obj1 moduleType] != QCModuleTypeResource && [obj2 moduleType] == QCModuleTypeResource) {
            return NSOrderedDescending;
        }
        
        if([obj1 moduleType] == QCModuleTypeResource && [obj2 moduleType] != QCModuleTypeResource) {
            return NSOrderedAscending;
        }
        
        if([obj2 moduleSort]>[obj1 moduleSort]) {
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];
    
    [self.lock unlock];
    return newmodules;
}

-(NSArray<id<QCModuleProtocol>>*) getResourceModules {
    NSMutableArray<id<QCModuleProtocol>> *resourceModules = [NSMutableArray array];
    NSArray<id<QCModuleProtocol>> *modules = [self getAllModules];
    if(modules && modules.count>0) {
        for (id<QCModuleProtocol> module in modules) {
            if([module moduleType] == QCModuleTypeResource) {
                [resourceModules addObject:module];
            }
        }
    }
    return resourceModules;
}

-(id<QCModuleProtocol>) getModuleWithId:(NSString*)moduleId{
    [self.lock lock];
    id<QCModuleProtocol> module = self.moduleMap[moduleId];
    [self.lock unlock];
    return module;
}

-(void) didModuleInit {
    NSArray<id<QCModuleProtocol>> *modules = [self getAllModules];
    if(modules&&modules.count>0) {
        for (id<QCModuleProtocol> module in modules) {
            // 模块初始化
            if([module respondsToSelector:@selector(moduleInit:)]) {
                [module moduleInit:self.moduleContext];
            }
            
        }
    }
    
}

-(QCModuleContext*) moduleContext {
    if(!_moduleContext) {
        _moduleContext = [QCModuleContext new];
    }
    return _moduleContext;
}

- (BOOL)didFinishLaunching{
    NSArray<id<QCModuleProtocol>> *modules = [self getAllModules];
    if(modules && modules.count>0) {
        for (id<QCModuleProtocol> module in modules) {
            if([module respondsToSelector:@selector(moduleDidFinishLaunching:)]) {
                [module moduleDidFinishLaunching:self.moduleContext];
            }
        }
    }
    return YES;
}

-(BOOL) didOpenURL:(NSURL*)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSArray<id<QCModuleProtocol>> *modules = [self getAllModules];
    for (id<QCModuleProtocol> module in modules) {
        if([module respondsToSelector:@selector(moduleOpenURL:options:)]) {
            BOOL open = [module moduleOpenURL:url options:options];
            if(open) {
                return open;
            }
        }
    }
    return NO;
}

-(BOOL) didContinueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    NSArray<id<QCModuleProtocol>> *modules = [self getAllModules];
    for (id<QCModuleProtocol> module in modules) {
        if([module respondsToSelector:@selector(didContinueUserActivity:restorationHandler:)]) {
            BOOL open = [module moduleContinueUserActivity:userActivity restorationHandler:restorationHandler];
            if(open) {
                return open;
            }
        }
    }
    return NO;
}


- (void)moduleDidReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSArray<id<QCModuleProtocol>> *modules = [self getAllModules];
    for (id<QCModuleProtocol> module in modules) {
        if([module respondsToSelector:@selector(moduleDidReceiveRemoteNotification:fetchCompletionHandler:)]) {
            [module moduleDidReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
        }
    }
}

-(void) didDatabaseLoad {
    NSArray<id<QCModuleProtocol>> *modules = [self getAllModules];
    for (id<QCModuleProtocol> module in modules) {
        if([module respondsToSelector:@selector(moduleDidDatabaseLoad:)]) {
            [module moduleDidDatabaseLoad:self.moduleContext];
        }
    }
}


@end
