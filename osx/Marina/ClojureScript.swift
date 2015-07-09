//
//  ClojureScript.swft.swift
//  Marina
//
//  Created by Guevara, Alexei on 7/2/15.
//  Copyright (c) 2015 zb0th. All rights reserved.
//

import Foundation
import JavaScriptCore

class ClojureScript {
    var ns: String
    var fn: String
    var context: JSContext
    var jsPath: String
    
    init(ns: String, fn: String, context: JSContext, jsPath: String!) {
        self.ns = ns
        self.fn = fn
        self.context = context
        self.jsPath = jsPath
    }
    
    func bootstrap() {
        self.setUpExceptionLogging(context)
        self.setUpConsoleLog(context)
        
        setUpClosureImportScript(context)
        
        setUpNativeBridge(context)

        let basePath = NSBundle.mainBundle().pathForResource("out/goog/base", ofType: "js")!
        context.evaluateScript(
            String(contentsOfFile:basePath, encoding:NSUTF8StringEncoding, error:nil),
            withSourceURL: NSURL(fileURLWithPath: basePath))
        
        context.evaluateScript(
            String(contentsOfFile:jsPath, encoding:NSUTF8StringEncoding, error:nil),
            withSourceURL: NSURL(fileURLWithPath: jsPath))
        
        context.setObject(Application.self, forKeyedSubscript: "Application")
        context.setObject(Point.self, forKeyedSubscript: "Point")
        context.setObject(Size.self, forKeyedSubscript: "Size")

        context.evaluateScript("goog.require('\(ns)');")
        
        let initFn : JSValue = context
            .objectForKeyedSubscript("marina")
            .objectForKeyedSubscript("core")
            .objectForKeyedSubscript("init_BANG_")
        
        if initFn.isUndefined() {
            println("NOOOOO!!!")
            exit(1)
        }
        
        //[{:app-title "foo" :windows []}]
        
        initFn.callWithArguments([["key":"value"]])
        
    }
    
    private func setUpExceptionLogging(context: JSContext) {
        context.exceptionHandler = { (context:JSContext!, exception: JSValue!) -> Void in
            let sourceURL = exception.objectForKeyedSubscript("sourceURL"),
                line = exception.objectForKeyedSubscript("line"),
                column = exception.objectForKeyedSubscript("column"),
                stack = exception.objectForKeyedSubscript("stack")
            
            println("[\(sourceURL):\(line):\(column)] \(exception)\n\(stack)")
        }
    }
    
    private func setUpConsoleLog(context: JSContext) {
        context.evaluateScript("var console = {}")
        
        let log: @objc_block String -> Void = { (message: String) -> Void in
            println("JS: \(message)")
        }
        
        context.objectForKeyedSubscript("console").setObject(
            unsafeBitCast(log, AnyObject.self),
            forKeyedSubscript: "log")
        
    }
    
    private func setUpClosureImportScript(context: JSContext) {
        let importScript: @objc_block String -> Bool = { (path: String) -> Bool in
            println("Loading: \(path)");
            
            let nativePath = NSBundle.mainBundle().pathForResource("out/goog/" + path, ofType: nil)!
            context.evaluateScript(
                String(contentsOfFile:nativePath, encoding:NSUTF8StringEncoding, error:nil),
                withSourceURL: NSURL(fileURLWithPath: nativePath))
            
            return true
        }
        
        context.setObject(
            unsafeBitCast(importScript, AnyObject.self),
            forKeyedSubscript: "CLOSURE_IMPORT_SCRIPT")
        
    }
    

    private func setUpNativeBridge(context: JSContext) {
        context.evaluateScript("var marina = {}")
        
        let subscribe: @objc_block (JSValue, JSValue) -> Void = { (eventType: JSValue, fn: JSValue) -> Void in
            println("SUBSCRIBE")
            println(eventType.objectForKeyedSubscript("name"))
            
            fn.callWithArguments(["Hola muchachos :)"])
        }
        
        context.objectForKeyedSubscript("marina").setObject(
            unsafeBitCast(subscribe, AnyObject.self),
            forKeyedSubscript: "subscribe")
    }
    
    
    //    + (NSString*)munge:(NSString*)s
    //    {
    //    return [[[s stringByReplacingOccurrencesOfString:@"-" withString:@"_"]
    //    stringByReplacingOccurrencesOfString:@"!" withString:@"_BANG_"]
    //    stringByReplacingOccurrencesOfString:@"?" withString:@"_QMARK_"];
    //    }
    
    
}
