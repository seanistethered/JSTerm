//
//  Machine.m
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#import "Machine.h"
#import "../UI/TerminalView.h"

@implementation Machine

- (instancetype)init
{
    self = [super init];
    NSString *discRoot = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    _JSTermClock = @([[NSDate date] timeIntervalSince1970]);
    _JSTermRoot = [NSString stringWithFormat:@"%@/rootfs", discRoot];
    _JSTermKernel = [NSString stringWithFormat:@"%@/kernelfs", discRoot];
    _JSTermPerm = [NSString stringWithFormat:@"%@/permfs", discRoot];
    _JSTermKernelName  = @"JSKern";
    _JSTermKernelVersion = @"2.0 (alpha)";
    return self;
}

- (NSNumber*)getClock
{
    NSNumber *result = [[NSNumber alloc] initWithDouble:[[NSDate date] timeIntervalSince1970] - [_JSTermClock doubleValue]];
    return result;
}

@end
