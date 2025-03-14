//
//  DBus.m
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#import "DBus.h"

/*
 @Brief for each DBUS connection a process has
 */
@implementation JS_DBUS

- (instancetype)init
{
    self = [super init];
    _semaphore = NULL;
    _data = @"";
    return self;
}

- (void)attach:(dispatch_semaphore_t)semaphore
{
    _semaphore = semaphore;
}

- (NSString*)waitformsg
{
    if(_semaphore == NULL)
    {
        return @"";
    }
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    return _data;
}

- (void)sendmsg:(NSString*)msg
{
    if(_semaphore == NULL)
    {
        return;
    }
    
    _data = msg;
    
    dispatch_semaphore_signal(_semaphore);
}

@end

/*
 @Brief the system that manages the DBus connections
 */
@implementation JS_DBUS_SYSTEM

- (instancetype)init
{
    self = [super init];
    _bus = [NSMutableDictionary dictionary];
    return self;
}

- (void)register:(NSString*)bus_id
{
    _bus[bus_id] = [[JS_DBUS alloc] init];
}

- (void)unregister:(NSString*)bus_id
{
    [_bus removeObjectForKey:bus_id];
}

- (NSString*)waitformsg:(NSString*)bus_id semaphore:(dispatch_semaphore_t) semaphore
{
    [_bus[bus_id] attach:semaphore];
    return [_bus[bus_id] waitformsg];
}

- (void)sendmsg:(NSString*)bus_id payload:(NSString*)payload
{
    [_bus[bus_id] sendmsg:payload];
}

@end
