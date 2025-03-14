//
//  FilePermissions.m
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

#import "FilePermissions.h"

@implementation FilePermissions

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Default initialization, if necessary
        _owner = 0;
        _group = 0;
        _owner_read = NO;
        _owner_write = NO;
        _owner_execute = NO;
        _group_read = NO;
        _group_write = NO;
        _group_execute = NO;
        _other_read = NO;
        _other_write = NO;
        _other_execute = NO;
    }
    return self;
}

- (void)setMe:(UInt16)o group:(UInt16)g owner_read:(BOOL)or owner_write:(BOOL)ow owner_execute:(BOOL)ox group_read:(BOOL)gr group_write:(BOOL)gw group_execute:(BOOL)gx other_read:(BOOL)otr other_write:(BOOL)otw other_execute:(BOOL)otx
{
    _owner = o;
    _group = g;
    _owner_read = or;
    _owner_write = ow;
    _owner_execute = ox;
    _group_read = gr;
    _group_write = gw;
    _group_execute = gx;
    _other_read = otr;
    _other_write = otw;
    _other_execute = otx;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.owner forKey:@"owner"];
    [coder encodeInteger:self.group forKey:@"group"];
    [coder encodeBool:self.owner_read forKey:@"ownerRead"];
    [coder encodeBool:self.owner_write forKey:@"ownerWrite"];
    [coder encodeBool:self.owner_execute forKey:@"ownerExecute"];
    [coder encodeBool:self.group_read forKey:@"groupRead"];
    [coder encodeBool:self.group_write forKey:@"groupWrite"];
    [coder encodeBool:self.group_execute forKey:@"groupExecute"];
}

- (void)decodeWithCoder:(NSCoder *)coder {
    _owner = [coder decodeIntegerForKey:@"owner"];
    _group = [coder decodeIntegerForKey:@"group"];
    _owner_read = [coder decodeBoolForKey:@"ownerRead"];
    _owner_write = [coder decodeBoolForKey:@"ownerWrite"];
    _owner_execute = [coder decodeBoolForKey:@"ownerExecute"];
    _group_read = [coder decodeBoolForKey:@"groupRead"];
    _group_write = [coder decodeBoolForKey:@"groupWrite"];
    _group_execute = [coder decodeBoolForKey:@"groupExecute"];
}

- (instancetype)initWithOwner:(UInt16)o group:(UInt16)g ownerRead:(BOOL)or ownerWrite:(BOOL)ow ownerExecute:(BOOL)ox groupRead:(BOOL)gr groupWrite:(BOOL)gw groupExecute:(BOOL)gx otherRead:(BOOL)otr otherWrite:(BOOL)otw otherExecute:(BOOL)otx {
    self = [super init];
    _owner = o;
    _group = g;
    _owner_read = or;
    _owner_write = ow;
    _owner_execute = ox;
    _group_read = gr;
    _group_write = gw;
    _group_execute = gx;
    _other_read = otr;
    _other_write = otw;
    _other_execute = otx;
    return self;
}

@end

@implementation PermissionResult

- (instancetype) init {
    self = [super init];
    return self;
}

@end
