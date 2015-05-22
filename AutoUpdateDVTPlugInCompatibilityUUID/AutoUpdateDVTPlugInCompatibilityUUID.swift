//
//  AutoUpdateDVTPlugInCompatibilityUUID.swift
//
//  Created by LawLincoln on 15/5/22.
//  Copyright (c) 2015年 LawLincoln. All rights reserved.
//

import AppKit
//E969541F-E6F9-4D25-8158-72DC3545A6C6
let pluginDir = "/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
let infoPlist = "/Contents/info.plist"
let configureDirectory = "/Library/Application Support/SelfStudio/"

var sharedPlugin: AutoUpdateDVTPlugInCompatibilityUUID?

class AutoUpdateDVTPlugInCompatibilityUUID: NSObject {
    var bundle: NSBundle

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.startChecking()
        })
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

extension AutoUpdateDVTPlugInCompatibilityUUID {
    func pluginPath()->String{
        let pluginsHome = NSHomeDirectory().stringByAppendingPathComponent(pluginDir)
        return pluginsHome
    }
    func startChecking(){
        let fm = NSFileManager.defaultManager()
        var isDir: ObjCBool = true
        let aPath = self.pluginPath()
        if fm.fileExistsAtPath(aPath, isDirectory: &isDir) {
            if let files = fm.contentsOfDirectoryAtPath(aPath, error: nil) as? [String]{
                var fielsToDeal = [String]()
                for item in files {
                    if item.hasSuffix(".xcplugin") {
                        fielsToDeal.append(item)
                    }
                }
                
                updateDVTPlugInCompatibilityUUIDFor(fielsToDeal)
            }
            
        }
    }
    
    func appConfigure()->String{
        let dir = NSHomeDirectory().stringByAppendingPathComponent(configureDirectory)
        let fm = NSFileManager.defaultManager()
        var isDir : ObjCBool = true
        if !fm.fileExistsAtPath(dir, isDirectory: &isDir) {
            fm.createDirectoryAtPath(dir, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
        var configureFile = dir.stringByAppendingPathComponent("UpdatePluginConf")
        return configureFile
    }
    
    func updateDVTPlugInCompatibilityUUIDFor(items:[String]){
        let aPath = self.pluginPath()
        let updatedArray = NSArray(contentsOfFile: appConfigure())
        var updatedMap = [String]()
        if let oldMap = updatedArray as? [String] {
            for item in oldMap {
                updatedMap.append(item)
            }
        }
         let currentVersionInfofile = NSMutableDictionary(contentsOfFile: "/Applications/Xcode.app/Contents/Info.plist")
        for item in items {
            var infoFile = aPath.stringByAppendingPathComponent(item+infoPlist)
            if let dict = NSMutableDictionary(contentsOfFile: infoFile),
                let ids = dict["DVTPlugInCompatibilityUUIDs"] as? [String],
            let currentKey  = currentVersionInfofile?["DVTPlugInCompatibilityUUID"] as? String {
                
                let pluginIdentifier = dict["CFBundleIdentifier"] as! String
                
                if let arr = updatedArray {
                    if arr.containsObject(pluginIdentifier) {
                        println("😘 😘 😘 😘 😘 skip for :\(pluginIdentifier)")
                        continue
                    }
                }
                
                
                println("😘 😘 😘 😘 😘currentKey:\(currentKey)")
                var modifyOne = ids
                
                var needUpdate = true
                for item in modifyOne {
                    if item == currentKey {
                        if !(updatedMap as NSArray).containsObject(pluginIdentifier) {
                            updatedMap.append(pluginIdentifier)
                        }
                        needUpdate = false
                        break
                    }
                }
                
                if needUpdate {
                    modifyOne.append(currentKey)
                    var toSaveDict = dict
                    toSaveDict["DVTPlugInCompatibilityUUIDs"] = modifyOne
                    (toSaveDict as NSDictionary).writeToFile(infoFile, atomically: true)
                    println("💋‍💋‍💋‍💋‍💋‍update for :\(pluginIdentifier)")
                }
            }
        }
        (updatedMap as NSArray).writeToFile(appConfigure(), atomically: true)
    }
}