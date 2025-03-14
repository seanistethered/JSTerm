//
//  ErrorThrow.m
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#import "ErrorThrow.h"

/*
 @Brief rewritten version of jsDoThrowError in ObjC
 */
JSValue* jsDoThrowError(JSContext *ctx, NSString *msg) {
    JSValue *error = [JSValue valueWithNewErrorFromMessage:msg inContext:ctx];
    [ctx setException:error];
    return error;
}
