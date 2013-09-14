//
//  DrawScreen.h
//  Jasmine
//
//  Created by Qiang Li on 13-7-19.
//  Copyright (c) 2013 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawWorld.h"


@interface DrawScene : NSObject

typedef void (^DrawModelDispatcher)(DrawScene*);

extern DrawModelDispatcher DefaultDispatcher;

@property (nonatomic, readonly) NSArray *worlds;
@property (nonatomic, readonly) NSArray *drawSequence;
@property (nonatomic, assign) DrawModelDispatcher dispatcher;

- (void)visit;
- (void)draw;

- (void)queueDrawModel:(DrawModel*)model;

- (void)addWorld:(DrawWorld*)world;
- (void)insertWorld:(DrawWorld*)world atIndex:(int)index;
- (void)removeWorld:(DrawWorld*)world;
- (void)removeWorldAtIndex:(int)index;
- (void)removeAllWorlds;

@end
