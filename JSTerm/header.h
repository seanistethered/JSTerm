//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

void proccore_run(uint16_t pid, NSString *code, JSContext *ctx, NSArray *jsargs);
void proccore_kill(uint16_t pid);
void proccore_assign(uint16_t pid, pthread_t thread);
