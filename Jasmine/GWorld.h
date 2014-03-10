//
//  GWorld.h
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLMatrixStack.h"
#import "GObject.h"
#import "GCamera.h"
#import "GProjection.h"

@interface GWorld : NSObject

@property (nonatomic, readonly) GCamera *camera;
@property (nonatomic, readonly) GProjection *projection;

@property (nonatomic, readonly) NSArray *objects;

- (void)visit;

- (void)addObject:(GObject*)obj;
- (void)insertObject:(GObject*)obj atIndex:(NSUInteger)index;
- (void)removeObject:(GObject*)obj;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeAllObjects;

@end
