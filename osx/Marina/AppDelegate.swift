//
//  AppDelegate.swift
//  Marina
//
//  Created by Guevara, Alexei on 6/30/15.
//  Copyright (c) 2015 zb0th. All rights reserved.
//

import Cocoa
import JavaScriptCore
import AppKit
import ApplicationServices
import CoreFoundation


/*

registerWindowListener()

WindowListener {
    opened
    closed
    minimized
    restored (from minimized or maximized)
    maximized
    focused
}

setWindowSize
setWindowPosition

... move to other desktop

... implement focus follows mouse

... when an app exists, close events for all its windows will be fired

... each window has a layout

*/

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var clojureScript : ClojureScript?
    
    func title(element: AXUIElement!) -> String? {
        return element.getAttribute(NSAccessibilityTitleAttribute)
    }
    
    class func allApps() -> [NSRunningApplication] {
        return (NSWorkspace.sharedWorkspace().runningApplications as! [NSRunningApplication])
    }
    

    func allWindows(element: AXUIElement?) -> [AXUIElement]? {
        return (element?.getAttributes("AXWindows") as [AXUIElement]?)
    }

    func mainWindow(element: AXUIElement?) -> AXUIElement? {
        return element?.getAttribute("AXMainWindow")
    }
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let dict: CFDictionary = [promptFlag: true]
        AXIsProcessTrustedWithOptions(dict)
        
        NSWorkspace.sharedWorkspace().runningApplications
        
        NSWorkspace.sharedWorkspace().notificationCenter.addObserverForName(
            NSWorkspaceDidLaunchApplicationNotification, object: nil, queue: nil) { (aNotification:NSNotification!) -> Void in
                
                
                let runningApp: NSRunningApplication?  = aNotification.userInfo![NSWorkspaceApplicationKey] as? NSRunningApplication
                let pid: pid_t = runningApp!.processIdentifier
//                NSLog("app = %u", pid)
                //NSRunningApplication
                
                //AXIsTrustedProcess
                
                let app: Unmanaged<AXUIElementRef>! = AXUIElementCreateApplication(pid)
                let appAXUIElement = app.takeRetainedValue()
                print(self.title(appAXUIElement))
        }
        
        let context = JSContext()
        
//        [[NSBundle mainBundle] pathForResource:@"out/main" ofType:@"js"]]
        
        clojureScript = ClojureScript(ns:"marina.core", fn:"init!",
            context:context,
            jsPath:NSBundle.mainBundle().pathForResource("out/main", ofType: "js"))
        clojureScript!.bootstrap()
        
        
//        for app in Application.allRunning() {
//            if let windows = app.windows {
//                for window in windows {
//                    println("\(window.title) -> \(window.position) - \(window.size)")
//                }
//                
//            }
//        }
        
//        context.evaluateScript("var num = 5 + 5")
//        context.evaluateScript("var names = ['Grace', 'Ada', 'Margaret']")
//        context.evaluateScript("var triple = function(value) { return value * 3 }")
//        let tripleNum: JSValue = context.evaluateScript("triple(num)")
//        
//        println(tripleNum)
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

