//
//  NSObject_Extension.swift
//
//  Created by LawLincoln on 15/5/22.
//  Copyright (c) 2015年 LawLincoln. All rights reserved.
//

import Foundation

extension NSObject {
    class func pluginDidLoad(bundle: NSBundle) {
        let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
        if appName == "Xcode" {
        	if sharedPlugin == nil {
        		sharedPlugin = AutoUpdateDVTPlugInCompatibilityUUID(bundle: bundle)
        	}
        }
    }
}