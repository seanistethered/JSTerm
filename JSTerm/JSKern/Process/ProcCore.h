//
//  ProcCore.h
//  JSTerm
//
//  Created by fridakitten on 11.03.25.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include <pthread.h>

/*
 @Brief structure for ProcCoreHelper
 */
typedef struct {
    NSString *code;
    NSString *symbol;
    JSContext *ctx;
    NSArray *args;
    BOOL evaluate_code;
} thread_args_js_t;

/*
 @Brief ProcCoreHelper is to use pthreads to run processes
 */
@interface ProcCoreHelper : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSValue *> *proc;
- (void)assignThread:(uint16_t)pid thread:(pthread_t *)thread;
- (pthread_t *)getThread:(uint16_t)pid;
- (void)run:(uint16_t)pid code:(NSString*)code symbol:(NSString*)symbol ctx:(JSContext*)ctx jsargs:(NSArray*)jsargs;
- (void)kill:(uint16_t)pid sema:(dispatch_semaphore_t)sema;
@end
