//
//  QCSwiftModuleManager.swift
//  QCUsernameLogin
//
//  Created by tt on 2023/9/8.
//

import Foundation

@objc open class QCSwiftModuleManager:NSObject {
    @objc public static let shared = QCSwiftModuleManager()
    private var modules:[String: QCModuleProtocol] = [:]
    
    var moduleContext: QCModuleContext = QCModuleContext()
    
  
    
    @objc public func registerModule(_ module:QCModuleProtocol) {
        self.modules[module.moduleId()] = module
    }
    
    @objc public func getAllModules() -> [QCModuleProtocol] {
        var modules:[QCModuleProtocol] = []
        for v in self.modules.values {
            modules.append(v)
        }
       let newModules = modules.sorted { obj1, obj2 in
            if obj1.moduleType() != QCModuleTypeResource && obj2.moduleType() == QCModuleTypeResource {
                    return true
                }
                
                if obj1.moduleType() == QCModuleTypeResource && obj2.moduleType() != QCModuleTypeResource {
                    return false
                }
                
                if obj2.moduleSort() > obj1.moduleSort() {
                    return true
                }
                
                return false
        }
        return newModules
        
    }
    
    @objc public func getModuleWithId(_ moduleId:String) ->QCModuleProtocol? {
        return self.modules[moduleId]
    }
    
   @objc public func getResourceModules() -> [QCModuleProtocol] {
        var resourceModules: [QCModuleProtocol] = []
        let modules = getAllModules()
        if !modules.isEmpty {
            for module in modules {
                if module.moduleType() == QCModuleTypeResource {
                    resourceModules.append(module)
                }
            }
        }
        return resourceModules
    }
    
    @objc public func didModuleInit() {
        let modules = getAllModules()
        if !modules.isEmpty {
            for module in modules {
                // 模块初始化
                module.moduleInit?(moduleContext)
            }
        }
    }
    
    @objc public func didFinishLaunching() -> Bool {
        let modules = getAllModules()
        if  !modules.isEmpty {
            for module in modules {
                module.moduleDidFinishLaunching?(moduleContext)
            }
        }
        return true
    }
    
    @objc public  func didDatabaseLoad() {
        let modules = getAllModules()
        for module in modules {
            module.moduleDidDatabaseLoad?(moduleContext)
        }
    }
    
    @objc public func didOpen(_ url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let modules = getAllModules()
        for module in modules {
            let open = module.moduleOpen?(url, options: options)
            if open ?? false {
                return open ?? false
            }
        }
        return false
    }
    
    @objc public func didContinue(_ userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let modules = getAllModules()
        for module in modules {
            let open = module.moduleContinue?(userActivity, restorationHandler: restorationHandler)
            if open ?? false {
                return open ?? false
            }
        }
        return false
    }
    
    @objc public  func moduleDidReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let modules = getAllModules()
        for module in modules {
            module.moduleDidReceiveRemoteNotification?(userInfo, fetchCompletionHandler: completionHandler)
        }
    }
        
}
