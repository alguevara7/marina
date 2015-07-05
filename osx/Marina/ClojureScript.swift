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
        
        context.evaluateScript("console.log('HI!!!!')")
        
        if let jsString = String(contentsOfFile:jsPath, encoding:NSUTF8StringEncoding, error:nil) {
            context.evaluateScript(jsString, withSourceURL: NSURL(fileURLWithPath: jsPath))
            
//            JSValue* initFn = [self getValue:initFnName inNamespace:namespace];
//            
//            [initFn callWithArguments:@[@{@"debug-build": @(debugBuild),
//            @"target-simulator": @(targetSimulator),
//            @"user-interface-idiom": (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"iPad": @"iPhone")}]];
            
            let initFn : JSValue = context
                .objectForKeyedSubscript("marina")
                .objectForKeyedSubscript("core")
                .objectForKeyedSubscript("init_BANG_")
                
//                .objectForKeyedSubscript("core").objectForKeyedSubscript("init!")
            
            if initFn.isUndefined() {
                println("NOOOOO!!!")
            }
            
            initFn.callWithArguments([["key":"value"]])
            
        }
    }
    
//    + (NSString*)munge:(NSString*)s
//    {
//    return [[[s stringByReplacingOccurrencesOfString:@"-" withString:@"_"]
//    stringByReplacingOccurrencesOfString:@"!" withString:@"_BANG_"]
//    stringByReplacingOccurrencesOfString:@"?" withString:@"_QMARK_"];
//    }
    
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
    
    
}
