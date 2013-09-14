//
//  DrawScreen.m
//  Jasmine
//
//  Created by Qiang Li on 13-7-19.
//  Copyright (c) 2013 Qiang Li. All rights reserved.
//

#import "DrawScene.h"

DrawModelDispatcher DefaultDispatcher = ^(DrawScene *scene) {
    void (^__weak __block iterator)(DrawGroup*) = ^(DrawGroup *group) {
        for (DrawModel *model in group.children) {
            [scene queueDrawModel:model];
            if ([model isKindOfClass:[DrawGroup class]]) {
                iterator((DrawGroup*)model);
            }
        }
    };
    for (DrawWorld *world in scene.worlds) {
        iterator((DrawGroup*)world);
    }
};

@implementation DrawScene
{
    NSMutableArray *_worlds;
    NSMutableArray *_drawSequence;
}

@synthesize worlds = _worlds;
@synthesize drawSequence = _drawSequence;

- (id)init
{
    self = [super init];
    if (self != nil) {
        _worlds = [[NSMutableArray alloc] init];
        _drawSequence = [[NSMutableArray alloc] init];
        _dispatcher = DefaultDispatcher;
    }
    return self;
}

- (void)addWorld:(DrawWorld*)world
{
    [_worlds addObject:world];
}

- (void)insertWorld:(DrawWorld*)world atIndex:(int)index
{
    [_worlds insertObject:world atIndex:index];
}

- (void)removeWorld:(DrawWorld*)world
{
    [_worlds removeObject:world];
}

- (void)removeWorldAtIndex:(int)index
{
    [_worlds removeObjectAtIndex:index];
}

- (void)removeAllWorlds
{
    [_worlds removeAllObjects];
}

- (void)draw
{
    glClearColor(25.f/255, 25.f/255, 25.f/255, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    for (DrawModel *model in _drawSequence) {
//        NSLog(@"%@", [[model class] description]);
        [model draw];
    }
}

- (void)visit
{
    for (DrawWorld *world in _worlds) {
        [world visit];
    }
    [_drawSequence removeAllObjects];
    self.dispatcher(self);
}

- (void)queueDrawModel:(DrawModel *)model
{
    [_drawSequence addObject:model];
}

@end
