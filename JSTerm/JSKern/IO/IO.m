//
//  IO.m
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#import "IO.h"
#import "../Handoff.h"
#import <JSTerm-Swift.h>

/*
 @Brief the actual interface of the IO class of JSKern
 */
@implementation JSKERN_IO

- (instancetype)init
{
    self = [super init];
    _thread = dispatch_queue_create("meow", DISPATCH_QUEUE_CONCURRENT);
    _machine = handoffMachine();
    return self;
}

- (void)fs_set_perm:(NSString*)path perms:(FilePermissions*)Perms
{
    dispatch_sync(_thread, ^{
        // Root path check
        if ([path isEqual: @"/"]) {
            // Root permission change is not allowed, rejecting request
            return;
        }

        // Proceeding
        NSString *fullPath = [NSString stringWithFormat:@"%@%@/perm", _machine.JSTermPerm, path];
        NSString *fullRootPath = [NSString stringWithFormat:@"%@%@", _machine.JSTermRoot, path];

        NSFileManager *manager = [NSFileManager defaultManager];
        
        if (![manager fileExistsAtPath:fullRootPath]) {
            return;
        }

        if (![manager fileExistsAtPath:fullPath]) {
            NSURL *url = [[NSURL fileURLWithPath:fullPath] URLByDeletingLastPathComponent];
            NSDictionary *attributes = @{
                NSFileCreationDate: [NSDate date],
            };
            NSError *createError = nil;
            if (![manager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:attributes error:&createError]) {
                return;
            }
        }

        NSDictionary *permissionsDict = @{
            @"owner": @(Perms.owner),
            @"group": @(Perms.group),
            @"owner_read": @(Perms.owner_read),
            @"owner_write": @(Perms.owner_write),
            @"owner_execute": @(Perms.owner_execute),
            @"group_read": @(Perms.group_read),
            @"group_write": @(Perms.group_write),
            @"group_execute": @(Perms.group_execute),
            @"other_read": @(Perms.other_read),
            @"other_write": @(Perms.other_write),
            @"other_execute": @(Perms.other_execute)
        };

        NSError *jsonError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:permissionsDict options:NSJSONWritingPrettyPrinted error:&jsonError];

        if (jsonError) {
            NSLog(@"Failed to serialize JSON: %@", jsonError.localizedDescription);
            return;
        }

        NSError *writeError = nil;
        BOOL success = [jsonData writeToFile:fullPath options:NSDataWritingAtomic error:&writeError];

        if (success) {
            NSLog(@"Permissions successfully saved as JSON to file.");
        } else {
            NSLog(@"Failed to write JSON data to file: %@", writeError.localizedDescription);
        }
    });
}


- (FilePermissions*)fs_get_perm:(NSString*)path
{
    __block FilePermissions *Perms = [[FilePermissions alloc] init];
    dispatch_sync(_thread, ^{
        if([path isEqual: @"/"]) {
            [Perms setMe:0 group:0 owner_read:YES owner_write:YES owner_execute:YES group_read:YES group_write:NO group_execute:YES other_read:YES other_write:NO other_execute:YES];
            return;
        }
        
        NSString *fullPath = [NSString stringWithFormat:@"%@%@/perm", _machine.JSTermPerm, path];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:fullPath]) {
            [Perms setMe:0 group:0 owner_read:NO owner_write:NO owner_execute:NO group_read:NO group_write:NO group_execute:NO other_read:NO other_write:NO other_execute:NO];
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        if (data == nil) {
            [Perms setMe:0 group:0 owner_read:NO owner_write:NO owner_execute:NO group_read:NO group_write:NO group_execute:NO other_read:NO other_write:NO other_execute:NO];
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *permissionsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            NSLog(@"Failed to deserialize JSON: %@", jsonError.localizedDescription);
            [Perms setMe:0 group:0 owner_read:NO owner_write:NO owner_execute:NO group_read:NO group_write:NO group_execute:NO other_read:NO other_write:NO other_execute:NO];
            return;
        }
        
        [Perms setMe:[permissionsDict[@"owner"] intValue]
              group:[permissionsDict[@"group"] intValue]
        owner_read:[permissionsDict[@"owner_read"] boolValue]
        owner_write:[permissionsDict[@"owner_write"] boolValue]
        owner_execute:[permissionsDict[@"owner_execute"] boolValue]
        group_read:[permissionsDict[@"group_read"] boolValue]
        group_write:[permissionsDict[@"group_write"] boolValue]
        group_execute:[permissionsDict[@"group_execute"] boolValue]
        other_read:[permissionsDict[@"other_read"] boolValue]
        other_write:[permissionsDict[@"other_write"] boolValue]
        other_execute:[permissionsDict[@"other_execute"] boolValue]];
    });
    return Perms;
}

