//
//  MakeUUID.m
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#import "MakeUUID.h"

UInt64 generateUInt64UUID(void) {
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *uuidString = [uuid UUIDString];
    
    NSString *uuidWithoutDashes = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    if (uuidWithoutDashes.length != 32) {
        return 0;
    }
    
    NSString *uuidSubString = [uuidWithoutDashes substringToIndex:16];
    
    unsigned long long int uuidInt64 = strtoull([uuidSubString UTF8String], NULL, 16);
    
    return (UInt64)uuidInt64;
}
