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
    func on(jsEventType: JSValue, _ jsListener: JSValue)
    
    static func allRunning() -> [Application]
    static func focused() -> Application?
    static func on(jsEventType: JSValue, _ jsListener: JSValue)
}


enum ApplicationEventType: String {
    case AppLaunched    = ":launched"
    case AppTerminated  = ":terminated"
    case AppHidden      = ":hidden"
    case AppUnhidden    = ":unhidden"
    case AppFocused     = ":focused"
    case AppUnfocused   = ":unfocused"
    
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

enum WindowEventType: String {
    case WindowCreated          = ":created"
    case WindowDestroyed        = ":destroyed"
    case WindowMoved            = ":moved"
    case WindowResized          = ":resized"
    case WindowMiniaturized     = ":miniaturized"
    case WindowDeminiaturized   = ":deminiaturized"
    case FocusedWindowChanged   = ":focused"
    case MainWindowChanged      = ":main-window-changed"
    case ApplicationHidden      = ":application-hidden"
    case ApplicationShown       = ":application-shown"
    case ApplicationActivated   = ":application-activated"
    case ApplicationDeactivated = ":application-deactivated"
    
    func name() -> String {
        switch self {
        case WindowCreated:        return kAXWindowCreatedNotification //FocusedWindowChanged is fired before WindowCreated 
        case WindowDestroyed:      return kAXUIElementDestroyedNotification
        case WindowMoved:          return kAXWindowMovedNotification
        case WindowResized:        return kAXWindowResizedNotification
        case WindowMiniaturized:   return kAXWindowMiniaturizedNotification
        case WindowDeminiaturized: return kAXWindowDeminiaturizedNotification
        case FocusedWindowChanged: return kAXFocusedWindowChangedNotification //element could be window or app (when there are no windows)
        case MainWindowChanged:    return kAXMainWindowChangedNotification
        case ApplicationHidden:    return kAXApplicationHiddenNotification
        case ApplicationShown:     return kAXApplicationShownNotification
        case ApplicationActivated: return kAXApplicationActivatedNotification
        case ApplicationDeactivated: return kAXApplicationDeactivatedNotification
        }
    }
}


@objc class Application : NSObject, ApplicationJSExport {
    dynamic var element: AXUIElement!
    
    var pid: pid_t {
        var pid: pid_t = 0
        AXUIElementGetPid(element, &pid)
        return pid
    }
    
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
            NSWorkspace.sharedWorkspace().notificationCenter.addObserverForName(eventType.name(), object: nil, queue: NSOperationQueue.mainQueue()) { notification in
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
    
    func on(jsEventType: JSValue, _ jsListener: JSValue) {
        
        let handler : @objc_block (AXObserver!, AXUIElement!, String!, UnsafeMutablePointer<Void>) -> Void = { (observer,elem,name, data) in
            jsListener.callWithArguments([jsEventType, Window(elem)])
        }
        
        let callback : AXObserverCallback = unsafeBitCast(
            imp_implementationWithBlock(unsafeBitCast(handler, AnyObject.self)),
            AXObserverCallback.self)
        
        let eventTypeRawValue = jsEventType.description;
        if let eventType = WindowEventType(rawValue: eventTypeRawValue) {
            var ob: Unmanaged<AXObserver>?
            var result = AXObserverCreate(pid, callback, &ob)
            if result != AXError(kAXErrorSuccess) {
                println("AXObserverCreate failed: code \(result)")
                return
            }
            if ob == nil {
                println("AXObserverCreate didn't do its job right")
                return
            }

            let observer = ob!.takeUnretainedValue()
            
            result = AXObserverAddNotification(observer, element, eventType.name(), nil)
            
            if result != AXError(kAXErrorSuccess) {
                println("AXObserverAddNotification failed: code \(result)")
                return
            }
            
            CFRunLoopAddSource(CFRunLoopGetCurrent(),
                AXObserverGetRunLoopSource(observer).takeRetainedValue(),
                kCFRunLoopDefaultMode)            
            
        }
    }
    
}




