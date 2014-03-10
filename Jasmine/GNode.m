//
//  GElement.m
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//

#import "GNode.h"

@implementation GNode
{
    @private
    __strong NSMutableArray *_children;
}

@synthesize children = _children;

- (id)init
{
    self = [super init];
    if (self) {
        _children = nil;
    }
    return self;
}

- (void)visitInWorld:(GWorld *)world
{
    if (!self.visible)
		return;
    GLMatrixStackPush();
    GLMatrixStackMultiple(self.modelView);
    [self renderWithModelView:GLMatrixStackGetTop() inWorld:world];
    if (_children != nil) {
        [_children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj visitInWorld:world];
        }];
    }
    GLMatrixStackPop();
}

- (GObject*)childAtIndex:(NSUInteger)index
{
    if (_children == nil)
        return nil;
    else
        return [_children objectAtIndex:index];
}

- (void)addChild:(GNode*)node
{
    if (node == nil || node.parent != nil)
        return;
    if (_children == nil) {
        _children = [[NSMutableArray alloc] init];
    }
    [_children addObject:node];
    node.parent = self;
}

- (void)insertChild:(GNode*)node atIndex:(NSUInteger)index
{
    if (_children == nil) {
        _children = [[NSMutableArray alloc] init];
    }
    [_children insertObject:node atIndex:index];
    node.parent = self;
}

- (void)removeChild:(GNode *)node
{
    if (_children == nil)
        return;
    node.parent = nil;
    [_children removeObject:node];
}

- (void)removeChildAtIndex:(NSUInteger)index
{
    if (_children == nil)
        return;
    GNode *node = [self childAtIndex:index];
    node.parent = nil;
    [_children removeObjectAtIndex:index];
}

- (void)removeAllChildren
{
    if (_children == nil)
        return;
    [_children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GNode *node = (GNode*)obj;
        node.parent = nil;
    }];
    [_children removeAllObjects];
}


@end
