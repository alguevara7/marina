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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let dict: CFDictionary = [promptFlag: true]
        AXIsProcessTrustedWithOptions(dict)
        
        
        NSWorkspace.sharedWorkspace().notificationCenter.addObserverForName(
            NSWorkspaceDidLaunchApplicationNotification, object: nil, queue: nil) { (aNotification:NSNotification!) -> Void in
                
                
                let runningApp: NSRunningApplication?  = aNotification.userInfo![NSWorkspaceApplicationKey] as? NSRunningApplication
                let pid: pid_t = runningApp!.processIdentifier
//                NSLog("app = %u", pid)
                //NSRunningApplication
                
                let app: Unmanaged<AXUIElementRef>! = AXUIElementCreateApplication(pid)
                print(app.takeRetainedValue())
                
                //AXIsTrustedProcess
                
                
                return
        }
        
        let context = JSContext()
        
        clojureScript = ClojureScript(ns:"marina.core", fn:"init!",
            context:context,
            jsPath:NSBundle.mainBundle().pathForResource("out/main", ofType: "js"))
        clojureScript!.bootstrap(NSBundle.mainBundle().pathForResource("out/goog/base", ofType: "js"))
        
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

