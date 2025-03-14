//
//  ErrorThrow.h
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#ifndef ERRORTHROW_H
#define ERRORTHROW_H

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

JSValue* jsDoThrowError(JSContext *ctx, NSString *msg);

#endif
