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


@objc protocol ApplicationJSExport : JSExport {
    var title: String? { get }
    var windows: [Window]? { get }
    
    static func allRunning() -> [Application]
}

@objc class Application : NSObject, ApplicationJSExport {
    dynamic var element: AXUIElement!
    
    init(_ element: AXUIElement!) {
        self.element = element
    }

    class func allRunning() -> [Application] {
        return (NSWorkspace.sharedWorkspace().runningApplications as! [NSRunningApplication]).map(toApplication)
    }

    internal class func toApplication(app: NSRunningApplication) -> Application {
        let pid = app.processIdentifier
        let elementRef: Unmanaged<AXUIElementRef>! = AXUIElementCreateApplication(pid)
        let element = elementRef.takeRetainedValue()
        return Application(element)
    }

    var title: String? {
        get {
           return element.getAttribute(NSAccessibilityTitleAttribute) as String?
        }
    }
    
    var windows: [Window]? {
        get {
            return (element.getAttributes("AXWindows") as [AXUIElement]?)?.map{ Window($0) }
        }
    }
    
}