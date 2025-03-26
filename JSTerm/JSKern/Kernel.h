//
//  Kernel.h
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#ifndef JSKERN_H
#define JSKERN_H

// Handoff System
#import "Handoff.h"

// Machine Header
#import "Machine.h"

// Communication Headers
#import "Communication/DBus.h"

// IO Headers
#import "IO/IO.h"
#import "IO/SerialIO.h"
#import "IO/FilePermissions.h"
#import "IO/OctalUtilities.h"

// Process Headers
#import "Process/ErrorThrow.h"
#import "Process/ProcCore.h"
#import "Process/Process.h"

// Frontend
#import "../UI/TerminalView.h"

#endif
