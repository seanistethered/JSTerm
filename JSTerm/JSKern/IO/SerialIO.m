//
//  SerialIO.m
//  JSTerm
//
//  Created by fridakitten on 15.03.25.
//

#import "SerialIO.h"

#include <unistd.h>

@implementation JSKERN_SERIAL_IO

- (instancetype)init
{
    self = [super init];
    return self;
}

- (void)print:(TerminalLCD*)tlcd msg:(NSString*)msg
{
    usleep(1);
    dispatch_sync(dispatch_get_main_queue(), ^{
        tlcd.text = [tlcd.text stringByAppendingFormat:@"%@", msg];
    });
}

- (NSString*)readline:(TerminalLCD*)tlcd prompt:(NSString*)prompt
{
    // prepare
    usleep(1);
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSString *captured = @"";
    
    // changing to main thread asyncronyously
    dispatch_async(dispatch_get_main_queue(), ^{
        // printing prompt
        tlcd.text = [tlcd.text stringByAppendingFormat:@"%@", prompt];
        
        // setting input action
        [tlcd setInput:^(NSString *input, TerminalLCD *tlcd) {
            if([input isEqual:@"\n"])
            {
                tlcd.text = [tlcd.text stringByAppendingFormat:@"%@", input];
                dispatch_semaphore_signal(semaphore);
                return;
            }
            tlcd.text = [tlcd.text stringByAppendingFormat:@"%@", input];
            captured = [captured stringByAppendingFormat:@"%@", input];
        }];
        
        // setting deletion action
        [tlcd setDeletion:^(NSString *input, TerminalLCD *tlcd) {
            if(![captured isEqual:@""])
            {
                tlcd.text = [tlcd.text substringToIndex:[tlcd.text length] - 1];
                captured = [captured substringToIndex:[captured length] - 1];
            }
        }];
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    // now removing stuff
    [tlcd setInput:^(NSString *input, TerminalLCD *tlcd) {}];
    [tlcd setDeletion:^(NSString *input, TerminalLCD *tlcd) {}];
    
    return captured;
}

@end
