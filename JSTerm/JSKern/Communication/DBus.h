//
//  DBus.h
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#ifndef JSKERN_DBUS_H
#define JSKERN_DBUS_H

// platform headers
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

// headers to other kernel stuff
#import "../Process/ErrorThrow.h"

@interface JS_DBUS : NSObject

@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSString *data;

@end

@interface JS_DBUS_SYSTEM : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, JS_DBUS *> *bus;

- (void)register:(NSString*)bus_id;
- (void)unregister:(NSString*)bus_id;
- (NSString*)waitformsg:(NSString*)bus_id semaphore:(dispatch_semaphore_t) semaphore;
- (void)sendmsg:(NSString*)bus_id payload:(NSString*)payload;

@end

#endif
