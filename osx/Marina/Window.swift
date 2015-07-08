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


@objc protocol WindowJSExport : JSExport {
    var title: String? { get }
    var position: Point? { get }
    var size: Size? { get }
}

@objc class Window : NSObject, WindowJSExport {
    dynamic var element: AXUIElement!
    
    init(_ element: AXUIElement!) {
        self.element = element
    }
    
    var title: String? {
        get {
            return element.getAttribute(NSAccessibilityTitleAttribute) as String?
        }
    }

    var position: Point? {
        get {
            let _point = (element.getAttribute(NSAccessibilityPositionAttribute) as AXValue?)?.convertToStruct() as NSPoint?
            return Point.createFromNSPoint(_point)
        }
    }
    
    var size: Size? {
        get {
            let _size = (element.getAttribute(NSAccessibilitySizeAttribute) as AXValue?)?.convertToStruct() as NSSize?
            return Size.createFromNSSize(_size)
        }
    }
    
}

@objc protocol PointJSExport : JSExport {
    var x: NSNumber { get }
    var y: NSNumber { get }
    var description: String { get }
}

@objc class Point : NSObject, PointJSExport, Printable {
    dynamic var x: NSNumber
    dynamic var y: NSNumber
    
    init(_ x: NSNumber, _ y: NSNumber) {
        self.x = x
        self.y = y
    }
    
    class func createFromNSPoint(point: NSPoint?) -> Point? {
        if let p = point {
            return Point(p.x, p.y)
        } else {
            return nil
        }
    }
    
    override var description: String {
        get {
            return "x:\(x), y:\(y)"
        }
    }
    
}

@objc protocol SizeJSExport : JSExport {
    var width: NSNumber { get }
    var height: NSNumber { get }
    var description: String { get }
}

@objc class Size : NSObject, SizeJSExport, Printable {
    dynamic var width: NSNumber
    dynamic var height: NSNumber
    
    init(_ width: NSNumber, _ height: NSNumber) {
        self.width = width
        self.height = height
    }
    
    class func createFromNSSize(size: NSSize?) -> Size? {
        if let s = size {
            return Size(s.width, s.height)
        } else {
            return nil
        }
    }
    
    override var description: String {
        get {
            return "width:\(width), height:\(height)"
        }
    }
    
}