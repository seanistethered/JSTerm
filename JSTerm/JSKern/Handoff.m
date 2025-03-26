//
//  Handoff.m
//  JSTerm
//
//  Created by fridakitten on 15.03.25.
//

#import "Handoff.h"

kernel_preserve_structure_t *kernel_preserve = NULL;

void kernel_preserve_check(void)
{
    if(kernel_preserve == NULL)
    {
        kernel_preserve = malloc(sizeof(kernel_preserve_structure_t));
        kernel_preserve->machine = [[Machine alloc] init];
        kernel_preserve->ui = [[TerminalView alloc] init];
    }
}

Machine* handoffMachine(void)
{
    kernel_preserve_check();
    return kernel_preserve->machine;
}

TerminalView* handoffUI(void)
{
    kernel_preserve_check();
    return kernel_preserve->ui;
}
