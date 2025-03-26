//
//  Kernel.m
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#import "Kernel.h"

#include <pthread.h>

static Machine *machine = NULL;
static JSKERN_IO *io = NULL;
static ProcCoreHelper *proccore = NULL;
static TerminalView *ui = NULL;
static JSKERN_SERIAL_IO *serial_io = NULL;
static pthread_t kern_thread;

/*
 @Brief function of Kernel Shell
 */
void *kernel_main_thread(void *argsd)
{
    TerminalLCD *tlcd = [ui getSerial:0];
    NSString *input;
    while(1)
    {
        input = [serial_io readline:tlcd prompt:@"kernel:/> "];
        NSArray *tokens = [input componentsSeparatedByString:@" "];
        
        if([tokens[0] isEqual:@"exit"])
        {
            exit(0);
        } else if([tokens[0] isEqual:@"serial_io"])
        {
            if([tokens[1] isEqual:@"spawn"])
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [ui spawnSerial];
                });
            }
        } else {
            [serial_io print:tlcd msg:@"Invalid Command\n"];
        }
    }
    return NULL;
}

/*
 @Brief function to kickstart the building process
 */
void jskern_kickstart(TerminalView *tcontroller)
{
    // gathering machine object
    machine = handoffMachine();
    
    // creating io objects
    io = [[JSKERN_IO alloc] init];
    serial_io = [[JSKERN_SERIAL_IO alloc] init];
    
    // creating procore object
    proccore = [[ProcCoreHelper alloc] init];
    
    // getting uirootcontroller
    ui = tcontroller;
    
    // trying our osprint ;)
    [ui osprint:[NSString stringWithFormat:@"[kernel]"]];
    [ui osprint:[NSString stringWithFormat:@"hello from kernel!"]];
    
    [ui osprint:[NSString stringWithFormat:@"[kernel -> object structure]"]];
    [ui osprint:[NSString stringWithFormat:@"machine: %p", machine]];
    [ui osprint:[NSString stringWithFormat:@"io: %p", io]];
    [ui osprint:[NSString stringWithFormat:@"serial_io: %p", serial_io]];
    [ui osprint:[NSString stringWithFormat:@"proc: %p", proccore]];
    [ui osprint:[NSString stringWithFormat:@"ui: %p", ui]];
    
    [ui osprint:[NSString stringWithFormat:@"[kernel -> starting kernel shell]"]];
    
    pthread_create(&kern_thread, NULL, kernel_main_thread, NULL);
}
