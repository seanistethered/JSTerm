//
//  OctalUtilities.m
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#import <Foundation/Foundation.h>
#import <JSTerm-Swift.h>

#import "OctalUtilities.h"

// HOPE
PermissionResult *octalHelper(NSInteger digit)
{
    PermissionResult * result = [[PermissionResult alloc] init];
    if (digit >= 4) {
        result.canRead = true;
        digit -= 4;
    }
    if (digit >= 2) {
        result.canWrite = true;
        digit -= 2;
    }
    if (digit >= 1) {
        result.canExecute = true;
    }
    return result;
}

// helper
FilePermissions *parseFilePermissionsFromOctal(NSInteger octal)
{
    if (octal < 0 || octal > 778) {
        return nil; // Invalid input, octal must be in the range 0-0777
    }
    
    int digit1 = octal / 100;
    int digit2 = (octal / 10) % 10;
    int digit3 = octal % 10;
    
    PermissionResult *per1 = octalHelper(digit1);
    PermissionResult *per2 = octalHelper(digit2);
    PermissionResult *per3 = octalHelper(digit3);
    
    FilePermissions *permission = [[FilePermissions alloc] init];
    permission.owner_read = per1.canRead;
    permission.owner_write = per1.canWrite;
    permission.owner_execute = per1.canExecute;
    permission.group_read = per2.canRead;
    permission.group_write = per2.canWrite;
    permission.group_execute = per2.canExecute;
    permission.other_read = per3.canRead;
    permission.other_write = per3.canWrite;
    permission.other_execute = per3.canExecute;
    
    return permission;
}
