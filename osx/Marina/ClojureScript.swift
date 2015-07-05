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
    
    func bootstrap(googPath: String!) {
        self.setUpExceptionLogging(context)
        self.setUpConsoleLog(context)
        
//        goog/base.js
        if let googString = String(contentsOfFile:googPath, encoding:NSUTF8StringEncoding, error:nil) {
            context.evaluateScript(googString, withSourceURL: NSURL(fileURLWithPath: googPath))
        }
        
        if let jsString = String(contentsOfFile:jsPath, encoding:NSUTF8StringEncoding, error:nil) {
            context.evaluateScript(jsString, withSourceURL: NSURL(fileURLWithPath: jsPath))
            
            var listener1 : JSValue?
            
            self.bind("subscribe", fn:{ (listener:JSValue) -> Void in
                listener1 = listener
            })
            
            context.evaluateScript("CLOSURE_IMPORT_SCRIPT = function(src) { AMBLY_IMPORT_SCRIPT('goog/' + src); return true; }")
            
            context.evaluateScript("goog.isProvided_ = function(x) { return false; };")
            
            context.evaluateScript("goog.require = function (name) { return CLOSURE_IMPORT_SCRIPT(goog.dependencies_.nameToPath[name]); };")
            
            context.evaluateScript("goog.require('cljs.core');")
            
            context.evaluateScript("goog.require('marina.core');")
            
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
            
            listener1?.callWithArguments([["type":"window-open"]])
            
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
    
    func bind(keyedSubscript: String, fn: JSValue -> Void) {
        let objcBlock: @objc_block JSValue -> Void = fn
        
        context.setObject(
            unsafeBitCast(objcBlock, AnyObject.self),
            forKeyedSubscript: keyedSubscript)
    }
    
}