- (BOOL)fs_move_perm:(NSString*)srcpath destpath:(NSString*)destpath
{
    __block BOOL result = NO;
    dispatch_sync(_thread, ^{
        if([srcpath  isEqual: @"/"])
        {
            return;
        }
        if([destpath  isEqual: @"/"])
        {
            return;
        }
        
        NSString *fullsrcpath = [NSString stringWithFormat:@"%@%@/perm", _machine.JSTermPerm, srcpath];
        NSString *fulldestpath = [NSString stringWithFormat:@"%@%@/perm", _machine.JSTermPerm, destpath];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if(![manager fileExistsAtPath:fullsrcpath])
        {
            // path doesnt exist
            //
            // because this should under no condition happen we lock the possibility for a vulnerability down
            // by doing a no perm return
            //
            return;
        }
        if(![manager fileExistsAtPath:fulldestpath])
        {
            // path doesnt exist
            //
            // because this should under no condition happen we lock the possibility for a vulnerability down
            // by doing a no perm return
            //
            return;
        }
        
        NSError *error = nil;
        [manager moveItemAtPath:fullsrcpath toPath:fulldestpath error:&error];
        
        if (error) {
            // failed to move perms
            //
            // because this should under no condition happen we lock the possibility for a vulnerability down
            // by doing a no perm return
            //
            return;
        }
        
        result = YES;
    });
    return result;
}

- (BOOL)fs_remove_perm:(NSString*)path
{
    __block BOOL result = NO;
    dispatch_sync(_thread, ^{
        if([path  isEqual: @"/"])
        {
            return;
        }
        
        NSString *fullPath = [NSString stringWithFormat:@"%@%@", _machine.JSTermPerm, path];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if(![manager fileExistsAtPath:fullPath])
        {
            // doesnt exist, no perms to set
            //
            // because this should under no condition happen we lock the possibility for a vulnerability down
            // by doing a no perm return
            //
            return;
        }
        
        NSError *error = nil;
        [manager removeItemAtPath:fullPath error:&error];
        
        if (error) {
            // failed to remove perms
            //
            // because this should under no condition happen we lock the possibility for a vulnerability down
            // by doing a no perm return
            //
            return;
        }
        
        result = YES;
    });
    return result;
}

- (PermissionResult*)fs_permcheck:(NSString*)path uid:(UInt16)uid gid:(UInt16)gid {
    PermissionResult *result = [[PermissionResult alloc] init];
    result.canRead = NO;
    result.canWrite = NO;
    result.canExecute = NO;
    
    FilePermissions *perms = [self fs_get_perm:path];
    
    if (perms) {
        if (uid == 0) {
            // Superuser
            result.canRead = YES;
            result.canWrite = YES;
        }
        
        if (perms.owner == uid) {
            result.canRead = YES;
            result.canWrite = YES;
            if (perms.owner_execute) {
                result.canExecute = YES;
            }
        }
        
        if (perms.group == gid) {
            if (perms.group_read) {
                result.canRead = YES;
            }
            if (perms.group_write) {
                result.canWrite = YES;
            }
            if (perms.group_execute) {
                result.canExecute = YES;
            }
        }
        
        if (perms.other_read) {
            result.canRead = YES;
        }
        if (perms.other_write) {
            result.canWrite = YES;
        }
        if (perms.group_execute) {
            result.canExecute = YES;
        }
    }
    
    return result;
}

- (PermissionResult*)fs_treepermcheck:(NSString*)path uid:(UInt16)uid gid:(UInt16)gid {
    PermissionResult *result = [self fs_permcheck:path uid:uid gid:gid];
    
    if (uid == 0) {
        return result;
    }
    
    if (!result.canRead && !result.canWrite && !result.canExecute) {
        return result;
    }
    
    NSString *currentPath = path;
    
    while (![currentPath isEqualToString:@"/"]) {
        NSString *parentPath = [currentPath stringByDeletingLastPathComponent];
        
        if ([parentPath isEqualToString:currentPath]) {
            break;
        }
        
        PermissionResult *parentPerms = [self fs_permcheck:parentPath uid:uid gid:gid];
        
        if (!(parentPerms.canRead && parentPerms.canExecute)) {
            // Path is inaccessible
            result.canWrite = NO;
            result.canRead = NO;
            result.canExecute = NO;
            break;
        }
        
        currentPath = parentPath;
    }
    
    return result;
}

@end
