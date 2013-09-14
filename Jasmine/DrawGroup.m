//
//  DrawContainer.m
//  Jasmine
//
//  Created by Gong Zhang on 12-10-10.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "DrawGroup.h"

@implementation DrawGroup
{
    @private
    __strong NSMutableArray *_children;
}

- (id)init
{
    self = [super init];
    if (self) {
        _children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)visit
{
    if (!self.visible)
		return;
    
    GLMatrixStackPush();
    GLMatrixStackMultiple(self.modelView);
    _modelToWorldTransformCache = GLMatrixStackGetTop();
//    [self draw];
    [_children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj visit];
    }];
    GLMatrixStackPop();
}

- (NSArray*)children
{
    return _children;
}

- (void)addChild:(DrawModel*)model
{
    [_children addObject:model];
    model.parent = self;
    model.world = self.world;
}

- (void)insertChild:(DrawModel*)model atIndex:(int)index
{
    [_children insertObject:model atIndex:index];
    model.parent = self;
    model.world = self.world;
}

- (void)removeChild:(DrawModel*)model
{
    model.world = nil;
    model.parent = nil;
    [_children removeObject:model];
}

- (void)removeChildAtIndex:(int)index
{
    DrawModel *model = [_children objectAtIndex:index];
    model.world = nil;
    model.parent = nil;
    [_children removeObjectAtIndex:index];
}

- (void)removeAllChildren
{
    for (DrawModel *model in _children) {
        model.world = nil;
        model.parent = nil;
    }
    [_children removeAllObjects];
}

@end
