//
//  ProcCore.c
//  JSTerm
//
//  Created by fridakitten on 11.03.25.
//

#import "ProcCore.h"
#import <JSTerm-Swift.h>
#include <stdint.h>

/*
 @Brief thread for ProcCoreHelper
 */
void* proccore_thread(void *args)
{
    thread_args_js_t *targs = (thread_args_js_t*)args;
    
    JSContext *ctx = targs->ctx;
    
    [ctx evaluateScript:targs->code];
    JSValue *function = [ctx objectForKeyedSubscript:targs->symbol];
    [function callWithArguments:targs->args];
    
    return NULL;
}

/*
 @Brief ProcCoreHelper
 */
@implementation ProcCoreHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        _proc = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)assignThread:(uint16_t)pid thread:(pthread_t *)thread {
    self.proc[@(pid)] = [NSValue valueWithPointer:thread];
}

- (pthread_t *)getThread:(uint16_t)pid {
    NSValue *value = self.proc[@(pid)];
    pthread_t *thread_ptr = value ? (pthread_t *)[value pointerValue] : NULL;
    return thread_ptr;
}

- (void)run:(uint16_t)pid code:(NSString*)code symbol:(NSString*)symbol ctx:(JSContext*)ctx jsargs:(NSArray*)jsargs {
    thread_args_js_t *args = malloc(sizeof(thread_args_js_t));
    args->code = code;
    args->ctx = ctx;
    args->args = jsargs;
    args->symbol = symbol;
    args->evaluate_code = YES;
    
    pthread_t *thread = malloc(sizeof(pthread_t));
    pthread_create(thread, NULL, proccore_thread, args);
    
    [self assignThread:pid thread:thread];
    
    // TODO: handle process killing the proper way if a parent process of many child processes gets killed
    pthread_join(*thread, NULL);
}

- (void)kill:(uint16_t)pid sema:(dispatch_semaphore_t)sema {
    pthread_t *thread = [self getThread:pid];
    
    int result = pthread_kill(*thread, 0);
    
    if (result == 0) {
        pthread_cancel(*thread);
    }
    
    dispatch_semaphore_signal(sema);
}

@end
