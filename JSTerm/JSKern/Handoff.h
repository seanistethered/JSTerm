//
//  Handoff.h
//  JSTerm
//
//  Created by fridakitten on 15.03.25.
//

#ifndef HANDOFF_H
#define HANDOFF_H

#import <Foundation/Foundation.h>
#import "Machine.h"
#import "../UI/TerminalView.h"

/*
 typedef struct for the kernel structure blahblahblah
 */
typedef struct {
    Machine *machine;
    TerminalView *ui;
} kernel_preserve_structure_t;

/*
 @Brief functions for object handoff
 */
Machine* handoffMachine(void);
TerminalView* handoffUI(void);

#endif
