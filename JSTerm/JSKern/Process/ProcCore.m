//
//  ProcCore.c
//  JSTerm
//
//  Created by fridakitten on 11.03.25.
//

#import "ProcCore.h"

/*
 @Brief structure for ProcCoreHelper
 */
typedef struct {
    NSString *code;
    JSContext *ctx;
    NSArray *args;
} thread_args_js_t;

/*
 @Brief thread for ProcCoreHelper
 */
void* proccore_thread(void *args)
{
    thread_args_js_t *targs = (thread_args_js_t*)args;
    
    JSContext *ctx = targs->ctx;
    
    [ctx evaluateScript:targs->code];
    JSValue *mainFunction = [ctx objectForKeyedSubscript:@"main"];
    [mainFunction callWithArguments:targs->args];
    
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
    return value ? (pthread_t *)[value pointerValue] : NULL;
}

- (void)run:(uint16_t)pid code:(NSString*)code ctx:(JSContext*)ctx jsargs:(NSArray*)jsargs {
    thread_args_js_t *args = malloc(sizeof(thread_args_js_t));
    args->code = code;
    args->ctx = ctx;
    args->args = jsargs;
    
    pthread_t *thread = malloc(sizeof(pthread_t));
    pthread_create(thread, NULL, proccore_thread, args);
    
    [self assignThread:pid thread:thread];
    
    // TODO: handle process killing the proper way if a parent process of many child processes gets killed
    pthread_join(*thread, NULL);
}

- (void)kill:(uint16_t)pid {
    pthread_t *thread = [self getThread:pid];
    pthread_cancel(*thread);
}

@end
