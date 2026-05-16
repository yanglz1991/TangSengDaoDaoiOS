//
//  QCBaseModule.m
//  QCCore
//
//  Created by tt on 2019/12/1.
//

#import "QCBaseModule.h"
#import "QCResource.h"
#import "QCApp.h"
#import "QCResource.h"
#import "QCModuleManager.h"
#import <QCCore/QCCore-Swift.h>
@implementation QCBaseModule


+ (NSString *)globalID {
    return @"";
}

- (QCModuleType)moduleType {
    return QCModuleTypeDefault;
}

- (NSInteger)moduleSort {
    return 0;
}

- (UIImage*) ImageForResource:(NSString*)name{
    UIImage *img;
    NSArray<id<QCModuleProtocol>> *resourceModules = [QCSwiftModuleManager.shared getResourceModules];
    if(resourceModules && resourceModules.count>0) {
        resourceModules = resourceModules.reverseObjectEnumerator.allObjects;
        for (id<QCModuleProtocol> module in resourceModules) {
            img =   [QCResource.shared imageNamed:[[self moduleId] stringByAppendingPathComponent:name] inBundle:[module imageBundle]];
            if(img) {
                return img;
            }
        }
    }
    
    img =   [QCResource.shared imageNamed:name inBundle:[self imageBundle]];
    if(img) {
        return img;
    }
    
    
    return nil;
}

-(NSDictionary*) LangResource:(NSString*)lang{
    NSString *langFileName = lang;
    if ([lang isEqualToString:@"zh-Hans-CN"]) {
        langFileName = @"zh-Hans";
    }
    NSString *langUrl = [self pathForResource:[NSString stringWithFormat:@"lang/%@.lproj/Localized",langFileName] ofType:@"strings"];
    NSDictionary *langDic = [[NSDictionary alloc] initWithContentsOfFile:langUrl];
    return langDic;
}

- (nullable NSString *)pathForResource:(nullable NSString *)name ofType:(nullable NSString *)ext{
    return [[self resourceBundle] pathForResource:name ofType:ext];
}
- (NSBundle*) resourceBundle{
    NSBundle *bundle = [QCResource.shared resourceBundleInClass:self.class];
    if(bundle) {
        return bundle;
    }
    bundle = [NSBundle bundleForClass:self.class];
    NSURL *url = [bundle URLForResource:[NSString stringWithFormat:@"%@_resources",[self moduleId]] withExtension:@"bundle"];
    return [NSBundle bundleWithURL:url];
}

- (NSBundle*) imageBundle{
    NSBundle *bundle = [QCResource.shared imageBundleInClass:self.class];
    if(bundle) {
        return bundle;
    }
    bundle = [NSBundle bundleForClass:self.class];
    NSURL *url = [bundle URLForResource:[NSString stringWithFormat:@"%@_images",[self moduleId]] withExtension:@"bundle"];
    if(url) {
        return [NSBundle bundleWithURL:url];
    }
    
    return nil;
}

-(NSString*) moduleId{
    
    return [self.class globalID];
}


- (UIImage *)at_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle  {
    UITraitCollection *trait;
    NSString *mode = [QCApp shared].loginInfo.extra[@"systemStyle"];
     if(mode && [mode isEqualToString:@"dark"]) {
         if (@available(iOS 12.0, *)) {
             trait = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark];
         }
     }else{
         if (@available(iOS 12.0, *)) {
             trait = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight];
         }
        
     }
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:trait];
}

-(void) setMethod:(NSString*)sid handler:(id) handler category:(NSString*)category {
    QCEndpoint *endpoint = [QCEndpoint initWithSid:sid handler:handler category:category];
    endpoint.moduleID = [self moduleId];
    [self registerEndpoint:endpoint];
}

-(void) setMethod:(NSString*)sid handler:(id) handler category:(NSString* __nullable)category sort:(int)sort {
    QCEndpoint *endpoint = [QCEndpoint initWithSid:sid handler:handler category:category sort:@(sort)];
    endpoint.moduleID = [self moduleId];
     [self registerEndpoint:endpoint];
}

-(void) setMethod:(NSString*)sid handler:(id) handler {
    [self setMethod:sid handler:handler category:nil];
}

-(void) registerEndpoint:(QCEndpoint*)endpoint {
    
    [QCApp.shared.endpointManager registerEndpoint:endpoint];
}

@end
