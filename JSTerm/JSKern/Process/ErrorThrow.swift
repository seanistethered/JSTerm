//
//  ErrorThrow.swift
//  JSTerm
//
//  Created by fridakitten on 13.03.25.
//

import JavaScriptCore

/*
 @Brief a helper function for more debugging of JSBinaries
 */
func jsDoThrowError(_ error: String) -> JSValue {
    let error = JSValue(newErrorFromMessage: error, in: JSContext.current())!
    JSContext.current()?.exception = error
    return JSValue(undefinedIn: JSContext.current())!
}
