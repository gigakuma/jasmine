//
//  GWorld.m
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//

#import "GWorld.h"

@implementation GWorld
{
    @private
    __strong NSMutableArray *_objects;
}

@synthesize camera;
@synthesize projection;

@synthesize objects = _objects;

- (id)init
{
    self = [super init];
    if (self) {
        camera = [GCamera new];
        projection = [GProjection new];
        _objects = [NSMutableArray new];
    }
    return self;
}

- (void)visit
{
    GLMatrixStackLoad(camera.matrix);
    [_objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GObject *go = (GObject*)obj;
        [go visitInWorld:self];
    }];
}

- (void)addObject:(GObject*)obj
{
    [_objects addObject:obj];
}

- (void)insertObject:(GObject *)obj atIndex:(NSUInteger)index
{
    [_objects insertObject:obj atIndex:index];
}

- (void)removeObject:(GObject *)obj
{
    [_objects removeObject:obj];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [_objects removeObjectAtIndex:index];
}

- (void)removeAllObjects
{
    [_objects removeAllObjects];
}

@end
