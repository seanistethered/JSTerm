//
//  ProcCore.c
//  JSTerm
//
//  Created by fridakitten on 11.03.25.
//

#import "ProcCore.h"

typedef struct {
    NSString *code;
    JSContext *ctx;
    NSArray *args;
} thread_args_js_t;

proccorehelper *helper = NULL;

void proccore_init(void)
{
    if(helper == NULL)
    {
        helper = [[proccorehelper alloc] init];
    }
}

void* proccore_thread(void *args)
{
    thread_args_js_t *targs = (thread_args_js_t*)args;
    
    JSContext *ctx = targs->ctx;
    
    [ctx evaluateScript:targs->code];
    JSValue *mainFunction = [ctx objectForKeyedSubscript:@"main"];
    [mainFunction callWithArguments:targs->args];
    
    return NULL;
}

void proccore_run(uint16_t pid, NSString *code, JSContext *ctx, NSArray *jsargs)
{
    proccore_init();
    thread_args_js_t *args = malloc(sizeof(thread_args_js_t));
    args->code = code;
    args->ctx = ctx;
    args->args = jsargs;
    
    pthread_t *thread = malloc(sizeof(pthread_t));
    pthread_create(thread, NULL, proccore_thread, args);
    [helper assignThreadWithPid:pid thread:thread];
    pthread_join(*thread, NULL);
}

void proccore_kill(uint16_t pid)
{
    proccore_init();
    
    pthread_t *thread = [helper getThreadWithPid:pid];
    
    pthread_cancel(*thread);
}
