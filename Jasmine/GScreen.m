//
//  GScreen.m
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//

#import "GScreen.h"

@implementation GScreen
{
    @private
    __strong NSMutableArray *_worlds;
}

@synthesize worlds = _worlds;

- (id)init
{
    self = [super init];
    if (self) {
        _worlds = [NSMutableArray new];
    }
    return self;
}

- (void)render
{
    glClearColor(25.f/255, 25.f/255, 25.f/255, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    [_worlds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GWorld *gw = (GWorld*)obj;
        [gw visit];
    }];
}

- (void)addWorld:(GWorld *)world
{
    [_worlds addObject:world];
}

- (void)insertWorld:(GWorld *)world atIndex:(NSUInteger)index
{
    [_worlds insertObject:world atIndex:index];
}

- (void)removeWorld:(GWorld *)world
{
    [_worlds removeObject:world];
}

- (void)removeWorldAtIndex:(NSUInteger)index
{
    [_worlds removeObjectAtIndex:index];
}

- (void)removeAllWorlds
{
    [_worlds removeAllObjects];
}

@end
