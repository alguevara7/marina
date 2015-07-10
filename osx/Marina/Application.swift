//
//  Application.swift
//  Marina
//
//  Created by Guevara, Alexei on 7/7/15.
//  Copyright (c) 2015 zb0th. All rights reserved.
//

import Foundation
import JavaScriptCore
import Cocoa

internal let systemWideElement = AXUIElementCreateSystemWide()!.takeRetainedValue()

@objc protocol ApplicationJSExport : JSExport {
    var title: String { get }
    var windows: [Window]? { get }
    var focusedWindow: Window? { get }
    
    static func allRunning() -> [Application]
    static func focused() -> Application?
    static func on(eventType: JSValue, _ listener: JSValue)
}


enum ApplicationEventType: String {
    case AppLaunched = ":launched"
    case AppTerminated = ":terminated"
    case AppHidden = ":hidden"
    case AppUnhidden = ":unhidden"
    case AppFocused = ":focused"
    case AppUnfocused = ":unfocused"
    
    func name() -> String {
        switch self {
        case AppLaunched: return NSWorkspaceDidLaunchApplicationNotification
        case AppTerminated: return NSWorkspaceDidTerminateApplicationNotification
        case AppHidden: return NSWorkspaceDidHideApplicationNotification
        case AppUnhidden: return NSWorkspaceDidUnhideApplicationNotification
        case AppFocused: return NSWorkspaceDidActivateApplicationNotification
        case AppUnfocused: return NSWorkspaceDidDeactivateApplicationNotification
        }
    }
}

@objc class Application : NSObject, ApplicationJSExport {
    dynamic var element: AXUIElement!
    
    init(_ element: AXUIElement!) {
        self.element = element
    }

    class func allRunning() -> [Application] {
        return (NSWorkspace.sharedWorkspace().runningApplications as! [NSRunningApplication]).map(toApplication)
    }

    class func focused() -> Application? {
        return Application(systemWideElement.getAttribute("AXFocusedApplication"))
    }
    
    class func on(jsEventType: JSValue, _ jsListener: JSValue) {
        let eventTypeRawValue = jsEventType.description;
        if let eventType = ApplicationEventType(rawValue: eventTypeRawValue) {
            let observer = NSWorkspace.sharedWorkspace().notificationCenter.addObserverForName(eventType.name(), object: nil, queue: NSOperationQueue.mainQueue()) { notification in
                if let dict = notification.userInfo {
                    if let runningApp: NSRunningApplication = dict[NSWorkspaceApplicationKey] as? NSRunningApplication {
                        jsListener.callWithArguments([jsEventType, Application.toApplication(runningApp)])
                    }
                }
            }
            
        }
    }
    
    private class func toApplication(app: NSRunningApplication) -> Application {
        let pid = app.processIdentifier
        let elementRef: Unmanaged<AXUIElementRef>! = AXUIElementCreateApplication(pid)
        let element = elementRef.takeRetainedValue()
        return Application(element)
    }

    var title: String {
        get {
           return (element.getAttribute(NSAccessibilityTitleAttribute) as String?) ?? ""
        }
    }
    
    var windows: [Window]? {
        get {
            return (element.getAttributes(NSAccessibilityWindowsAttribute) as [AXUIElement]?)?.map{ Window($0) }
        }
    }
    
    var focusedWindow: Window? {
        get {
            return Window(element.getAttribute(NSAccessibilityFocusedWindowAttribute))
        }
    }
    
}