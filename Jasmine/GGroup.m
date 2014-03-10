//
//  GGroup.m
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//

#import "GGroup.h"

@implementation GGroup
{
    @private
    __strong NSMutableSet *_members;
}

@synthesize members = _members;

- (id)init
{
    self = [super init];
    if (self) {
        _members = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)transformWithMatrix:(GLKMatrix4)matrix
{
    [_members enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [obj transformWithMatrix:matrix];
    }];
}

- (void)addMember:(id<GTransformable>)member
{
    [_members addObject:member];
}

- (void)removeMember:(id<GTransformable>)member
{
    [_members removeObject:member];
}

- (void)removeAllMembers
{
    [_members removeAllObjects];
}

@end
