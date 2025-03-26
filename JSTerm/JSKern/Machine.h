//
//  Machine.h
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#ifndef JSKERN_MACHINE
#define JSKERN_MACHINE

#import <Foundation/Foundation.h>

@interface Machine : NSObject

@property (nonatomic, strong, readonly) NSString *JSTermRoot;
@property (nonatomic, strong, readonly) NSString *JSTermKernel;
@property (nonatomic, strong, readonly) NSString *JSTermPerm;
@property (nonatomic, strong, readonly) NSString *JSTermKernelName;
@property (nonatomic, strong, readonly) NSString *JSTermKernelVersion;
@property (nonatomic, strong, readonly) NSNumber *JSTermClock;

- (NSNumber*)getClock;

@end

#endif
