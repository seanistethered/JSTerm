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

BackIO *backio;

- (instancetype)init {
    self = [super init];
    if (self) {
        _proc = [NSMutableDictionary dictionary];
        backio = [[BackIO alloc] init];
    }
    return self;
}

- (void)assignThread:(uint16_t)pid thread:(pthread_t *)thread {
    [backio osprintWithMsg:[NSString stringWithFormat: @"[ProcCore:%d] requestor requested attach thread %p to pid %d", pid, thread, pid]];
    self.proc[@(pid)] = [NSValue valueWithPointer:thread];
    [backio osprintWithMsg:[NSString stringWithFormat: @"[ProcCore:%d] attached thread %p to pid %d", pid, thread, pid]];
}

- (pthread_t *)getThread:(uint16_t)pid {
    [backio osprintWithMsg:[NSString stringWithFormat: @"[ProcCore:%d] requestor asked for the thread of pid %d", pid, pid]];
    NSValue *value = self.proc[@(pid)];
    pthread_t *thread_ptr = value ? (pthread_t *)[value pointerValue] : NULL;
    [backio osprintWithMsg:[NSString stringWithFormat: @"[ProcCore:%d] thread of %d is %p", pid, pid, thread_ptr]];
    return thread_ptr;
}

- (void)run:(uint16_t)pid code:(NSString*)code symbol:(NSString*)symbol ctx:(JSContext*)ctx jsargs:(NSArray*)jsargs {
    [backio osprintWithMsg:[NSString stringWithFormat: @"[ProcCore:%d] requestor asked to run a task\nINFO\npid: %d\nsymbol: %@\ncontext:%p\njsagrs: %p", pid, pid, symbol, ctx, jsargs]];
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
    [backio osprintWithMsg:[NSString stringWithFormat: @"[ProcCore:%d] requestor requested to kill pid %d", pid, pid]];
    pthread_t *thread = [self getThread:pid];
    [backio osprintWithMsg:[NSString stringWithFormat: @"[ProcCore:%d] found thread %p for pid %d", pid, thread, pid]];
    
    int result = pthread_kill(*thread, 0);
    [backio osprintWithMsg:[NSString stringWithFormat: @"[ProcCore:%d] killed thread %p with result %d", pid, thread, result]];
    
    if (result == 0) {
        pthread_cancel(*thread);
    } else {
        [backio osprintWithMsg:[NSString stringWithFormat: @"[ProcCore:%d] looks like i wasnt able to do my job for pid %d", pid, pid]];
    }
    
    dispatch_semaphore_signal(sema);
}

@end
