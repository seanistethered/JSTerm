//
//  FilePermissions.h
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#ifndef JSKERN_FILEPERMISSIONS_H
#define JSKERN_FILEPERMISSIONS_H

#import <Foundation/Foundation.h>

@interface FilePermissions : NSObject

@property (nonatomic, assign) UInt16 owner;
@property (nonatomic, assign) UInt16 group;

@property (nonatomic, assign) BOOL owner_read;
@property (nonatomic, assign) BOOL owner_write;
@property (nonatomic, assign) BOOL owner_execute;

@property (nonatomic, assign) BOOL group_read;
@property (nonatomic, assign) BOOL group_write;
@property (nonatomic, assign) BOOL group_execute;

@property (nonatomic, assign) BOOL other_read;
@property (nonatomic, assign) BOOL other_write;
@property (nonatomic, assign) BOOL other_execute;

- (instancetype)initWithOwner:(UInt16)o
                        group:(UInt16)g
                  ownerRead:(BOOL)or
                 ownerWrite:(BOOL)ow
              ownerExecute:(BOOL)ox
                  groupRead:(BOOL)gr
                 groupWrite:(BOOL)gw
              groupExecute:(BOOL)gx
                otherRead:(BOOL)otr
               otherWrite:(BOOL)otw
            otherExecute:(BOOL)otx;

- (void)setMe:(UInt16)o group:(UInt16)g owner_read:(BOOL)or owner_write:(BOOL)ow owner_execute:(BOOL)ox group_read:(BOOL)gr group_write:(BOOL)gw group_execute:(BOOL)gx other_read:(BOOL)otr other_write:(BOOL)otw other_execute:(BOOL)otx;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)decodeWithCoder:(NSCoder *)coder;

@end

@interface PermissionResult : NSObject

@property (nonatomic, assign) BOOL canRead;
@property (nonatomic, assign) BOOL canWrite;
@property (nonatomic, assign) BOOL canExecute;

@end


#endif
