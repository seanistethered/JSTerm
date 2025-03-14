//
//  OctalUtilities.h
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#ifndef OCTALUTILITIES_H
#define OCTALUTILITIES_H

#import "FilePermissions.h"

PermissionResult *octalHelper(NSInteger digit);
FilePermissions *parseFilePermissionsFromOctal(NSInteger octal);

#endif
