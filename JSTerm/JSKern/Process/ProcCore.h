//
//  ProcCore.h
//  JSTerm
//
//  Created by fridakitten on 11.03.25.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <JSTerm-Swift.h>
#include <pthread.h>

void proccore_run(uint16_t pid, NSString *code, JSContext *ctx, NSArray *jsargs);
void proccore_kill(uint16_t pid);
void proccore_assign(uint16_t pid, pthread_t thread);
