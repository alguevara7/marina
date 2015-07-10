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
    var title: String { get }
    var role: String { get }
    var position: PointJSExport? { get set }
    var size: SizeJSExport? { get set }
}

@objc class Window : NSObject, WindowJSExport {
    dynamic var element: AXUIElement?
    
    init(_ element: AXUIElement?) {
        self.element = element
    }
    
    var title: String {
        get {
            return (element?.getAttribute(NSAccessibilityTitleAttribute) as String?) ?? ""
        }
    }

    var role: String {
        get {
            return (element?.getAttribute(NSAccessibilityRoleAttribute) as String?) ?? ""
        }
    }

    var subrole: String {
        get {
            return (element?.getAttribute(NSAccessibilitySubroleAttribute) as String?) ?? ""
        }
    }
    
    var position: PointJSExport? {
        get {
            let _point = (element?.getAttribute(NSAccessibilityPositionAttribute) as AXValue?)?.convertToStruct() as NSPoint?
            return Point.createFromNSPoint(_point)
        }
        set(newPosition) {
            if let p = newPosition {
                let x: CGFloat = CGFloat(p.x.floatValue)
                let y: CGFloat = CGFloat(p.y.floatValue)
                element?.setAttribute(NSAccessibilityPositionAttribute, value: AXValue.fromPoint(NSPoint(x:x, y:y)))
            }
        }
    }
    
    var size: SizeJSExport? {
        get {
            let _size = (element?.getAttribute(NSAccessibilitySizeAttribute) as AXValue?)?.convertToStruct() as NSSize?
            return Size.createFromNSSize(_size)
        }
        set(newSize) {
            if let s = newSize {
                let width: CGFloat = CGFloat(s.width.floatValue)
                let height: CGFloat = CGFloat(s.height.floatValue)
                element?.setAttribute(NSAccessibilitySizeAttribute, value: AXValue.fromSize(NSSize(width:width, height:height)))
            }
        }

    }
    
}

@objc protocol PointJSExport : JSExport {
    var x: NSNumber { get }
    var y: NSNumber { get }
    var description: String { get }
    
    static func createFromXY(x: NSNumber, _ y: NSNumber) -> Point
}

@objc class Point : NSObject, PointJSExport, Printable {
    dynamic var x: NSNumber
    dynamic var y: NSNumber
    
    init(_ x: NSNumber, _ y: NSNumber) {
        self.x = x
        self.y = y
    }
    
    class func createFromXY(x: NSNumber, _ y: NSNumber) -> Point {
        return Point(x, y)
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
    
    static func createFromWidthHeight(width: NSNumber, _ height: NSNumber) -> Size
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
    
    class func createFromWidthHeight(width: NSNumber, _ height: NSNumber) -> Size {
        return Size(width, height)
    }
    
    override var description: String {
        get {
            return "width:\(width), height:\(height)"
        }
    }
    
}