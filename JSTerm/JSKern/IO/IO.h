//
//  IO.h
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#ifndef JSKERN_IO_H
#define JSKERN_IO_H

#import <Foundation/Foundation.h>
#import "FilePermissions.h"

@interface JSKERN_IO : NSObject

@property (nonatomic, strong) dispatch_queue_t thread;

- (void)fs_set_perm:(NSString*)path perms:(FilePermissions*)Perms;
- (FilePermissions*)fs_get_perm:(NSString*)path;
- (BOOL)fs_move_perm:(NSString*)srcpath destpath:(NSString*)destpath;
- (BOOL)fs_remove_perm:(NSString*)path;
- (PermissionResult*)fs_permcheck:(NSString*)path uid:(UInt16)uid gid:(UInt16)gid;
- (PermissionResult*)fs_treepermcheck:(NSString*)path uid:(UInt16)uid gid:(UInt16)gid;

@end

#endif
